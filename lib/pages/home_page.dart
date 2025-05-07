import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedNavIndex = 0; // 0: Calendar, 1: GPA, 2: Map, 3: Profile
  int _viewMode = 0; // 0: Week View, 1: Day View
  String _searchQuery = ''; // Add this line to track search query
  final TextEditingController _searchController = TextEditingController(); // Add controller

  @override
  void dispose() {
    _searchController.dispose(); // Dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Different body content based on selected navigation item
    Widget body;
    
    if (_selectedNavIndex == 0) {
      // Calendar View with separate view mode handling
      body = Column(
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
                              // Here you would implement clearing search results
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    // Here you would implement the search functionality
                    // For example: _searchCourses(value);
                  });
                },
                onSubmitted: (value) {
                  // Here you would implement search submission
                  // For example: _fetchCoursesFromInternet(value);
                },
              ),
            ),

          // Custom tabs without TabController
          Container(
            color: Theme.of(context).primaryColor.withAlpha((0.1 * 255).toInt()),
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
                              ? Theme.of(context).primaryColor 
                              : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Week View',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
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
                              ? Theme.of(context).primaryColor 
                              : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Day View',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
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
                  weekDayBuilder: (date) {
                    return Container(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        date.day.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                  eventTileBuilder: (date, events, boundary, startDuration, endDuration) {
                    // Filter events based on search query if needed
                    final filteredEvents = _searchQuery.isEmpty
                        ? events
                        : events.where((event) =>
                            event.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
                    
                    if (filteredEvents.isEmpty) return const SizedBox();
                    
                    return Container(
                      margin: const EdgeInsets.all(2),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        filteredEvents.first.title,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                )
              : DayView(
                  dayTitleBuilder: (date) {
                    return Container(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        'Day: ${date.day}/${date.month}/${date.year}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                  eventTileBuilder: (date, events, boundary, startDuration, endDuration) {
                    if (events.isEmpty) return const SizedBox();
                    
                    return Container(
                      margin: const EdgeInsets.all(2),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        events.first.title,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                ),
          ),
        ],
      );
    } else if (_selectedNavIndex == 1) {
      // GPA Calculator Page (placeholder)
      body = const Center(
        child: Text('GPA Calculator', style: TextStyle(fontSize: 24)),
      );
    } else if (_selectedNavIndex == 2) {
      // Map Page (placeholder)
      body = const Center(
        child: Text('Campus Map', style: TextStyle(fontSize: 24)),
      );
    } else if (_selectedNavIndex == 3) {
      // customized dashboard (placeholder)
      body = const Center(
        child: Text('customized dashboard', style: TextStyle(fontSize: 24)),
      );
    } else if (_selectedNavIndex == 4) {
      // Chatbot Page (placeholder)
      body = const Center(
        child: Text('Chatbot', style: TextStyle(fontSize: 24)),
      );
    } else {
      body = const Center(
        child: Text('Unknown Page', style: TextStyle(fontSize: 24)),
      );


    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('DegreEZ'),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.person,color: Colors.black,),
            onPressed: () {
              // Navigate to settings page
              print('profile clicked');
            },
          ),
        ],
      ),
      body: body,

      floatingActionButton: _selectedNavIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                // Add event creation logic here
                print('Create new event');
              },
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'GPA',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'customized dashboard',
          ),
          
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'chatbot',
          ),
        ],
        currentIndex: _selectedNavIndex,
        onTap: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
        },
      ),
    );
  }

  // Method stub for future implementation - to fetch course data from internet
  void _fetchCoursesFromInternet(String query) {
    // TODO: Implement API call to fetch course data
    print('Searching for courses with query: $query');
    // This will be replaced with actual API integration
  }
}