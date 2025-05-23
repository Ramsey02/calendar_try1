import 'package:flutter/material.dart';
import 'registration_page.dart'; // Add this import
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo and App name
                  Column(
                    children: [
                      // App Logo
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 1,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'lib/pages/login.png',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // App Name
                      Text(
                        'DegreEZ',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onBackground,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your academic journey made easy',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 36),
                  
                  // Login Card
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Theme.of(context).colorScheme.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          Text(
                            'Sign in with your Google account to continue',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Gmail Sign-In button
                          ElevatedButton.icon(
                            onPressed: () {
                              // For UI only - no functionality
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black87,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Colors.grey, width: 1),
                              ),
                              elevation: 2,
                            ),
                            icon: Icon(
                              Icons.email,
                              color: Colors.red,
                            ),
                            label: Text(
                              'Sign in with Gmail',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Help text
                          Text(
                            'We only use your Gmail account for authentication purposes.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(height: 24), // Add some spacing

// TextButton to navigate to Registration Page
TextButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegistrationPage()), // Make sure RegistrationPage is imported
    );
  },
  child: Text(
    'Don\'t have an account? Register here',
    style: TextStyle(
      color: Theme.of(context).colorScheme.secondary, // Or your preferred color
      fontWeight: FontWeight.w600,
    ),
  ),
),

const SizedBox(height: 16), // Existing help text spacing
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}