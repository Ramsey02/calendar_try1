import 'course.dart';

class Semester {
  final String id; // e.g., "Winter 2024/25"
  final int semesterNumber;
  final List<Course> courses;

  Semester({
    required this.id,
    required this.semesterNumber,
    required this.courses,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'Semester Number': semesterNumber,
    };
  }

  double calculateGPA() {
    if (courses.isEmpty) return 0.0;
    
    double totalPoints = 0;
    int totalCourses = 0;
    
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
    
    return totalCourses > 0 ? totalPoints / totalCourses : 0.0;
  }
}