import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:calendar_view/calendar_view.dart'; // <-- Add this import
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
      child: CalendarControllerProvider(
        controller: EventController(), // <-- Provide the controller here
        child: MaterialApp(
          title: 'DegreEZ',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: AuthWrapper(),
        ),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated) {
        final courseProvider = Provider.of<CourseProvider>(context, listen: false);
        courseProvider.loadStudentCourses(authProvider.user!.uid);
        if (authProvider.student != null) {
          String semester = authProvider.student!.currentSemester;
          String semesterCode = _convertToSemesterCode(semester);
          courseProvider.loadCourseData(semesterCode);
        }
      }
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    if (authProvider.isAuthenticated) {
      return HomePage();
    } else {
      return LoginPage();
    }
  }

  String _convertToSemesterCode(String semester) {
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