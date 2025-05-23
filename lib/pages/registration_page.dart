import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _majorController = TextEditingController();
  
  String? _selectedFaculty;
  String? _selectedSemester;
  String? _selectedCatalog;
  String _preferences = '';
  
  final List<String> _faculties = [
    'הפקולטה למדעי המחשב',
    'הפקולטה להנדסת חשמל',
    'הפקולטה להנדסת מכונות',
    'הפקולטה להנדסה אזרחית וסביבתית',
    'הפקולטה להנדסה כימית',
    'הפקולטה להנדסת חומרים',
    'הפקולטה להנדסה ביורפואית',
    'הפקולטה להנדסת תעשייה וניהול',
    'הפקולטה למתמטיקה',
    'הפקולטה לפיזיקה',
    'הפקולטה לכימיה',
    'הפקולטה לביולוגיה',
  ];
  
  final List<String> _semesters = [
    'Winter 2024/25',
    'Spring 2024/25',
    'Winter 2025/26',
    'Spring 2025/26',
  ];
  
  final List<String> _catalogs = [
    'Catalog 2024-2025',
    'Catalog 2023-2024',
    'Catalog 2022-2023',
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _majorController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
          major: _majorController.text.trim(),
          faculty: _selectedFaculty!,
          preferences: _preferences,
          semester: _selectedSemester!,
          catalog: _selectedCatalog!,
        );
        
        Navigator.of(context).pop(); // Go back to login
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Account'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: authProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Join DegreEZ',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30),
                    
                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    // Faculty Dropdown
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Faculty',
                        prefixIcon: Icon(Icons.school),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      value: _selectedFaculty,
                      items: _faculties.map((faculty) {
                        return DropdownMenuItem(
                          value: faculty,
                          child: Text(faculty),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedFaculty = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select your faculty';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    // Major Field
                    TextFormField(
                      controller: _majorController,
                      decoration: InputDecoration(
                        labelText: 'Major',
                        prefixIcon: Icon(Icons.book),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your major';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    // Current Semester Dropdown
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Current Semester',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      value: _selectedSemester,
                      items: _semesters.map((semester) {
                        return DropdownMenuItem(
                          value: semester,
                          child: Text(semester),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSemester = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select your current semester';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    // Catalog Dropdown
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Academic Catalog',
                        prefixIcon: Icon(Icons.menu_book),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      value: _selectedCatalog,
                      items: _catalogs.map((catalog) {
                        return DropdownMenuItem(
                          value: catalog,
                          child: Text(catalog),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCatalog = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select your catalog year';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    // Preferences Field
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Academic Preferences (optional)',
                        prefixIcon: Icon(Icons.favorite),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hintText: 'e.g., AI, Machine Learning, Cybersecurity',
                      ),
                      maxLines: 2,
                      onChanged: (value) {
                        _preferences = value;
                      },
                    ),
                    SizedBox(height: 30),
                    
                    // Register Button
                    ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade800,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Create Account',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}