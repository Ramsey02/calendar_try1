import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../pages/login_page.dart';
import '../pages/home_page.dart';

class AuthWrapper extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // If user is logged in
        if (snapshot.hasData && snapshot.data != null) {
          return const HomePage();
        }
        
        // If user is not logged in
        return const LoginPage();
      },
    );
  }
}