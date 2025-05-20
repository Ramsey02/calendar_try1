// pages/course_list_panel.dart
import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import '../services/auth_service.dart';

class CourseListPanel extends StatefulWidget {
  final EventController eventController;

  const CourseListPanel({
    super.key,
    required this.eventController,
  });

  @override
  _CourseListPanelState createState() => _CourseListPanelState();
}

class _CourseListPanelState extends State<CourseListPanel> {
  bool _isExpanded = false;
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>>? _courses;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    // Don't load data here
  }
  
  // Safely load courses outside of the build method
  Future<void> _loadCourses() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final userId = _authService.currentUser?.uid ?? '';
      if (userId.isNotEmpty) {
        final studentProvider = Provider.of<StudentProvider>(context, listen: false);
        final courses = await studentProvider.getCourses(userId);
        
        if (mounted) {
          setState(() {
            _courses = courses;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _courses = [];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading courses: $e');
      if (mounted) {
        setState(() {
          _courses = [];
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Don't fetch data in the build method directly
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: _isExpanded ? 200 : 48,
      curve: Curves.easeInOut,
      child: Card(
        margin: EdgeInsets.all(8),
        child: Column(
          children: [
            // Header
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                  // Only load courses when panel is expanded and we haven't loaded them yet
                  if (_isExpanded && (_courses == null)) {
                    // Use Future.microtask to schedule this after the current build cycle
                    Future.microtask(() => _loadCourses());
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.list,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Courses List',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Spacer(),
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                    ),
                  ],
                ),
              ),
            ),
            
            // Expanded content - Course List
            if (_isExpanded)
              Expanded(
                child: _buildCourseListContent(),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCourseListContent() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    if (_courses == null) {
      // We're waiting for _loadCourses() to complete
      return Center(child: CircularProgressIndicator());
    }
    
    if (_courses!.isEmpty) {
      return Center(
        child: Text('No courses found for this semester'),
      );
    }
    
    return ListView.builder(
      itemCount: _courses!.length,
      itemBuilder: (context, index) {
        final course = _courses![index];
        return _buildCourseListItem(course);
      },
    );
  }
  
  // Rest of your CourseListPanel implementation...
  Widget _buildCourseListItem(Map<String, dynamic> course) {
    final lectureTime = course['Lecture_time'] ?? '';
    final tutorialTime = course['Tutorial_time'] ?? '';
    
    return ListTile(
      title: Text(
        course['Name'] ?? 'Unknown Course',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(course['Course_Id'] ?? ''),
          if (lectureTime.isNotEmpty)
            Text(
              'Lecture: $lectureTime',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade300,
              ),
            ),
          if (tutorialTime.isNotEmpty)
            Text(
              'Tutorial: $tutorialTime',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green.shade300,
              ),
            ),
        ],
      ),
      trailing: _getCourseStatusIcon(course['Status'] ?? 'Active'),
      onTap: () => _showCourseOptions(course),
      dense: true,
    );
  }
  
  Widget _getCourseStatusIcon(String status) {
    IconData iconData;
    Color iconColor;
    
    switch (status.toLowerCase()) {
      case 'active':
        iconData = Icons.play_circle_outline;
        iconColor = Colors.green;
        break;
      case 'completed':
        iconData = Icons.check_circle_outline;
        iconColor = Colors.blue;
        break;
      case 'planned':
        iconData = Icons.schedule;
        iconColor = Colors.orange;
        break;
      case 'failed':
        iconData = Icons.cancel_outlined;
        iconColor = Colors.red;
        break;
      default:
        iconData = Icons.help_outline;
        iconColor = Colors.grey;
    }
    
    return Icon(
      iconData,
      color: iconColor,
    );
  }
  
  
  void _showCourseOptions(Map<String, dynamic> course) {
    final courseId = course['id'];
    
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                course['Name'] ?? 'Unknown Course',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit Course'),
                onTap: () {
                  Navigator.pop(context);
                  _editCourse(course);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Remove Course', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteCourse(courseId);
                },
              ),
              ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('View Details'),
                onTap: () {
                  Navigator.pop(context);
                  _viewCourseDetails(course);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _editCourse(Map<String, dynamic> course) {
    final titleController = TextEditingController(text: course['Name']);
    final courseIdController = TextEditingController(text: course['Course_Id']);
    final lectureTimeController = TextEditingController(text: course['Lecture_time']);
    final tutorialTimeController = TextEditingController(text: course['Tutorial_time']);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Course'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Course Name*'),
              ),
              SizedBox(height: 8),
              TextField(
                controller: courseIdController,
                decoration: InputDecoration(labelText: 'Course ID*'),
              ),
              SizedBox(height: 8),
              TextField(
                controller: lectureTimeController,
                decoration: InputDecoration(
                  labelText: 'Lecture Time*',
                  hintText: 'Example: Monday 10:00-12:00',
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: tutorialTimeController,
                decoration: InputDecoration(
                  labelText: 'Tutorial Time (optional)',
                  hintText: 'Example: Wednesday 14:00-15:30',
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
              if (titleController.text.isEmpty || 
                  courseIdController.text.isEmpty ||
                  lectureTimeController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please fill all required fields')),
                );
                return;
              }
              
              final studentProvider = Provider.of<StudentProvider>(context, listen: false);
              final userId = _authService.currentUser?.uid ?? '';
              
              Map<String, dynamic> updatedData = {
                'Name': titleController.text,
                'Course_Id': courseIdController.text,
                'Lecture_time': lectureTimeController.text,
                'Tutorial_time': tutorialTimeController.text,
              };
              
              bool success = await studentProvider.updateCourse(
                userId, course['id'], updatedData);
              
              Navigator.pop(context);
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Course updated successfully')),
                );
                setState(() {}); // Refresh the list
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to update course')),
                );
              }
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }
  
  void _confirmDeleteCourse(String courseId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Course'),
        content: Text('Are you sure you want to delete this course?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              Navigator.pop(context);
              
              final studentProvider = Provider.of<StudentProvider>(context, listen: false);
              final userId = _authService.currentUser?.uid ?? '';
              
              bool success = await studentProvider.deleteCourse(userId, courseId);
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Course deleted successfully')),
                );
                setState(() {}); // Refresh the list
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete course')),
                );
              }
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  void _viewCourseDetails(Map<String, dynamic> course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(course['Name'] ?? 'Course Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Course ID', course['Course_Id'] ?? ''),
              _buildDetailRow('Status', course['Status'] ?? 'Active'),
              _buildDetailRow('Lecture Time', course['Lecture_time'] ?? 'Not specified'),
              _buildDetailRow('Tutorial Time', course['Tutorial_time'] ?? 'Not specified'),
              _buildDetailRow('Last Taken', course['Last_Semester_taken'] ?? ''),
              if (course['Final_grade'] != null)
                _buildDetailRow('Final Grade', course['Final_grade'].toString()),
              if (course['Credits'] != null)
                _buildDetailRow('Credits', course['Credits'].toString()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
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
}