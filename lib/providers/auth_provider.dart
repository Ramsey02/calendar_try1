import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _user;
  Student? _student;
  bool _isLoading = false;

  User? get user => _user;
  Student? get student => _student;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        _loadStudentData();
      } else {
        _student = null;
      }
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String major,
    required String faculty,
    required String preferences,
    required String semester,
    required String catalog,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Create user account
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create student document
      if (userCredential.user != null) {
        Student newStudent = Student(
          id: userCredential.user!.uid,
          name: name,
          major: major,
          faculty: faculty,
          preferences: preferences,
          currentSemester: semester,
          catalog: catalog,
        );
        
        await _firestore
            .collection('Students')
            .doc(userCredential.user!.uid)
            .set(newStudent.toFirestore());
        
        _student = newStudent;
      }
    } catch (e) {
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadStudentData() async {
    if (_user == null) return;
    
    try {
      DocumentSnapshot doc = await _firestore
          .collection('Students')
          .doc(_user!.uid)
          .get();
      
      if (doc.exists) {
        _student = Student.fromFirestore(doc);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading student data: $e');
    }
  }

  Future<void> updateProfile(Student updatedStudent) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _firestore
          .collection('Students')
          .doc(_user!.uid)
          .update(updatedStudent.toFirestore());
      
      _student = updatedStudent;
    } catch (e) {
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _student = null;
    notifyListeners();
  }
}