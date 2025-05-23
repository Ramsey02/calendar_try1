// services/event_service.dart
import 'dart:async'; // Added import for StreamSubscription
import 'package:calendar_view/calendar_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EventController _eventController;
  
  // Firestore listener subscription
  StreamSubscription<QuerySnapshot>? _courseSubscription;
  
  // Cache of event mappings (courseId -> List of identifiers)
  // We'll use event.title + start time as a unique identifier
  final Map<String, List<String>> _courseEventMap = {};
  
  EventService({required EventController eventController}) 
      : _eventController = eventController;
      
  // Get the event controller
  EventController get eventController => _eventController;
  
  // Dispose method to clean up resources
  void dispose() {
    _courseSubscription?.cancel();
  }
  
  // Setup real-time event synchronization
  Stream<String> setupEventSync(String userId, String currentSemester) {
    if (userId.isEmpty) {
      return Stream.value('User ID is empty');
    }
    
    // Clear existing events - fix for clearAll not existing
    _eventController.allEvents.clear(); // Use allEvents instead of events
    _courseEventMap.clear();
    
    // Cancel existing subscription
    _courseSubscription?.cancel();
    
    // Create a controller to emit errors
    final errorController = StreamController<String>();
    
    try {
      // First, ensure semester document exists
      _firestore
          .collection('Students')
          .doc(userId)
          .collection('Courses-per-Semesters')
          .doc(currentSemester)
          .get()
          .then((semesterDoc) async {
        // If semester doc doesn't exist, create it
        if (!semesterDoc.exists) {
          try {
            await _firestore
                .collection('Students')
                .doc(userId)
                .collection('Courses-per-Semesters')
                .doc(currentSemester)
                .set({
              'Semester Number': 1,
              'Last Updated': FieldValue.serverTimestamp(),
            });
          } catch (e) {
            errorController.add('Failed to create semester document: $e');
          }
        }
        
        // Listen to courses collection changes
        _courseSubscription = _firestore
            .collection('Students')
            .doc(userId)
            .collection('Courses-per-Semesters')
            .doc(currentSemester)
            .collection('Courses')
            .snapshots()
            .listen(
          (snapshot) {
            _processCoursesSnapshot(snapshot);
          },
          onError: (error) {
            errorController.add('Error syncing events: $error');
          },
        );
      }).catchError((error) {
        errorController.add('Error checking semester document: $error');
      });
    } catch (e) {
      errorController.add('Error setting up event sync: $e');
    }
    
    return errorController.stream;
  }
  
  // Process courses snapshot and update events
  void _processCoursesSnapshot(QuerySnapshot snapshot) {
    // Handle document changes
    for (var change in snapshot.docChanges) {
      final courseId = change.doc.id;
      final courseData = change.doc.data() as Map<String, dynamic>;
      
      switch (change.type) {
        case DocumentChangeType.added:
          _addCourseEvents(courseData, courseId);
          break;
        case DocumentChangeType.modified:
          _updateCourseEvents(courseData, courseId);
          break;
        case DocumentChangeType.removed:
          _removeCourseEvents(courseId);
          break;
      }
    }
  }
  
  // Generate a unique identifier for an event
  String _getEventIdentifier(CalendarEventData event) {
    // Combine title, start time and event data (courseId) to create a unique identifier
    return '${event.title}_${event.startTime.toString()}_${event.event}';
  }
  
  // Add events for a new course
  void _addCourseEvents(Map<String, dynamic> courseData, String courseId) {
    final events = _createEventsFromCourse(courseData, courseId);
    
    // Add events to controller
    _eventController.addAll(events);
    
    // Store event identifiers in map for future reference
    _courseEventMap[courseId] = events.map((e) => _getEventIdentifier(e)).toList();
  }
  
  // Update events for a modified course
  void _updateCourseEvents(Map<String, dynamic> courseData, String courseId) {
    // Remove existing events
    _removeCourseEvents(courseId);
    
    // Add new events
    _addCourseEvents(courseData, courseId);
  }
  
  // Remove events for a deleted course
  void _removeCourseEvents(String courseId) {
    // Get list of event identifiers for this course
    final eventIdentifiers = _courseEventMap[courseId] ?? [];
    
    // Remove each event
    if (eventIdentifiers.isNotEmpty) {
      // Create a copy of the events list to avoid modification during iteration
      final allEvents = List<CalendarEventData>.from(_eventController.allEvents);
      
      for (var event in allEvents) {
        String identifier = _getEventIdentifier(event);
        if (eventIdentifiers.contains(identifier)) {
          _eventController.remove(event);
        }
      }
    }
    
    // Remove from map
    _courseEventMap.remove(courseId);
  }
  
  // Create calendar events from course data
  List<CalendarEventData> _createEventsFromCourse(
      Map<String, dynamic> courseData, String courseId) {
    List<CalendarEventData> events = [];
    final courseName = courseData['Name'] ?? 'Unknown Course';
    final courseNumber = courseData['Course_Id'] ?? '';
    
    // Process lecture time events
    if (courseData['Lecture_time'] != null && 
        courseData['Lecture_time'].toString().isNotEmpty) {
      final lectureEvents = _parseTimeToEvents(
        courseName,
        courseData['Lecture_time'],
        Colors.blue.shade700,
        '$courseNumber - Lecture',
        courseId,
        'lecture',
      );
      events.addAll(lectureEvents);
    }
    
    // Process tutorial time events
    if (courseData['Tutorial_time'] != null && 
        courseData['Tutorial_time'].toString().isNotEmpty) {
      final tutorialEvents = _parseTimeToEvents(
        courseName,
        courseData['Tutorial_time'],
        Colors.green.shade700,
        '$courseNumber - Tutorial',
        courseId,
        'tutorial',
      );
      events.addAll(tutorialEvents);
    }
    
    return events;
  }
  
  // Parse time strings to calendar events
  List<CalendarEventData> _parseTimeToEvents(
      String title, 
      String timeString, 
      Color color, 
      String description, 
      String courseId,
      String type) {
    List<CalendarEventData> events = [];
    final now = DateTime.now();
    
    try {
      // Split by comma for multiple time slots
      final timeSlots = timeString.split(',');
      
      for (var i = 0; i < timeSlots.length; i++) {
        var slot = timeSlots[i].trim();
        
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
        final eventDate = _findNextDayOfWeek(now, dayOfWeek);
        
        // Create event
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
          event: courseId, // Store course ID for reference
        ));
      }
    } catch (e) {
      // Use a logging framework instead of print in production
      debugPrint('Error parsing time: $e');
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