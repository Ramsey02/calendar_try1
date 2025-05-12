import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sample profile data - replace with actual user data
    final Map<String, dynamic> userProfile = {
      'name': 'John Doe',
      'major': 'cyber security',
      'gpa': 90.0,
      'faculty': 'Computer Science',
      'catalog': '2023-2024',
      'preferences': 'Dark theme, Calendar notifications enabled, Priority for math courses',
      'currentSemester': 2,
      'firstSemester': 'Fall 2023',
    };

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
                  userProfile['name'],
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  userProfile['major'],
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
                          color: _getGpaColor(userProfile['gpa']),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          userProfile['gpa'].toString(),
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
                      value: userProfile['gpa'] / 100.0, // Assuming 4.0 scale
                      minHeight: 10,
                      backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(_getGpaColor(userProfile['gpa'])),
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
                  _buildInfoRow(context, 'Faculty', userProfile['faculty'], Icons.school),
                  _buildInfoRow(context, 'Catalog', userProfile['catalog'], Icons.book),
                  _buildInfoRow(
                    context,
                    'Current Semester', 
                    'Semester ${userProfile['currentSemester']}', 
                    Icons.calendar_today
                  ),
                  _buildInfoRow(
                    context,
                    'First Semester', 
                    userProfile['firstSemester'], 
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
                      userProfile['preferences'],
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
                // Handle edit button press
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
    if (gpa >= 3.5) return Colors.green;
    if (gpa >= 3.0) return Colors.lightGreen;
    if (gpa >= 2.5) return Colors.amber;
    if (gpa >= 2.0) return Colors.orange;
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
    // Implement your edit profile dialog here
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
          content: Text(
            'Profile editing functionality coming soon!',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Close',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}