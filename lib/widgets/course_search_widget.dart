import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/course_provider.dart';
import '../providers/auth_provider.dart';
import '../models/course.dart';

class CourseSearchWidget extends StatefulWidget {
  final String semesterId;
  
  CourseSearchWidget({required this.semesterId});
  
  @override
  _CourseSearchWidgetState createState() => _CourseSearchWidgetState();
}

class _CourseSearchWidgetState extends State<CourseSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<CourseInfo> _searchResults = [];
  
  void _search() {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    setState(() {
      _searchResults = courseProvider.searchCourses(_searchController.text);
    });
  }
  
  void _addCourse(CourseInfo courseInfo) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    
    if (authProvider.user == null) return;
    
    // Show time selection dialog
    Map<String, dynamic>? selectedTimes = await _showTimeSelectionDialog(courseInfo);
    if (selectedTimes == null) return;
    
    // Create course object
    Course newCourse = Course(
      courseId: courseInfo.courseId,
      name: courseInfo.name,
      lectureTime: selectedTimes['lecture'],
      tutorialTime: selectedTimes['tutorial'],
      status: CourseStatus.inProgress,
    );
    
    try {
      await courseProvider.addCourse(
        studentId: authProvider.user!.uid,
        semesterId: widget.semesterId,
        course: newCourse,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Course added successfully!')),
      );
      
      // Clear search
      _searchController.clear();
      setState(() {
        _searchResults = [];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add course: $e')),
      );
    }
  }
  
  Future<Map<String, dynamic>?> _showTimeSelectionDialog(CourseInfo courseInfo) async {
    String? selectedLecture;
    String? selectedTutorial;
    
    // Group schedule by type
    List<CourseSchedule> lectures = courseInfo.schedule
        .where((s) => s.type == 'הרצאה')
        .toList();
    List<CourseSchedule> tutorials = courseInfo.schedule
        .where((s) => s.type == 'תרגול')
        .toList();
    
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Times for ${courseInfo.name}'),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (lectures.isNotEmpty) ...[
                  Text('Lecture:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...lectures.map((lecture) => RadioListTile<String>(
                    title: Text('${lecture.day} ${lecture.time}'),
                    subtitle: Text('Group ${lecture.group} - ${lecture.instructor}'),
                    value: '${lecture.day} ${lecture.time}',
                    groupValue: selectedLecture,
                    onChanged: (value) {
                      setState(() {
                        selectedLecture = value;
                      });
                    },
                  )),
                ],
                SizedBox(height: 16),
                if (tutorials.isNotEmpty) ...[
                  Text('Tutorial:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...tutorials.map((tutorial) => RadioListTile<String>(
                    title: Text('${tutorial.day} ${tutorial.time}'),
                    subtitle: Text('Group ${tutorial.group}'),
                    value: '${tutorial.day} ${tutorial.time}',
                    groupValue: selectedTutorial,
                    onChanged: (value) {
                      setState(() {
                        selectedTutorial = value;
                      });
                    },
                  )),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if ((lectures.isEmpty || selectedLecture != null) &&
                  (tutorials.isEmpty || selectedTutorial != null)) {
                Navigator.pop(context, {
                  'lecture': selectedLecture,
                  'tutorial': selectedTutorial,
                });
              }
            },
            child: Text('Add Course'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search courses by ID or name...',
              prefixIcon: Icon(Icons.search),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchResults = [];
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (value) => _search(),
          ),
        ),
        
        // Search Results
        Expanded(
          child: ListView.builder(
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final course = _searchResults[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  title: Text(course.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ID: ${course.courseId}'),
                      Text('Credits: ${course.credits}'),
                      if (course.prerequisites.isNotEmpty)
                        Text('Prerequisites: ${course.prerequisites}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () => _addCourse(course),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}