import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'calendar_theme_mixin.dart'; // Import the mixin
import 'profile_page.dart'; // Import profile page
import 'course_list_panel.dart'; // Import course list panel
import 'semester_diagram.dart'; // Import the new diagram widget
import 'login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/course_service.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with CalendarDarkThemeMixin {
  final AuthService _authService = AuthService();
  final CourseService _courseService = CourseService(); // Add this line

  String _currentPage = 'Calendar'; // Default page
  int _viewMode = 0; // 0: Week View, 1: Day View
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  String get _userId => _authService.currentUser?.uid ?? 'user123';

  String _currentSemester = 'Winter 2024/25'; // Replace with current semester logic

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get the event controller
  EventController get _eventController => 
      CalendarControllerProvider.of(context).controller;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fetch events from Firestore
  Future<void> _fetchEvents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Clear existing events
      _eventController.events.clear();

      // Fetch the current semester document
      final semesterDoc = await _firestore
          .collection('Students')
          .doc(_userId)
          .collection('Courses-per-Semesters')
          .doc(_currentSemester)
          .get();

      if (semesterDoc.exists) {
        // Fetch all courses for this semester
        final coursesSnapshot = await _firestore
            .collection('Students')
            .doc(_userId)
            .collection('Courses-per-Semesters')
            .doc(_currentSemester)
            .collection('Courses')
            .get();

        if (coursesSnapshot.docs.isNotEmpty) {
          final now = DateTime.now();
          List<CalendarEventData> events = [];

          for (var courseDoc in coursesSnapshot.docs) {
            final courseData = courseDoc.data();
            
            // Handle lecture time events
            if (courseData['Lecture_time'] != null) {
              final lectureEvents = _parseTimeToEvents(
                courseData['Name'] ?? 'Unknown Course',
                courseData['Lecture_time'],
                now,
                Colors.blue.shade700,
                '${courseData['Course_Id']} - Lecture'
              );
              events.addAll(lectureEvents);
            }
            
            // Handle tutorial time events
            if (courseData['Tutorial_time'] != null) {
              final tutorialEvents = _parseTimeToEvents(
                courseData['Name'] ?? 'Unknown Course',
                courseData['Tutorial_time'],
                now,
                Colors.green.shade700,
                '${courseData['Course_Id']} - Tutorial'
              );
              events.addAll(tutorialEvents);
            }
          }
          
          // Add all events to the controller
          _eventController.addAll(events);
        }
      } else {
        // Create default semester if it doesn't exist
        await _firestore
            .collection('Students')
            .doc(_userId)
            .collection('Courses-per-Semesters')
            .doc(_currentSemester)
            .set({
          'Semester Number': 1,
        });
        
        // Add some default events if needed
        _addDefaultEvents();
      }
    } catch (e) {
      print('Error fetching events: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper to parse time strings into events
  List<CalendarEventData> _parseTimeToEvents(
      String title, String timeString, DateTime baseDate, Color color, String description) {
    // This is a simplified parser - you'll need to adapt it based on your time format
    // Example format: "Monday 10:00-12:00"
    List<CalendarEventData> events = [];
    
    try {
      // Split by comma for multiple time slots
      final timeSlots = timeString.split(',');
      
      for (var slot in timeSlots) {
        slot = slot.trim();
        
        // Extract day and time
        final parts = slot.split(' ');
        if (parts.length < 2) continue;
        
        final day = parts[0].toLowerCase();
        final timePart = parts[1];
        
        // Parse time range
        final timeRange = timePart.split('-');
        if (timeRange.length < 2) continue;
        
        final startTimeParts = timeRange[0].split(':');
        final endTimeParts = timeRange[1].split(':');
        
        if (startTimeParts.length < 2 || endTimeParts.length < 2) continue;
        
        final startHour = int.tryParse(startTimeParts[0]) ?? 0;
        final startMinute = int.tryParse(startTimeParts[1]) ?? 0;
        final endHour = int.tryParse(endTimeParts[0]) ?? 0;
        final endMinute = int.tryParse(endTimeParts[1]) ?? 0;
        
        // Map day string to day of week (0 = Sunday, 1 = Monday, etc.)
        int dayOfWeek;
        switch (day) {
          case 'sunday': dayOfWeek = 0; break;
          case 'monday': dayOfWeek = 1; break;
          case 'tuesday': dayOfWeek = 2; break;
          case 'wednesday': dayOfWeek = 3; break;
          case 'thursday': dayOfWeek = 4; break;
          case 'friday': dayOfWeek = 5; break;
          case 'saturday': dayOfWeek = 6; break;
          default: continue; // Skip if day is invalid
        }
        
        // Calculate event date (find the next occurrence of this day)
        final eventDate = _findNextDayOfWeek(baseDate, dayOfWeek);
        
        // Create event
        events.add(CalendarEventData(
          date: eventDate,
          title: title,
          description: description,
          startTime: DateTime(
            eventDate.year, 
            eventDate.month, 
            eventDate.day, 
            startHour, 
            startMinute
          ),
          endTime: DateTime(
            eventDate.year, 
            eventDate.month, 
            eventDate.day, 
            endHour, 
            endMinute
          ),
          color: color,
        ));
      }
    } catch (e) {
      print('Error parsing time: $e');
    }
    
    return events;
  }

  // Helper to find the next occurrence of a day of week
  DateTime _findNextDayOfWeek(DateTime date, int dayOfWeek) {
    DateTime result = DateTime(date.year, date.month, date.day);
    int daysToAdd = (dayOfWeek - date.weekday) % 7;
    if (daysToAdd == 0) {
      daysToAdd = 7; // If today is the target day, get next week
    }
    return result.add(Duration(days: daysToAdd));
  }

  // Add some default events for demonstration
  void _addDefaultEvents() {
    final now = DateTime.now();
    final events = [
      CalendarEventData(
        date: now,
        title: "Electrical Circuit Theory",
        description: "004401053 - Ullman room 101",
        startTime: DateTime(now.year, now.month, now.day, 8, 0),
        endTime: DateTime(now.year, now.month, now.day, 10, 0),
        color: Colors.blue.shade700,
      ),
      
      CalendarEventData(
        date: now,
        title: "Physical Electronics",
        description: "00440124 - Meyer Building room 305",
        startTime: DateTime(now.year, now.month, now.day, 12, 30),
        endTime: DateTime(now.year, now.month, now.day, 14, 0),
        color: Colors.green.shade700,
      ),
    ];
    
    _eventController.addAll(events);
  }

  // Search for courses in Firestore
  void _fetchCoursesFromInternet(String query) async {
    if (query.isEmpty) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // This is a simplified search - you'll need to adapt based on your actual data structure
      final results = await _firestore
          .collection('Students')
          .doc(_userId)
          .collection('Courses-per-Semesters')
          .doc(_currentSemester)
          .collection('Courses')
          .where('Name', isGreaterThanOrEqualTo: query)
          .where('Name', isLessThanOrEqualTo: query + '\uf8ff')
          .get();
      
      // Process search results
      print('Found ${results.docs.length} courses matching "$query"');
      
      // You could display these results in a dialog or panel
    } catch (e) {
      print('Error searching for courses: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build the body content based on selected page
    Widget body;
    
    switch (_currentPage) {
      case 'Calendar':
        body = _buildCalendarView();
        break;
      case 'Profile':
        body = const ProfilePage();
        break;
      case 'Custom Diagram':
        body = _buildDiagramView();
        break;
      case 'Prerequisites Diagram':
        body = _buildPrerequisitesDiagramView();
        break;
      case 'Map':
        body = _buildMapView();
        break;
      case 'Chatbot':
        body = _buildChatbotView();
        break;
      case 'GPA Calculator':
        body = _buildGpaCalculatorView();
        break;
      case 'Log Out':
        // Handle logout functionality here
        body = Center(child: Text('Logging out...'));
        // You might want to implement actual logout logic
        break;
      case 'Credit':
        body = _buildCreditView();
        break;
      case 'Login':
        body = const LoginPage();
        break;
      default:
        body = _buildCalendarView();
    }

  Widget _buildBody() {
    switch (_currentPage) {
      case 'Calendar':
        return _buildCalendarView();
      case 'Profile':
        return const ProfilePage();
      case 'Diagram':
        return _buildDiagramView();
      case 'Prerequisites Diagram':
        return _buildPrerequisitesDiagramView();
      case 'Map':
        return _buildMapView();
      case 'Chatbot':
        return _buildChatbotView();
      case 'GPA Calculator':
        return _buildGpaCalculatorView();
      case 'Credit':
        return _buildCreditView();
      default:
        return Center(child: Text('Unknown page: $_currentPage'));
    }
    Widget _buildPlaceholderView(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text('Coming soon', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
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
              // ignore: avoid_print
              print('ai clicked');
            },
          ),
        ],
      ),
      drawer: _buildSideDrawer(),
      body: _buildBody(),
        floatingActionButton: _currentPage == 'Calendar'
            ? FloatingActionButton(
                onPressed: () => _showAddCourseDialog(context),
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
  // Dialog to add a new event
  void _showAddEventDialog() {
    final titleController = TextEditingController();
    final courseIdController = TextEditingController();
    final lectureTimeController = TextEditingController();
    final tutorialTimeController = TextEditingController();
    
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
                decoration: InputDecoration(labelText: 'Course Name'),
              ),
              TextField(
                controller: courseIdController,
                decoration: InputDecoration(labelText: 'Course ID'),
              ),
              TextField(
                controller: lectureTimeController,
                decoration: InputDecoration(
                  labelText: 'Lecture Time',
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
              if (titleController.text.isEmpty || courseIdController.text.isEmpty) {
                // Show validation error
                return;
              }
              
              try {
                // Add to Firestore
                final courseRef = await _firestore
                    .collection('Students')
                    .doc(_userId)
                    .collection('Courses-per-Semesters')
                    .doc(_currentSemester)
                    .collection('Courses')
                    .add({
                  'Name': titleController.text,
                  'Course_Id': courseIdController.text,
                  'Lecture_time': lectureTimeController.text,
                  'Tutorial_time': tutorialTimeController.text,
                  'Status': 'Active',
                  'Final_grade': 0,
                  'Last_Semester_taken': _currentSemester,
                });
                
                Navigator.pop(context);
                
                // Refresh events
                _fetchEvents();
              } catch (e) {
                print('Error adding course: $e');
                // Show error message
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  // Build side drawer for navigation
  Widget _buildSideDrawer() {
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
                  FutureBuilder<DocumentSnapshot>(
                    future: _firestore.collection('Students').doc(_userId).get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text('Loading...',
                          style: TextStyle(color: Colors.white),
                        );
                      }
                      
                      if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                        return Text('User',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }
                      
                      final userData = snapshot.data!.data() as Map<String, dynamic>;
                      return Text(
                        userData['Name'] ?? 'User',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
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
  Widget _buildCalendarView() {
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
                _fetchCoursesFromInternet(value);
              },
            ),
          ),

        // Add the Course List Panel - NEW ADDITION
        CourseListPanel(
          eventController: _eventController,
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
          
          
        Expanded(
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
              ),
              
        ),
      ],
    );
  }

  // Placeholder methods for other views
  Widget _buildDiagramView() {
    return const SemesterDiagram();
  }

  Widget _buildPrerequisitesDiagramView() {
    return _buildPlaceholderView('Prerequisites Diagram', Icons.account_tree);
  }

  Widget _buildMapView() {
    return _buildPlaceholderView('Map', Icons.map);
  }

  Widget _buildChatbotView() {
    return _buildPlaceholderView('Chatbot', Icons.chat);
  }

  Widget _buildGpaCalculatorView() {
    return _buildPlaceholderView('GPA Calculator', Icons.calculate);
  }

  Widget _buildCreditView() {
    return _buildPlaceholderView('Credit', Icons.info);
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
  // Method to show the Add Course dialog
void _showAddCourseDialog(BuildContext context) {
  final TextEditingController courseIdController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lectureTimeController = TextEditingController();
  final TextEditingController tutorialTimeController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Add New Course'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: courseIdController,
                decoration: const InputDecoration(labelText: 'Course ID'),
              ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Course Name'),
              ),
              TextField(
                controller: lectureTimeController,
                decoration: const InputDecoration(labelText: 'Lecture Time (e.g., Mon 10:00-12:00)'),
              ),
              TextField(
                controller: tutorialTimeController,
                decoration: const InputDecoration(labelText: 'Tutorial Time (e.g., Tue 14:00-16:00)'),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: const Text('Add Course'),
            onPressed: () async {
              if (courseIdController.text.isNotEmpty && nameController.text.isNotEmpty) {
                final String? userId = _authService.currentUser?.uid;
                if (userId != null) {
                  final courseData = {
                    'Course_Id': courseIdController.text,
                    'Name': nameController.text,
                    'Lecture_time': lectureTimeController.text.isEmpty ? null : lectureTimeController.text,
                    'Tutorial_time': tutorialTimeController.text.isEmpty ? null : tutorialTimeController.text,
                    'Final_grade': '', // Default empty grade
                  };

                  setState(() {
                    _isLoading = true; // Show loading indicator
                  });

                  try {
                    await _courseService.addCourse(
                      userId,
                      _currentSemester, // Use the current semester
                      courseData,
                    );
                    // Refresh events after adding a new course
                    _eventController.addAll(
                      await _courseService.getStudentCoursesAsEvents(
                        userId,
                        _currentSemester,
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Course added successfully!')),
                    );
                    Navigator.of(context).pop(); // Close the dialog
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to add course: $e')),
                    );
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isLoading = false; // Hide loading indicator
                      });
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User not logged in.')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Course ID and Name cannot be empty.')),
                );
              }
            },
          ),
        ],
      );
    },
  );
}
}