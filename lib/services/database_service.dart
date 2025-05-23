// services/database_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Constructor - initialize Firestore settings
  DatabaseService() {
    _firestore.settings = Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }
  
  // Get Firestore instance
  FirebaseFirestore get firestore => _firestore;
  
  // Check if student exists
  Future<bool> studentExists(String userId) async {
    try {
      final docSnapshot = await _firestore
          .collection('Students')
          .doc(userId)
          .get();
      return docSnapshot.exists;
    } catch (e) {
      print('Error checking if student exists: $e');
      return false;
    }
  }
  
  // Transaction to batch update multiple courses
  Future<bool> batchUpdateCourses(String userId, String semester, 
      Map<String, Map<String, dynamic>> courseUpdates) async {
    try {
      return await _firestore.runTransaction<bool>((transaction) async {
        // Create a batch for optimized write operations
        WriteBatch batch = _firestore.batch();
        
        // Add each course update to the batch
        courseUpdates.forEach((courseId, data) {
          final docRef = _firestore
              .collection('Students')
              .doc(userId)
              .collection('Courses-per-Semesters')
              .doc(semester)
              .collection('Courses')
              .doc(courseId);
              
          batch.update(docRef, data);
        });
        
        // Commit the batch
        await batch.commit();
        return true;
      });
    } catch (e) {
      print('Error in batch update courses: $e');
      return false;
    }
  }
  
  // Get all courses for a student (across all semesters)
  Future<Map<String, List<Map<String, dynamic>>>> getAllCourses(String userId) async {
    try {
      // Get all semesters
      final semestersSnapshot = await _firestore
          .collection('Students')
          .doc(userId)
          .collection('Courses-per-Semesters')
          .get();
          
      Map<String, List<Map<String, dynamic>>> result = {};
      
      // For each semester, get courses
      for (var semesterDoc in semestersSnapshot.docs) {
        final semesterName = semesterDoc.id;
        
        final coursesSnapshot = await _firestore
            .collection('Students')
            .doc(userId)
            .collection('Courses-per-Semesters')
            .doc(semesterName)
            .collection('Courses')
            .get();
            
        result[semesterName] = coursesSnapshot.docs.map((doc) {
          var data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      }
      
      return result;
    } catch (e) {
      print('Error getting all courses: $e');
      return {};
    }
  }
  
  // Optimized GPA calculation
  Future<double> calculateGPA(String userId) async {
    try {
      double totalPoints = 0;
      double totalCredits = 0;
      
      // Get all completed courses across all semesters
      final coursesQuery = _firestore
          .collectionGroup('Courses')
          .where('Status', isEqualTo: 'Completed');
          
      // Execute query
      final coursesSnapshot = await coursesQuery.get();
      
      // Process results
      for (var doc in coursesSnapshot.docs) {
        // Make sure this course belongs to the right student
        // (collection group queries span all documents of this type)
        final path = doc.reference.path;
        if (!path.contains('/Students/$userId/')) continue;
        
        final data = doc.data();
        final credits = data['Credits'] ?? 0;
        final grade = data['Final_grade'] ?? 0;
        
        if (grade > 0) {
          totalPoints += credits * grade;
          totalCredits += credits;
        }
      }
      
      if (totalCredits == 0) return 0;
      return totalPoints / totalCredits;
    } catch (e) {
      print('Error calculating GPA: $e');
      return 0;
    }
  }
}