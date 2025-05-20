// providers/student_provider.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_model.dart';

class StudentProvider with ChangeNotifier {
  StudentModel? _student;
  bool _isLoading = false;
  String _error = '';

  StudentModel? get student => _student;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Fetch student data from Firestore
  Future<void> fetchStudentData(String userId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('Students')
          .doc(userId)
          .get();

      if (docSnapshot.exists) {
        _student = StudentModel.fromFirestore(
            docSnapshot.data() as Map<String, dynamic>);
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
}