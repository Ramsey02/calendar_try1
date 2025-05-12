import 'dart:ui';

import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'pages/home_page.dart';  // You'll need to create this file
// import 'pages/course_diagram_page.dart';

DateTime get _now => DateTime.now();

// Move the _events list above the main() function
// Move the _events list above the main() function
List<CalendarEventData> _events = [
  CalendarEventData(
    date: _now,
    title: "Electrical Circuit Theory",
    description: "004401053 - Ullman room 101",
    startTime: DateTime(_now.year, _now.month, _now.day, 8, 0),
    endTime: DateTime(_now.year, _now.month, _now.day, 10, 0),
    color: Colors.blue.shade700,
  ),
  
  CalendarEventData(
    date: _now,
    title: "Physical Electronics",
    description: "00440124 - Meyer Building room 305",
    startTime: DateTime(_now.year, _now.month, _now.day, 12, 30),
    endTime: DateTime(_now.year, _now.month, _now.day, 14, 0),
    color: Colors.green.shade700,
  ),
  
  CalendarEventData(
    date: _now.add(const Duration(days: 1)), // Next day
    title: "Semiconductor Device Basics",
    description: "00440127 - EE Lab room 202",
    startTime: DateTime(_now.year, _now.month, _now.day + 1, 10, 15),
    endTime: DateTime(_now.year, _now.month, _now.day + 1, 11, 45),
    color: Colors.purple.shade700,
  ),
];

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider(
      controller: EventController()..addAll(_events),
      child: MaterialApp(
        title: 'DegreEZ',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        scrollBehavior: ScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.trackpad,
            PointerDeviceKind.mouse,
            PointerDeviceKind.touch,
          },
        ),
        home: HomePage(),
      ),
    );
  }
}