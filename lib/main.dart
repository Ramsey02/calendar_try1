import 'dart:ui';

import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'pages/home_page.dart';  // You'll need to create this file

DateTime get _now => DateTime.now();

// Move the _events list above the main() function
List<CalendarEventData> _events = [
  CalendarEventData(
    date: _now,  // 
    title: "algebra A \n nir ben david \n Ullman room 101",
    titleStyle: TextStyle(),
    description: "nir ben david, Ullman room 101",
    startTime: DateTime(_now.year, _now.month, _now.day, 8, 0),
    endTime: DateTime(_now.year, _now.month, _now.day, 10, 0),
  ),

  // Add more sample events as needed
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
        theme: ThemeData.light(),
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