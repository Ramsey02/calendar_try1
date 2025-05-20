// models/student_model.dart
class StudentModel {
  final String id;
  final String name;
  final String major;
  final String faculty;
  final String preferences;
  final int semester;
  final String catalog;

  StudentModel({
    required this.id,
    required this.name,
    required this.major,
    required this.faculty,
    required this.preferences,
    required this.semester,
    required this.catalog,
  });

  factory StudentModel.fromFirestore(Map<String, dynamic> data) {
    return StudentModel(
      id: data['Id'] ?? '',
      name: data['Name'] ?? '',
      major: data['Major'] ?? '',
      faculty: data['Faculty'] ?? '',
      preferences: data['Preferences'] ?? '',
      semester: data['Semester'] ?? 1,
      catalog: data['Catalog'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'Id': id,
      'Name': name,
      'Major': major,
      'Faculty': faculty,
      'Preferences': preferences,
      'Semester': semester,
      'Catalog': catalog,
    };
  }
}