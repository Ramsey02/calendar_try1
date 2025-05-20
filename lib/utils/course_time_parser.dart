// utils/course_time_parser.dart
import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';

class CourseTimeParser {
  /// Parses time strings into calendar events
  /// Format: "Monday 10:00-12:00, Wednesday 14:00-15:30"
  static List<CalendarEventData> parseTimeToEvents({
    required String title,
    required String timeString,
    required DateTime baseDate,
    required Color color,
    required String description,
    String? courseId,
  }) {
    List<CalendarEventData> events = [];
    
    try {
      // Handle empty time strings
      if (timeString.isEmpty) {
        return events;
      }
      
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
          event: courseId, // Store the course ID in the event for reference
        ));
      }
    } catch (e) {
      print('Error parsing time: $e');
    }
    
    return events;
  }
  
  /// Find the next occurrence of a specific day of the week
  static DateTime _findNextDayOfWeek(DateTime date, int dayOfWeek) {
    DateTime result = DateTime(date.year, date.month, date.day);
    int daysToAdd = (dayOfWeek - date.weekday) % 7;
    if (daysToAdd == 0) {
      daysToAdd = 7; // If today is the target day, get next week
    }
    return result.add(Duration(days: daysToAdd));
  }
  
  /// Validate time string format
  static bool isValidTimeFormat(String timeString) {
    if (timeString.isEmpty) return false;
    
    final timeSlots = timeString.split(',');
    
    for (var slot in timeSlots) {
      slot = slot.trim();
      
      // Should match pattern: "Day HH:MM-HH:MM"
      final regex = RegExp(r'^(sunday|monday|tuesday|wednesday|thursday|friday|saturday) \d{1,2}:\d{2}-\d{1,2}:\d{2}$', caseSensitive: false);
      
      if (!regex.hasMatch(slot)) {
        return false;
      }
    }
    
    return true;
  }
  
  /// Get display name for a time string
  static String getDisplayTimeString(String timeString) {
    if (timeString.isEmpty) return 'Not scheduled';
    
    final timeSlots = timeString.split(',');
    List<String> formattedSlots = [];
    
    for (var slot in timeSlots) {
      slot = slot.trim();
      
      // Extract day and time
      final parts = slot.split(' ');
      if (parts.length < 2) continue;
      
      final day = parts[0];
      final timePart = parts[1];
      
      // Capitalize day name
      final capitalizedDay = day.substring(0, 1).toUpperCase() + day.substring(1);
      
      formattedSlots.add('$capitalizedDay $timePart');
    }
    
    return formattedSlots.join(', ');
  }
  
  /// Check if two course times have conflicts
  static bool hasTimeConflict(String timeString1, String timeString2) {
    if (timeString1.isEmpty || timeString2.isEmpty) return false;
    
    final timeSlots1 = timeString1.split(',');
    final timeSlots2 = timeString2.split(',');
    
    for (var slot1 in timeSlots1) {
      for (var slot2 in timeSlots2) {
        if (_doSlotsConflict(slot1.trim(), slot2.trim())) {
          return true;
        }
      }
    }
    
    return false;
  }
  
  /// Check if two time slots conflict
  static bool _doSlotsConflict(String slot1, String slot2) {
    // Extract day and time
    final parts1 = slot1.split(' ');
    final parts2 = slot2.split(' ');
    
    if (parts1.length < 2 || parts2.length < 2) return false;
    
    final day1 = parts1[0].toLowerCase();
    final day2 = parts2[0].toLowerCase();
    
    // If different days, no conflict
    if (day1 != day2) return false;
    
    // Parse time ranges
    final timeRange1 = parts1[1].split('-');
    final timeRange2 = parts2[1].split('-');
    
    if (timeRange1.length < 2 || timeRange2.length < 2) return false;
    
    // Convert times to minutes for easier comparison
    final start1 = _timeToMinutes(timeRange1[0]);
    final end1 = _timeToMinutes(timeRange1[1]);
    final start2 = _timeToMinutes(timeRange2[0]);
    final end2 = _timeToMinutes(timeRange2[1]);
    
    // Check for overlap
    return (start1 < end2 && end1 > start2);
  }
  
  /// Convert time string (HH:MM) to minutes
  static int _timeToMinutes(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length < 2) return 0;
    
    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;
    
    return hours * 60 + minutes;
  }
}