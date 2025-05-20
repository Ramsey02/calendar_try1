// providers/student_provider.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import '../models/student_model.dart';

class StudentProvider with ChangeNotifier {
  StudentModel? _student;
  bool _isLoading = false;
  String _error = '';
  String _currentSemester = 'Winter 2024/25'; // Default current semester
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EventController _eventController = EventController();

  // Getters
  StudentModel? get student => _student;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get currentSemester => _currentSemester;
  EventController get eventController => _eventController;

  // Set current semester
  void setCurrentSemester(String semester) {
    _currentSemester = semester;
    notifyListeners();
    // Refresh events when semester changes
    fetchEvents(_student?.id ?? '');
  }

  // Fetch student data from Firestore
Future<void> fetchStudentData(String userId) async {
  // Don't notify if we're already loading
  if (_isLoading) return;
  
  _isLoading = true;
  _error = '';
  notifyListeners();

  try {
    final docSnapshot = await _firestore
        .collection('Students')
        .doc(userId)
        .get();

    if (docSnapshot.exists) {
      _student = StudentModel.fromFirestore(
          docSnapshot.data() as Map<String, dynamic>);
      
      // After getting student data, fetch their courses/events
      await fetchEvents(userId);
    } else {
      _error = 'Student not found';
    }
  } catch (e) {
    _error = 'Error fetching student data: $e';
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  // Create a new student profile if it doesn't exist
  Future<void> createStudentProfile(String userId, StudentModel student) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('Students').doc(userId).set(student.toFirestore());
      _student = student;
      
      // Create default semester document if it doesn't exist
      await _firestore
        .collection('Students')
        .doc(userId)
        .collection('Courses-per-Semesters')
        .doc(_currentSemester)
        .set({
          'Semester Number': student.semester,
        });
    } catch (e) {
      _error = 'Error creating student profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update student profile
  Future<void> updateStudentProfile(String userId, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('Students').doc(userId).update(data);
      
      // Update local student model
      final docSnapshot = await _firestore.collection('Students').doc(userId).get();
      if (docSnapshot.exists) {
        _student = StudentModel.fromFirestore(
            docSnapshot.data() as Map<String, dynamic>);
      }
    } catch (e) {
      _error = 'Error updating student profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new course
  Future<String?> addCourse(String userId, Map<String, dynamic> courseData) async {
    try {
      // Make sure required fields are present
      if (!courseData.containsKey('Name') || !courseData.containsKey('Course_Id')) {
        _error = 'Course name and ID are required';
        notifyListeners();
        return null;
      }
      
      // Set defaults for missing fields
      courseData['Status'] = courseData['Status'] ?? 'Active';
      courseData['Final_grade'] = courseData['Final_grade'] ?? 0;
      courseData['Last_Semester_taken'] = courseData['Last_Semester_taken'] ?? _currentSemester;
      
      // Add to Firestore
      final courseRef = await _firestore
          .collection('Students')
          .doc(userId)
          .collection('Courses-per-Semesters')
          .doc(_currentSemester)
          .collection('Courses')
          .add(courseData);
      
      // Refresh events
      await fetchEvents(userId);
      
      return courseRef.id;
    } catch (e) {
      _error = 'Error adding course: $e';
      notifyListeners();
      return null;
    }
  }

  // Delete a course
  Future<bool> deleteCourse(String userId, String courseId) async {
    try {
      await _firestore
          .collection('Students')
          .doc(userId)
          .collection('Courses-per-Semesters')
          .doc(_currentSemester)
          .collection('Courses')
          .doc(courseId)
          .delete();
      
      // Refresh events
      await fetchEvents(userId);
      return true;
    } catch (e) {
      _error = 'Error deleting course: $e';
      notifyListeners();
      return false;
    }
  }

  // Update a course
  Future<bool> updateCourse(String userId, String courseId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('Students')
          .doc(userId)
          .collection('Courses-per-Semesters')
          .doc(_currentSemester)
          .collection('Courses')
          .doc(courseId)
          .update(data);
      
      // Refresh events
      await fetchEvents(userId);
      return true;
    } catch (e) {
      _error = 'Error updating course: $e';
      notifyListeners();
      return false;
    }
  }

  // Fetch courses for the current semester and convert to calendar events
  Future<void> fetchEvents(String userId) async {
    if (userId.isEmpty) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      // Clear existing events
      _eventController.events.clear();

      // Check if semester document exists
      final semesterDoc = await _firestore
          .collection('Students')
          .doc(userId)
          .collection('Courses-per-Semesters')
          .doc(_currentSemester)
          .get();

      if (semesterDoc.exists) {
        // Fetch all courses for this semester
        final coursesSnapshot = await _firestore
            .collection('Students')
            .doc(userId)
            .collection('Courses-per-Semesters')
            .doc(_currentSemester)
            .collection('Courses')
            .get();

        if (coursesSnapshot.docs.isNotEmpty) {
          final now = DateTime.now();
          List<CalendarEventData> events = [];

          for (var courseDoc in coursesSnapshot.docs) {
            final courseData = courseDoc.data();
            
            // Handle lecture time events
            if (courseData['Lecture_time'] != null && courseData['Lecture_time'].toString().isNotEmpty) {
              final lectureEvents = _parseTimeToEvents(
                courseData['Name'] ?? 'Unknown Course',
                courseData['Lecture_time'],
                now,
                Colors.blue.shade700,
                '${courseData['Course_Id']} - Lecture',
                courseDoc.id, // Include document ID for reference
              );
              events.addAll(lectureEvents);
            }
            
            // Handle tutorial time events
            if (courseData['Tutorial_time'] != null && courseData['Tutorial_time'].toString().isNotEmpty) {
              final tutorialEvents = _parseTimeToEvents(
                courseData['Name'] ?? 'Unknown Course',
                courseData['Tutorial_time'],
                now,
                Colors.green.shade700,
                '${courseData['Course_Id']} - Tutorial',
                courseDoc.id, // Include document ID for reference
              );
              events.addAll(tutorialEvents);
            }
          }
          
          // Add all events to the controller
          _eventController.addAll(events);
        }
      } else {
        // Create default semester if it doesn't exist
        await _firestore
            .collection('Students')
            .doc(userId)
            .collection('Courses-per-Semesters')
            .doc(_currentSemester)
            .set({
          'Semester Number': _student?.semester ?? 1,
        });
      }
    } catch (e) {
      _error = 'Error fetching events: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get all courses for the current semester
  Future<List<Map<String, dynamic>>> getCourses(String userId) async {
    try {
      final coursesSnapshot = await _firestore
          .collection('Students')
          .doc(userId)
          .collection('Courses-per-Semesters')
          .doc(_currentSemester)
          .collection('Courses')
          .get();
      
      return coursesSnapshot.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id; // Add document ID
        return data;
      }).toList();
    } catch (e) {
      _error = 'Error fetching courses: $e';
      notifyListeners();
      return [];
    }
  }

  // Calculate GPA based on courses
  Future<double> calculateGPA(String userId) async {
    try {
      double totalPoints = 0;
      double totalCredits = 0;
      
      // Get all semesters
      final semestersSnapshot = await _firestore
          .collection('Students')
          .doc(userId)
          .collection('Courses-per-Semesters')
          .get();
      
      for (var semesterDoc in semestersSnapshot.docs) {
        final coursesSnapshot = await _firestore
            .collection('Students')
            .doc(userId)
            .collection('Courses-per-Semesters')
            .doc(semesterDoc.id)
            .collection('Courses')
            .where('Status', isEqualTo: 'Completed')  // Only count completed courses
            .get();
        
        for (var courseDoc in coursesSnapshot.docs) {
          final courseData = courseDoc.data();
          final credits = courseData['Credits'] ?? 0;
          final grade = courseData['Final_grade'] ?? 0;
          
          if (grade > 0) {  // Only count courses with grades
            totalPoints += credits * grade;
            totalCredits += credits;
          }
        }
      }
      
      if (totalCredits == 0) return 0;
      return totalPoints / totalCredits;
    } catch (e) {
      _error = 'Error calculating GPA: $e';
      notifyListeners();
      return 0;
    }
  }

  // Helper to parse time strings into events
  List<CalendarEventData> _parseTimeToEvents(
      String title, String timeString, DateTime baseDate, Color color, 
      String description, String courseId) {
    List<CalendarEventData> events = [];
    
    try {
      // Split by comma for multiple time slots
      final timeSlots = timeString.split(',');
      
      for (var slot in timeSlots) {
        slot = slot.trim();
        
        // Extract day and time
        final parts = slot.split(' ');
        if (parts.length < 2) continue;
        
        final day = parts[0].toLowerCase();
        final timePart = parts[1];
        
        // Parse time range
        final timeRange = timePart.split('-');
        if (timeRange.length < 2) continue;
        
        final startTimeParts = timeRange[0].split(':');
        final endTimeParts = timeRange[1].split(':');
        
        if (startTimeParts.length < 2 || endTimeParts.length < 2) continue;
        
        final startHour = int.tryParse(startTimeParts[0]) ?? 0;
        final startMinute = int.tryParse(startTimeParts[1]) ?? 0;
        final endHour = int.tryParse(endTimeParts[0]) ?? 0;
        final endMinute = int.tryParse(endTimeParts[1]) ?? 0;
        
        // Map day string to day of week (0 = Sunday, 1 = Monday, etc.)
        int dayOfWeek;
        switch (day) {
          case 'sunday': dayOfWeek = 0; break;
          case 'monday': dayOfWeek = 1; break;
          case 'tuesday': dayOfWeek = 2; break;
          case 'wednesday': dayOfWeek = 3; break;
          case 'thursday': dayOfWeek = 4; break;
          case 'friday': dayOfWeek = 5; break;
          case 'saturday': dayOfWeek = 6; break;
          default: continue; // Skip if day is invalid
        }
        
        // Calculate event date (find the next occurrence of this day)
        final eventDate = _findNextDayOfWeek(baseDate, dayOfWeek);
        
        // Create event with courseId stored in the event data
        events.add(CalendarEventData(
          date: eventDate,
          title: title,
          description: description,
          startTime: DateTime(
            eventDate.year, 
            eventDate.month, 
            eventDate.day, 
            startHour, 
            startMinute
          ),
          endTime: DateTime(
            eventDate.year, 
            eventDate.month, 
            eventDate.day, 
            endHour, 
            endMinute
          ),
          color: color,
          event: courseId, // Store the course ID in the event object for reference
        ));
      }
    } catch (e) {
      print('Error parsing time: $e');
    }
    
    return events;
  }

  // Helper to find the next occurrence of a day of week
  DateTime _findNextDayOfWeek(DateTime date, int dayOfWeek) {
    DateTime result = DateTime(date.year, date.month, date.day);
    int daysToAdd = (dayOfWeek - date.weekday) % 7;
    if (daysToAdd == 0) {
      daysToAdd = 7; // If today is the target day, get next week
    }
    return result.add(Duration(days: daysToAdd));
  }
}