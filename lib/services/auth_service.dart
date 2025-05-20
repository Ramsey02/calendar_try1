// services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  // Register with email and password
  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create initial student profile
      await _createInitialStudentProfile(userCredential.user!.uid, email);
      
      return userCredential;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  // Create initial student profile
  Future<void> _createInitialStudentProfile(String userId, String email) async {
    try {
      // Extract name from email (as a placeholder)
      final name = email.split('@')[0];
      
      // Create basic student model
      final student = StudentModel(
        id: userId,
        name: name,
        major: 'Not specified',
        faculty: 'Not specified',
        preferences: '',
        semester: 1,
        catalog: 'Default Catalog',
      );
      
      // Save to Firestore
      await _firestore.collection('Students').doc(userId).set(student.toFirestore());
      
      // Create default semester document
      await _firestore
          .collection('Students')
          .doc(userId)
          .collection('Courses-per-Semesters')
          .doc('Winter 2024/25')
          .set({
        'Semester Number': 1,
      });
    } catch (e) {
      print('Error creating initial student profile: $e');
      // We'll continue anyway since the auth was successful
    }
  }
  
  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  // Helper to handle Firebase auth exceptions with user-friendly messages
  Exception _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return Exception('No user found with this email address.');
        case 'wrong-password':
          return Exception('Incorrect password. Please try again.');
        case 'email-already-in-use':
          return Exception('This email is already registered.');
        case 'weak-password':
          return Exception('Password is too weak. Please use a stronger password.');
        case 'invalid-email':
          return Exception('The email address is invalid.');
        case 'user-disabled':
          return Exception('This user account has been disabled.');
        case 'too-many-requests':
          return Exception('Too many login attempts. Please try again later.');
        case 'operation-not-allowed':
          return Exception('This operation is not allowed.');
        default:
          return Exception('Authentication error: ${e.message}');
      }
    }
    return Exception('An unexpected error occurred: $e');
  }
}