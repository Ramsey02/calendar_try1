import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'calendar_theme_mixin.dart'; // Import the mixin
import 'profile_page.dart'; // Import profile page
import 'course_list_panel.dart'; // Import course list panel

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with CalendarDarkThemeMixin {
  String _currentPage = 'Calendar'; // Default page
  int _viewMode = 0; // 0: Week View, 1: Day View
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Get the event controller
  EventController get _eventController => 
      CalendarControllerProvider.of(context).controller;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      default:
        body = _buildCalendarView();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text('DegreEZ - $_currentPage'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.star,
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
      body: body,
      floatingActionButton: _currentPage == 'Calendar'
          ? FloatingActionButton(
              onPressed: () {
                // ignore: avoid_print
                print('Create new event');
                // _showAddEventDialog();
              },
              child: const Icon(Icons.add),
            )
          : null,
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
                  const Text(
                    'DegreEZ',
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
            _buildDrawerItem('Log Out', Icons.logout),
            _buildDrawerItem('Credit', Icons.info),
          ],
        ),
      ),
    );
  }

  // Helper method to build drawer items
  Widget _buildDrawerItem(String title, IconData icon) {
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
      onTap: () {
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
        
        // Calendar View based on selected view mode
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
              ),
        ),
      ],
    );
  }

  // Placeholder methods for other views
  Widget _buildDiagramView() {
    return _buildPlaceholderView('Custom Diagram', Icons.timeline);
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
}

void _fetchCoursesFromInternet(String value) {
  // Implement your API call here
}