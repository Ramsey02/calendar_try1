import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String id;
  final String name;
  final String major;
  final String faculty;
  final String preferences;
  final String currentSemester;
  final String catalog;

  Student({
    required this.id,
    required this.name,
    required this.major,
    required this.faculty,
    required this.preferences,
    required this.currentSemester,
    required this.catalog,
  });

  factory Student.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Student(
      id: doc.id,
      name: data['Name'] ?? '',
      major: data['Major'] ?? '',
      faculty: data['Faculty'] ?? '',
      preferences: data['Preferences'] ?? '',
      currentSemester: data['Semester'] ?? '',
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
      'Semester': currentSemester,
      'Catalog': catalog,
    };
  }

  Student copyWith({
    String? id,
    String? name,
    String? major,
    String? faculty,
    String? preferences,
    String? currentSemester,
    String? catalog,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      major: major ?? this.major,
      faculty: faculty ?? this.faculty,
      preferences: preferences ?? this.preferences,
      currentSemester: currentSemester ?? this.currentSemester,
      catalog: catalog ?? this.catalog,
    );
  }
}