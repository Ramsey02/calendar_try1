// pages/home_page.dart
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'calendar_theme_mixin.dart';
import 'profile_page.dart';
import 'course_list_panel.dart';
import 'semester_diagram.dart';
import 'login_page.dart';
import 'gpa_calculator_page.dart';
import '../services/auth_service.dart';
import '../providers/student_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with CalendarDarkThemeMixin {
  final AuthService _authService = AuthService();
  String _currentPage = 'Calendar'; // Default page
  int _viewMode = 0; // 0: Week View, 1: Day View
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _dataInitialized = false;

  String get _userId => _authService.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    // Do NOT fetch data here, we'll do it in didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This is a safer place to initialize data that depends on InheritedWidgets like Provider
    if (!_dataInitialized && _userId.isNotEmpty) {
      _dataInitialized = true; // Set flag to avoid multiple initializations
      // Schedule the data fetch for after this build cycle completes
      Future.microtask(() {
        if (mounted) { // Check if widget is still in the tree
          final studentProvider = Provider.of<StudentProvider>(context, listen: false);
          studentProvider.fetchStudentData(_userId);
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Dialog to add a new event
  void _showAddCourseDialog() {
    final titleController = TextEditingController();
    final courseIdController = TextEditingController();
    final lectureTimeController = TextEditingController();
    final tutorialTimeController = TextEditingController();
    final creditsController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Course'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Course Name*'),
              ),
              TextField(
                controller: courseIdController,
                decoration: InputDecoration(labelText: 'Course ID*'),
              ),
              TextField(
                controller: lectureTimeController,
                decoration: InputDecoration(
                  labelText: 'Lecture Time*',
                  hintText: 'Example: Monday 10:00-12:00',
                ),
              ),
              TextField(
                controller: tutorialTimeController,
                decoration: InputDecoration(
                  labelText: 'Tutorial Time (optional)',
                  hintText: 'Example: Wednesday 14:00-15:30',
                ),
              ),
              TextField(
                controller: creditsController,
                decoration: InputDecoration(
                  labelText: 'Credits',
                  hintText: '3.0',
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              Text(
                '* Required fields',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
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
                // Show validation error
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please fill all required fields')),
                );
                return;
              }
              
              final studentProvider = Provider.of<StudentProvider>(context, listen: false);
              final credits = double.tryParse(creditsController.text) ?? 3.0;
              
              // Create course data object following the structure
              Map<String, dynamic> courseData = {
                'Name': titleController.text,
                'Course_Id': courseIdController.text,
                'Lecture_time': lectureTimeController.text,
                'Tutorial_time': tutorialTimeController.text,
                'Credits': credits,
                'Status': 'Active',
                'Final_grade': 0,
                'Last_Semester_taken': studentProvider.currentSemester,
                'Success_Rate': 0, // Default value, can be calculated later
              };
              
              // Add course using the provider
              String? courseId = await studentProvider.addCourse(_userId, courseData);
              
              if (courseId != null) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Course added successfully')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to add course: ${studentProvider.error}')),
                );
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Access the provider
    final studentProvider = Provider.of<StudentProvider>(context);
    final studentName = studentProvider.student?.name ?? 'User';
    final isLoading = studentProvider.isLoading;
    
    // Build the body content based on selected page
    Widget body;
    
    switch (_currentPage) {
      case 'Calendar':
        body = _buildCalendarView(context, studentProvider);
        break;
      case 'Profile':
        body = ProfilePage();
        break;
      case 'Custom Diagram':
        body = SemesterDiagram();
        break;
      case 'Prerequisites Diagram':
        body = _buildPlaceholderView('Prerequisites Diagram', Icons.account_tree);
        break;
      case 'Map':
        body = _buildPlaceholderView('Map', Icons.map);
        break;
      case 'Chatbot':
        body = _buildPlaceholderView('Chatbot', Icons.chat);
        break;
      case 'GPA Calculator':
        body = _buildPlaceholderView('GPA Calculator', Icons.calculate);
        break;
      case 'Log Out':
        // Handle logout functionality
        _handleLogout();
        body = Center(child: Text('Logging out...'));
        break;
      case 'Credit':
        body = _buildPlaceholderView('Credit', Icons.info);
        break;
      case 'Login':
        body = LoginPage();
        break;
      default:
        body = _buildCalendarView(context, studentProvider);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text('DegreEZ - $_currentPage'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.bolt_sharp,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () {
              // AI functionality
              print('ai clicked');
            },
          ),
        ],
      ),
      drawer: _buildSideDrawer(context, studentName),
      body: isLoading 
          ? Center(child: CircularProgressIndicator())
          : body,
      floatingActionButton: _currentPage == 'Calendar'
          ? FloatingActionButton(
              onPressed: () {
                _showAddCourseDialog();
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _handleLogout() async {
    try {
      await _authService.signOut();
      // AuthWrapper will handle navigation after logout
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Build side drawer for navigation
  Widget _buildSideDrawer(BuildContext context, String studentName) {
    return Drawer(
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Theme.of(context).colorScheme.onPrimary,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    studentName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem('Profile', Icons.person),
            _buildDrawerItem('Calendar', Icons.calendar_today),
            _buildDrawerItem('Custom Diagram', Icons.timeline),
            _buildDrawerItem('Prerequisites Diagram', Icons.account_tree),
            _buildDrawerItem('Map', Icons.map),
            _buildDrawerItem('Chatbot', Icons.chat),
            _buildDrawerItem('GPA Calculator', Icons.calculate),
            const Divider(),
            _buildDrawerItem('Login', Icons.login),
            _buildDrawerItem('Log Out', Icons.logout, onTap: _handleLogout),
            _buildDrawerItem('Credit', Icons.info),
          ],
        ),
      ),
    );
  }

  // Helper method to build drawer items
  Widget _buildDrawerItem(String title, IconData icon, {Function()? onTap}) {
    return ListTile(
      leading: Icon(
        icon,
        color: _currentPage == title
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).colorScheme.onSurface,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: _currentPage == title
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).colorScheme.onSurface,
          fontWeight: _currentPage == title ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: _currentPage == title,
      onTap: onTap ?? () {
        setState(() {
          _currentPage = title;
        });
        Navigator.pop(context); // Close the drawer
      },
    );
  }

  // Calendar View - FULL IMPLEMENTATION
  Widget _buildCalendarView(BuildContext context, StudentProvider studentProvider) {
    // Access the event controller from the provider
    final eventController = studentProvider.eventController;

    return Column(
      children: [
        // Add Search Bar here - only visible in the Weekly View
        if (_viewMode == 0)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search courses...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              onSubmitted: (value) {
                _searchCourses(value);
              },
            ),
          ),

        // Add the Course List Panel
        CourseListPanel(
          eventController: eventController,
        ),

        // Custom tabs without TabController
        Container(
          color: Theme.of(context).colorScheme.surface.withAlpha(25),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _viewMode = 0;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _viewMode == 0 
                            ? Theme.of(context).colorScheme.secondary 
                            : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      'Week View',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _viewMode == 0
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _viewMode = 1;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _viewMode == 1 
                            ? Theme.of(context).colorScheme.secondary 
                            : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      'Day View',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _viewMode == 1
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Add the day-of-week header only in Week View
        if (_viewMode == 0)
          Container(
            color: Theme.of(context).colorScheme.surface.withAlpha(15),
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                // Empty space to match the timeline column width
                SizedBox(
                  width: 50, // Adjust this width to match your timeline column width
                  child: Container(), // Empty container
                ),
                // Days of the week
                Expanded(
                  child: Row(
                    children: const [
                      Expanded(
                        child: Text(
                          'S',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'M',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'T',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'W',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'T',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'F',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'S',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ), 
          
        // Calendar view content
        Expanded(
          child: CalendarControllerProvider(
            controller: eventController,
            child: _viewMode == 0
              ? WeekView(
                  // Apply dark theme using the mixin
                  backgroundColor: getCalendarBackgroundColor(context),
                  headerStyle: getHeaderStyle(context),
                  weekDayBuilder: (date) => buildWeekDay(context, date),
                  timeLineBuilder: (date) => buildTimeLine(context, date),
                  liveTimeIndicatorSettings: getLiveTimeIndicatorSettings(context),
                  hourIndicatorSettings: getHourIndicatorSettings(context),
                  eventTileBuilder: (date, events, boundary, startDuration, endDuration) =>
                    buildEventTile(
                      context, date, events, boundary, startDuration, endDuration,
                      filtered: true, searchQuery: _searchQuery
                    ),
                  startDay: WeekDays.sunday,
                  startHour: 7, // Start at 7:00 AM
                  endHour: 24, // End at midnight (24:00)
                  onEventTap: (events, date) => _showEventDetails(events, date),
                )
              : DayView(
                  // Apply dark theme using the mixin
                  backgroundColor: getCalendarBackgroundColor(context),
                  dayTitleBuilder: (date) => buildDayHeader(context, date),
                  timeLineBuilder: (date) => buildTimeLine(context, date),
                  liveTimeIndicatorSettings: getLiveTimeIndicatorSettings(context),
                  hourIndicatorSettings: getHourIndicatorSettings(context),
                  eventTileBuilder: (date, events, boundary, startDuration, endDuration) =>
                    buildEventTile(context, date, events, boundary, startDuration, endDuration),
                  startHour: 7, // Start at 7:00 AM
                  endHour: 24, // End at midnight (24:00)
                  onEventTap: (events, date) => _showEventDetails(events, date),
                ),
          ),
        ),
      ],
    );
  }

  // Show event details and allow editing/deleting
  void _showEventDetails(List<CalendarEventData> events, DateTime date) {
    if (events.isEmpty) return;
    
    // Get the first event
    final event = events.first;
    final courseId = event.event as String?; // The course ID is stored in the event field
    
    if (courseId == null) return;
    
    // Show details and options in a bottom sheet
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(event.description ?? ''),
              SizedBox(height: 8),
              Text('${_formatDateTime(event.startTime!)} - ${_formatDateTime(event.endTime!)}'),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _editCourse(courseId);
                    },
                    child: Text('Edit'),
                  ),
                  SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteCourse(courseId);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Format date and time for display
  String _formatDateTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Edit a course
  void _editCourse(String courseId) async {
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    final courses = await studentProvider.getCourses(_userId);
    final course = courses.firstWhere((c) => c['id'] == courseId, orElse: () => {});
    
    if (course.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Course not found')),
      );
      return;
    }
    
    final titleController = TextEditingController(text: course['Name']);
    final courseIdController = TextEditingController(text: course['Course_Id']);
    final lectureTimeController = TextEditingController(text: course['Lecture_time']);
    final tutorialTimeController = TextEditingController(text: course['Tutorial_time']);
    final creditsController = TextEditingController(text: (course['Credits'] ?? 3.0).toString());
    
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
              TextField(
                controller: courseIdController,
                decoration: InputDecoration(labelText: 'Course ID*'),
              ),
              TextField(
                controller: lectureTimeController,
                decoration: InputDecoration(
                  labelText: 'Lecture Time*',
                  hintText: 'Example: Monday 10:00-12:00',
                ),
              ),
              TextField(
                controller: tutorialTimeController,
                decoration: InputDecoration(
                  labelText: 'Tutorial Time (optional)',
                  hintText: 'Example: Wednesday 14:00-15:30',
                ),
              ),
              TextField(
                controller: creditsController,
                decoration: InputDecoration(
                  labelText: 'Credits',
                  hintText: '3.0',
                ),
                keyboardType: TextInputType.number,
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
              
              Map<String, dynamic> updatedData = {
                'Name': titleController.text,
                'Course_Id': courseIdController.text,
                'Lecture_time': lectureTimeController.text,
                'Tutorial_time': tutorialTimeController.text,
                'Credits': double.tryParse(creditsController.text) ?? 3.0,
              };
              
              bool success = await studentProvider.updateCourse(_userId, courseId, updatedData);
              
              Navigator.pop(context);
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Course updated successfully')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to update course: ${studentProvider.error}')),
                );
              }
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  // Delete a course with confirmation
  void _deleteCourse(String courseId) {
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
            onPressed: () async {
              Navigator.pop(context);
              
              final studentProvider = Provider.of<StudentProvider>(context, listen: false);
              bool success = await studentProvider.deleteCourse(_userId, courseId);
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Course deleted successfully')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete course: ${studentProvider.error}')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Search for courses
  void _searchCourses(String query) async {
    if (query.isEmpty) return;
    
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    final courses = await studentProvider.getCourses(_userId);
    
    // Filter courses based on search query
    final filteredCourses = courses.where((course) {
      final name = course['Name']?.toString().toLowerCase() ?? '';
      final id = course['Course_Id']?.toString().toLowerCase() ?? '';
      final searchLower = query.toLowerCase();
      
      return name.contains(searchLower) || id.contains(searchLower);
    }).toList();
    
    if (filteredCourses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No courses found matching "$query"')),
      );
      return;
    }
    
    // Show search results in a dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Search Results'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: filteredCourses.length,
            itemBuilder: (context, index) {
              final course = filteredCourses[index];
              return ListTile(
                title: Text(course['Name'] ?? 'Unknown Course'),
                subtitle: Text(course['Course_Id'] ?? ''),
                onTap: () {
                  Navigator.pop(context);
                  _editCourse(course['id']);
                },
              );
            },
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

  // Helper method to build placeholder views
  Widget _buildPlaceholderView(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming soon',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
            ),
          ),
        ],
      ),
    );
  }
}