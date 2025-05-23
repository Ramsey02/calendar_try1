import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/auth_provider.dart';
import 'providers/course_provider.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
      ],
      child: MaterialApp(
        title: 'DegreEZ',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    if (authProvider.isAuthenticated) {
      // Load courses when authenticated
      final courseProvider = Provider.of<CourseProvider>(context, listen: false);
      courseProvider.loadStudentCourses(authProvider.user!.uid);
      
      // Load current semester course data from GitHub
      if (authProvider.student != null) {
        String semester = authProvider.student!.currentSemester;
        // Convert "Winter 2024/25" to "2024_200" format
        String semesterCode = _convertToSemesterCode(semester);
        courseProvider.loadCourseData(semesterCode);
      }
      
      return HomePage();
    } else {
      return LoginPage();
    }
  }
  
  String _convertToSemesterCode(String semester) {
    // Extract year and season from "Winter 2024/25" format
    if (semester.contains('Winter')) {
      String year = semester.split(' ')[1].split('/')[0];
      return '${year}_200';
    } else if (semester.contains('Spring')) {
      String year = semester.split(' ')[1].split('/')[0];
      return '${year}_201';
    }
    return '2024_200'; // Default
  }
}