import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  final String courseId;
  final String name;
  final String? finalGrade;
  final String? lectureTime;
  final String? tutorialTime;
  final CourseStatus status;

  Course({
    required this.courseId,
    required this.name,
    this.finalGrade,
    this.lectureTime,
    this.tutorialTime,
    this.status = CourseStatus.planned,
  });

  factory Course.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Course(
      courseId: data['Course_Id'] ?? '',
      name: data['Name'] ?? '',
      finalGrade: data['Final_grade'],
      lectureTime: data['Lecture_time'],
      tutorialTime: data['Tutorial_time'],
      status: _parseStatus(data['status']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'Course_Id': courseId,
      'Name': name,
      'Final_grade': finalGrade,
      'Lecture_time': lectureTime,
      'Tutorial_time': tutorialTime,
      'status': status.toString().split('.').last,
    };
  }

  static CourseStatus _parseStatus(String? status) {
    switch (status) {
      case 'completed':
        return CourseStatus.completed;
      case 'inProgress':
        return CourseStatus.inProgress;
      case 'planned':
      default:
        return CourseStatus.planned;
    }
  }
}

enum CourseStatus { completed, inProgress, planned }

// Model for courses from GitHub repository
class CourseInfo {
  final String courseId;
  final String name;
  final String syllabus;
  final String faculty;
  final String prerequisites;
  final String credits;
  final List<CourseSchedule> schedule;

  CourseInfo({
    required this.courseId,
    required this.name,
    required this.syllabus,
    required this.faculty,
    required this.prerequisites,
    required this.credits,
    required this.schedule,
  });

  factory CourseInfo.fromJson(Map<String, dynamic> json) {
    var general = json['general'] as Map<String, dynamic>;
    var scheduleList = json['schedule'] as List;
    
    return CourseInfo(
      courseId: general['מספר מקצוע'] ?? '',
      name: general['שם מקצוע'] ?? '',
      syllabus: general['סילבוס'] ?? '',
      faculty: general['פקולטה'] ?? '',
      prerequisites: general['מקצועות קדם'] ?? '',
      credits: general['נקודות'] ?? '',
      schedule: scheduleList.map((item) => CourseSchedule.fromJson(item)).toList(),
    );
  }
}

class CourseSchedule {
  final int group;
  final String type;
  final String day;
  final String time;
  final String building;
  final int room;
  final String instructor;

  CourseSchedule({
    required this.group,
    required this.type,
    required this.day,
    required this.time,
    required this.building,
    required this.room,
    required this.instructor,
  });

  factory CourseSchedule.fromJson(Map<String, dynamic> json) {
    return CourseSchedule(
      group: json['קבוצה'] ?? 0,
      type: json['סוג'] ?? '',
      day: json['יום'] ?? '',
      time: json['שעה'] ?? '',
      building: json['בניין'] ?? '',
      room: json['חדר'] ?? 0,
      instructor: json['מרצה/מתרגל'] ?? '',
    );
  }
}