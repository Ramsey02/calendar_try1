import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/student_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;
  Map<String, dynamic> _userData = {};
  String _userId = 'user123'; // Replace with actual user ID from auth

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('Students')
          .doc(_userId)
          .get();

      if (docSnapshot.exists) {
        setState(() {
          _userData = docSnapshot.data() as Map<String, dynamic>;
        });
      } else {
        // Create a default profile if none exists
        final defaultProfile = {
          'Id': _userId,
          'Name': 'New User',
          'Major': 'Select Major',
          'Faculty': 'Select Faculty',
          'GPA': 0.0,
          'Semester': 1,
          'Catalog': '2024-2025',
          'Preferences': 'Default preferences',
          'FirstSemester': 'Fall 2024',
        };
        
        await FirebaseFirestore.instance
            .collection('Students')
            .doc(_userId)
            .set(defaultProfile);
            
        setState(() {
          _userData = defaultProfile;
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
      // Show error message if needed
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header with Avatar and Name
          Center(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.secondary,
                      width: 4.0,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    child: Icon(
                      Icons.person,
                      size: 80,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _userData['Name'] ?? 'User',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  _userData['Major'] ?? 'No Major Selected',
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // GPA Card with visual indicator
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Theme.of(context).colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current GPA',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getGpaColor(_userData['GPA'] ?? 0.0),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          (_userData['GPA'] ?? 0.0).toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (_userData['GPA'] ?? 0.0) / 100.0, // Assuming 100 scale
                      minHeight: 10,
                      backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(_getGpaColor(_userData['GPA'] ?? 0.0)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Academic Info Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Theme.of(context).colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Academic Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const Divider(),
                  _buildInfoRow(context, 'Faculty', _userData['Faculty'] ?? 'Not Set', Icons.school),
                  _buildInfoRow(context, 'Catalog', _userData['Catalog'] ?? 'Not Set', Icons.book),
                  _buildInfoRow(
                    context,
                    'Current Semester', 
                    'Semester ${_userData['Semester'] ?? 1}', 
                    Icons.calendar_today
                  ),
                  _buildInfoRow(
                    context,
                    'First Semester', 
                    _userData['FirstSemester'] ?? 'Not Set', 
                    Icons.calendar_month
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Preferences Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Theme.of(context).colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preferences',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      _userData['Preferences'] ?? 'No preferences set',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Edit Profile Button
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                _showEditProfileDialog(context);
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Helper method for GPA color
  Color _getGpaColor(double gpa) {
    if (gpa >= 85) return Colors.green;
    if (gpa >= 75) return Colors.lightGreen;
    if (gpa >= 65) return Colors.amber;
    if (gpa >= 55) return Colors.orange;
    return Colors.red;
  }

  // Helper method to build info rows
  Widget _buildInfoRow(BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Dialog to edit profile
  void _showEditProfileDialog(BuildContext context) {
    // Create controllers for each field
    final nameController = TextEditingController(text: _userData['Name']);
    final majorController = TextEditingController(text: _userData['Major']);
    final facultyController = TextEditingController(text: _userData['Faculty']);
    final catalogController = TextEditingController(text: _userData['Catalog']);
    final semesterController = TextEditingController(text: _userData['Semester'].toString());
    final preferencesController = TextEditingController(text: _userData['Preferences']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            'Edit Profile',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: majorController,
                  decoration: const InputDecoration(labelText: 'Major'),
                ),
                TextField(
                  controller: facultyController,
                  decoration: const InputDecoration(labelText: 'Faculty'),
                ),
                TextField(
                  controller: catalogController,
                  decoration: const InputDecoration(labelText: 'Catalog'),
                ),
                TextField(
                  controller: semesterController,
                  decoration: const InputDecoration(labelText: 'Current Semester'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: preferencesController,
                  decoration: const InputDecoration(labelText: 'Preferences'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Update Firestore with new values
                try {
                  await FirebaseFirestore.instance
                      .collection('Students')
                      .doc(_userId)
                      .update({
                    'Name': nameController.text,
                    'Major': majorController.text,
                    'Faculty': facultyController.text,
                    'Catalog': catalogController.text,
                    'Semester': int.tryParse(semesterController.text) ?? 1,
                    'Preferences': preferencesController.text,
                  });
                  
                  // Refresh data
                  Navigator.of(context).pop();
                  _fetchUserData();
                } catch (e) {
                  print('Error updating profile: $e');
                  // Show error message
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}