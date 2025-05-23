import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/course.dart';
import '../models/semester.dart';
import '../models/student.dart';

class CourseProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _githubBaseUrl = 'https://raw.githubusercontent.com/michael-maltsev/technion-sap-info-fetcher/gh-pages/';
  
  Map<String, List<Course>> _semesterCourses = {}; // semester ID -> courses
  Map<String, CourseInfo> _courseInfoCache = {}; // course ID -> course info from GitHub
  List<Semester> _semesters = [];
  bool _isLoading = false;
  String? _currentSemesterData;

  Map<String, List<Course>> get semesterCourses => _semesterCourses;
  List<Semester> get semesters => _semesters;
  bool get isLoading => _isLoading;

  // Load student's courses from Firestore
  Future<void> loadStudentCourses(String studentId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Get all semesters
      QuerySnapshot semesterSnapshot = await _firestore
          .collection('Students')
          .doc(studentId)
          .collection('Courses-per-Semesters')
          .orderBy('Semester Number')
          .get();

      _semesters.clear();
      _semesterCourses.clear();

      for (var semesterDoc in semesterSnapshot.docs) {
        String semesterId = semesterDoc.id;
        int semesterNumber = semesterDoc.data() is Map 
            ? (semesterDoc.data() as Map)['Semester Number'] ?? 0 
            : 0;

        // Get courses for this semester
        QuerySnapshot courseSnapshot = await semesterDoc.reference
            .collection('Courses')
            .get();

        List<Course> courses = courseSnapshot.docs
            .map((doc) => Course.fromFirestore(doc))
            .toList();

        _semesterCourses[semesterId] = courses;
        _semesters.add(Semester(
          id: semesterId,
          semesterNumber: semesterNumber,
          courses: courses,
        ));
      }
    } catch (e) {
      print('Error loading courses: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load course data from GitHub
  Future<void> loadCourseData(String semester) async {
    try {
      // Check cache first
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String cacheKey = 'courses_$semester';
      String? cachedData = prefs.getString(cacheKey);
      
      if (cachedData != null) {
        _currentSemesterData = cachedData;
        _parseCourseData(cachedData);
        return;
      }

      // Fetch from GitHub
      String url = '$_githubBaseUrl/courses_$semester.json';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        _currentSemesterData = response.body;
        await prefs.setString(cacheKey, response.body);
        _parseCourseData(response.body);
      }
    } catch (e) {
      print('Error loading course data from GitHub: $e');
    }
  }

  void _parseCourseData(String jsonData) {
    try {
      Map<String, dynamic> data = json.decode(jsonData);
      _courseInfoCache.clear();
      
      data.forEach((courseId, courseData) {
        if (courseData is Map<String, dynamic>) {
          _courseInfoCache[courseId] = CourseInfo.fromJson(courseData);
        }
      });
      
      notifyListeners();
    } catch (e) {
      print('Error parsing course data: $e');
    }
  }

  // Get course info from cache
  CourseInfo? getCourseInfo(String courseId) {
    return _courseInfoCache[courseId];
  }

  // Add course to student's semester
  Future<void> addCourse({
    required String studentId,
    required String semesterId,
    required Course course,
  }) async {
    try {
      // Check if semester exists, if not create it
      DocumentReference semesterRef = _firestore
          .collection('Students')
          .doc(studentId)
          .collection('Courses-per-Semesters')
          .doc(semesterId);
      
      DocumentSnapshot semesterDoc = await semesterRef.get();
      if (!semesterDoc.exists) {
        // Calculate semester number
        int semesterNumber = _semesters.length + 1;
        await semesterRef.set({'Semester Number': semesterNumber});
      }

      // Add course
      await semesterRef
          .collection('Courses')
          .doc(course.courseId)
          .set(course.toFirestore());

      // Update local data
      if (_semesterCourses[semesterId] == null) {
        _semesterCourses[semesterId] = [];
      }
      _semesterCourses[semesterId]!.add(course);
      
      notifyListeners();
    } catch (e) {
      print('Error adding course: $e');
      throw e;
    }
  }

  // Update course grade
  Future<void> updateCourseGrade({
    required String studentId,
    required String semesterId,
    required String courseId,
    required String grade,
  }) async {
    try {
      await _firestore
          .collection('Students')
          .doc(studentId)
          .collection('Courses-per-Semesters')
          .doc(semesterId)
          .collection('Courses')
          .doc(courseId)
          .update({'Final_grade': grade});

      // Update local data
      var courses = _semesterCourses[semesterId];
      if (courses != null) {
        int index = courses.indexWhere((c) => c.courseId == courseId);
        if (index != -1) {
          courses[index] = Course(
            courseId: courses[index].courseId,
            name: courses[index].name,
            finalGrade: grade,
            lectureTime: courses[index].lectureTime,
            tutorialTime: courses[index].tutorialTime,
            status: CourseStatus.completed,
          );
        }
      }
      
      notifyListeners();
    } catch (e) {
      print('Error updating grade: $e');
      throw e;
    }
  }

  // Calculate overall GPA
  double calculateOverallGPA() {
    double totalPoints = 0;
    int totalCourses = 0;
    
    _semesterCourses.forEach((semesterId, courses) {
      for (var course in courses) {
        if (course.finalGrade != null) {
          try {
            double grade = double.parse(course.finalGrade!);
            totalPoints += grade;
            totalCourses++;
          } catch (e) {
            // Handle non-numeric grades
          }
        }
      }
    });
    
    return totalCourses > 0 ? totalPoints / totalCourses : 0.0;
  }

  // Search courses
  List<CourseInfo> searchCourses(String query) {
    if (query.isEmpty) return [];
    
    query = query.toLowerCase();
    return _courseInfoCache.values
        .where((course) =>
            course.courseId.toLowerCase().contains(query) ||
            course.name.toLowerCase().contains(query))
        .toList();
  }
}