// pages/semester_diagram.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import '../services/auth_service.dart';

class SemesterDiagram extends StatefulWidget {
  const SemesterDiagram({super.key});

  @override
  _SemesterDiagramState createState() => _SemesterDiagramState();
}

class _SemesterDiagramState extends State<SemesterDiagram> {
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _courses = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadCourses();
  }
  
  Future<void> _loadCourses() async {
    setState(() {
      _isLoading = true;
    });
    
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    final userId = _authService.currentUser?.uid ?? '';
    
    if (userId.isNotEmpty) {
      try {
        final courses = await studentProvider.getCourses(userId);
        setState(() {
          _courses = courses;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading courses: $e')),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    
    return Column(
      children: [
        _buildSemesterSelector(studentProvider),
        Expanded(
          child: _isLoading 
              ? Center(child: CircularProgressIndicator())
              : _courses.isEmpty
                  ? _buildEmptyState()
                  : _buildCourseDiagram(),
        ),
      ],
    );
  }
  
  Widget _buildSemesterSelector(StudentProvider studentProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Text(
            'Current Semester: ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => _changeSemester(studentProvider),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.primary),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      studentProvider.currentSemester,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadCourses,
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timeline_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No courses found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add courses to see your semester diagram',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate back to calendar to add courses
              Navigator.pop(context);
            },
            child: Text('Add Courses'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCourseDiagram() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Semester Courses Diagram',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            // Course cards in a grid
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: _courses.length,
              itemBuilder: (context, index) {
                final course = _courses[index];
                return _buildCourseCard(course);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCourseCard(Map<String, dynamic> course) {
    final Color cardColor = _getStatusColor(course['Status'] ?? 'Active');
    
    return Card(
      elevation: 3,
      color: cardColor.withOpacity(0.1),
      child: InkWell(
        onTap: () => _showCourseDetails(course),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: cardColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      course['Status'] ?? 'Active',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: cardColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                course['Name'] ?? 'Unknown Course',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                course['Course_Id'] ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              Spacer(),
              if (course['Final_grade'] != null && 
                  course['Final_grade'] is num && 
                  course['Status'] == 'Completed')
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Grade: ${course['Final_grade']}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'planned':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  void _showCourseDetails(Map<String, dynamic> course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course['Name'] ?? 'Unknown Course',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Course ID: ${course['Course_Id'] ?? 'N/A'}',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 16),
              _buildDetailItem('Status', course['Status'] ?? 'Active'),
              _buildDetailItem('Lecture Time', course['Lecture_time'] ?? 'Not specified'),
              _buildDetailItem('Tutorial Time', course['Tutorial_time'] ?? 'Not specified'),
              _buildDetailItem('Last Taken', course['Last_Semester_taken'] ?? 'Current semester'),
              _buildDetailItem('Final Grade', 
                course['Final_grade'] != null ? course['Final_grade'].toString() : 'Not graded'),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton.icon(
                    icon: Icon(Icons.edit),
                    label: Text('Edit Status'),
                    onPressed: () => _editCourseStatus(course),
                  ),
                  if (course['Status'] == 'Completed' || course['Status'] == 'Active')
                    OutlinedButton.icon(
                      icon: Icon(Icons.grade),
                      label: Text('Set Grade'),
                      onPressed: () => _setCourseGrade(course),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
  
  void _editCourseStatus(Map<String, dynamic> course) {
    final statusOptions = ['Active', 'Completed', 'Planned', 'Failed'];
    final courseId = course['id'];
    String selectedStatus = course['Status'] ?? 'Active';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Update Course Status'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: statusOptions.map((status) {
                return RadioListTile<String>(
                  title: Text(status),
                  value: status,
                  groupValue: selectedStatus,
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value!;
                    });
                  },
                );
              }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  
                  final studentProvider = 
                      Provider.of<StudentProvider>(context, listen: false);
                  final userId = _authService.currentUser?.uid ?? '';
                  
                  // Update course status
                  await studentProvider.updateCourse(
                    userId, 
                    courseId, 
                    {'Status': selectedStatus},
                  );
                  
                  // Refresh courses
                  _loadCourses();
                },
                child: Text('Update'),
              ),
            ],
          );
        },
      ),
    );
  }
  
  void _setCourseGrade(Map<String, dynamic> course) {
    final courseId = course['id'];
    final gradeController = TextEditingController(
      text: course['Final_grade'] != null ? course['Final_grade'].toString() : '',
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Course Grade'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: gradeController,
              decoration: InputDecoration(
                labelText: 'Grade (0-100)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 8),
            Text(
              'Enter the final grade for this course',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final grade = double.tryParse(gradeController.text);
              if (grade == null || grade < 0 || grade > 100) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter a valid grade (0-100)')),
                );
                return;
              }
              
              Navigator.pop(context);
              
              final studentProvider = 
                  Provider.of<StudentProvider>(context, listen: false);
              final userId = _authService.currentUser?.uid ?? '';
              
              // Update course grade
              Map<String, dynamic> updates = {
                'Final_grade': grade,
              };
              
              // Automatically set status to completed if grade is given
              if (course['Status'] != 'Completed') {
                updates['Status'] = 'Completed';
              }
              
              await studentProvider.updateCourse(userId, courseId, updates);
              
              // Refresh courses
              _loadCourses();
            },
            child: Text('Save'),
          ),
        ],
      ),
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
                    // Reload courses for the new semester
                    _loadCourses();
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