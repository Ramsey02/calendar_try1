// pages/profile_page.dart
import 'package:calendar_try1/models/student_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import '../services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  bool _isEditing = false;
  
  // Controllers for editing
  late TextEditingController _nameController;
  late TextEditingController _majorController;
  late TextEditingController _facultyController;
  late TextEditingController _preferencesController;
  late TextEditingController _semesterController;
  late TextEditingController _catalogController;
  
  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _majorController.dispose();
    _facultyController.dispose();
    _preferencesController.dispose();
    _semesterController.dispose();
    _catalogController.dispose();
    super.dispose();
  }
  
  void _initializeControllers() {
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    final student = studentProvider.student;
    
    _nameController = TextEditingController(text: student?.name ?? '');
    _majorController = TextEditingController(text: student?.major ?? '');
    _facultyController = TextEditingController(text: student?.faculty ?? '');
    _preferencesController = TextEditingController(text: student?.preferences ?? '');
    _semesterController = TextEditingController(text: student?.semester.toString() ?? '1');
    _catalogController = TextEditingController(text: student?.catalog ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    final student = studentProvider.student;
    final isLoading = studentProvider.isLoading;
    
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    if (student == null) {
      return _buildEmptyProfile();
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _isEditing 
              ? _buildEditForm() 
              : _buildProfileDetails(student),
          const SizedBox(height: 24),
          _buildActionButtons(),
          const SizedBox(height: 16),
          _buildSemesterInfo(studentProvider),
        ],
      ),
    );
  }
  
  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            child: Icon(
              Icons.person,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Student Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your academic information',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProfileDetails(student) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('ID', student.id),
            const Divider(),
            _buildDetailRow('Name', student.name),
            const Divider(),
            _buildDetailRow('Major', student.major),
            const Divider(),
            _buildDetailRow('Faculty', student.faculty),
            const Divider(),
            _buildDetailRow('Preferences', student.preferences),
            const Divider(),
            _buildDetailRow('Current Semester', student.semester.toString()),
            const Divider(),
            _buildDetailRow('Catalog', student.catalog),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'Not specified',
              style: value.isEmpty 
                  ? TextStyle(fontStyle: FontStyle.italic, color: Colors.grey) 
                  : null,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEditForm() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(_nameController, 'Name'),
            _buildTextField(_majorController, 'Major'),
            _buildTextField(_facultyController, 'Faculty'),
            _buildTextField(_preferencesController, 'Preferences'),
            _buildTextField(_semesterController, 'Current Semester', 
                keyboardType: TextInputType.number),
            _buildTextField(_catalogController, 'Catalog'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTextField(
      TextEditingController controller, String label, 
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
      ),
    );
  }
  
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (_isEditing) ...[
          TextButton(
            onPressed: _cancelEdit,
            child: Text('Cancel'),
          ),
          SizedBox(width: 8),
          ElevatedButton(
            onPressed: _saveProfile,
            child: Text('Save'),
          ),
        ] else ...[
          ElevatedButton(
            onPressed: _startEditing,
            child: Text('Edit Profile'),
          ),
        ],
      ],
    );
  }
  
  Widget _buildSemesterInfo(StudentProvider studentProvider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Active Semester',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    studentProvider.currentSemester,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _changeSemester(studentProvider),
                ),
              ],
            ),
            FutureBuilder<double>(
              future: _calculateGPA(studentProvider),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                
                final gpa = snapshot.data ?? 0.0;
                
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Current GPA: ${gpa.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Future<double> _calculateGPA(StudentProvider studentProvider) async {
    return studentProvider.calculateGPA(_authService.currentUser?.uid ?? '');
  }
  
  Widget _buildEmptyProfile() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No profile found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Please create a profile to get started',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _createNewProfile,
            child: Text('Create Profile'),
          ),
        ],
      ),
    );
  }
  
  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
  }
  
  void _cancelEdit() {
    _initializeControllers(); // Reset controllers to current values
    setState(() {
      _isEditing = false;
    });
  }
  
  void _saveProfile() async {
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    final userId = _authService.currentUser?.uid ?? '';
    
    // Validate inputs
    final semesterValue = int.tryParse(_semesterController.text);
    if (semesterValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Semester must be a number')),
      );
      return;
    }
    
    // Create updated data
    Map<String, dynamic> updatedData = {
      'Name': _nameController.text,
      'Major': _majorController.text,
      'Faculty': _facultyController.text,
      'Preferences': _preferencesController.text,
      'Semester': semesterValue,
      'Catalog': _catalogController.text,
    };
    
    try {
      await studentProvider.updateStudentProfile(userId, updatedData);
      setState(() {
        _isEditing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }
  
  void _createNewProfile() async {
    // Show a dialog to get basic info
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        final majorController = TextEditingController();
        final facultyController = TextEditingController();
        
        return AlertDialog(
          title: Text('Create Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name*',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: majorController,
                  decoration: InputDecoration(
                    labelText: 'Major*',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: facultyController,
                  decoration: InputDecoration(
                    labelText: 'Faculty*',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || 
                    majorController.text.isEmpty || 
                    facultyController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all required fields')),
                  );
                  return;
                }
                
                final studentProvider = 
                    Provider.of<StudentProvider>(context, listen: false);
                final userId = _authService.currentUser?.uid ?? '';
                
                // Create student model
                final student = createStudentModel(
                  userId,
                  nameController.text,
                  majorController.text,
                  facultyController.text,
                );
                
                await studentProvider.createStudentProfile(userId, student);
                Navigator.pop(context);
                
                // Refresh controllers with new data
                _initializeControllers();
                setState(() {});
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );
  }
  
  // Helper to create a student model with default values
  createStudentModel(String id, String name, String major, String faculty) {
    return StudentModel(
      id: id,
      name: name,
      major: major,
      faculty: faculty,
      preferences: '',
      semester: 1,
      catalog: 'Default Catalog 2024/25',
    );
  }
  
  void _changeSemester(StudentProvider studentProvider) {
    // Show semester selection dialog
    showDialog(
      context: context,
      builder: (context) {
        final semesters = [
          'Winter 2024/25',
          'Spring 2024/25',
          'Winter 2023/24',
          'Spring 2023/24',
        ];
        
        return AlertDialog(
          title: Text('Select Semester'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: semesters.length,
              itemBuilder: (context, index) {
                final semester = semesters[index];
                final isSelected = semester == studentProvider.currentSemester;
                
                return ListTile(
                  title: Text(semester),
                  trailing: isSelected ? Icon(Icons.check) : null,
                  onTap: () {
                    studentProvider.setCurrentSemester(semester);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}