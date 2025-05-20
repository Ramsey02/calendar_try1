// services/course_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';

class CourseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all courses for a student in the current semester
  Future<List<CalendarEventData>> getStudentCoursesAsEvents(
      String userId, String currentSemester) async {
    List<CalendarEventData> events = [];

    try {
      final coursesSnapshot = await _firestore
          .collection('Students')
          .doc(userId)
          .collection('Courses-per-Semesters')
          .doc(currentSemester)
          .collection('Courses')
          .get();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      for (var doc in coursesSnapshot.docs) {
        final courseData = doc.data();
        
        // Parse lecture times and add events
        if (courseData['Lecture_time'] != null) {
          final lectureEvents = _parseTimeToEvents(
            courseData['Name'],
            courseData['Lecture_time'],
            today,
            Colors.blue.shade700,
            '${courseData['Course_Id']} - Lecture',
          );
          events.addAll(lectureEvents);
        }

        // Parse tutorial times and add events
        if (courseData['Tutorial_time'] != null) {
          final tutorialEvents = _parseTimeToEvents(
            courseData['Name'],
            courseData['Tutorial_time'],
            today,
            Colors.green.shade700,
            '${courseData['Course_Id']} - Tutorial',
          );
          events.addAll(tutorialEvents);
        }
      }
    } catch (e) {
      print('Error getting courses: $e');
    }

    return events;
  }

  // Helper method to parse time strings into calendar events
  // This is a placeholder - you'll need to implement your own parsing logic
  List<CalendarEventData> _parseTimeToEvents(
      String title, String timeString, DateTime baseDate, Color color, String description) {
    // Implement your parsing logic here
    // Example: "Monday 10:00-12:00" should be parsed into a calendar event
    
    // Placeholder implementation
    return [
      CalendarEventData(
        date: baseDate,
        title: title,
        description: description,
        startTime: DateTime(baseDate.year, baseDate.month, baseDate.day, 10, 0),
        endTime: DateTime(baseDate.year, baseDate.month, baseDate.day, 12, 0),
        color: color,
      ),
    ];
  }
}