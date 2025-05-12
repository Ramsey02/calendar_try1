import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';

class CourseListPanel extends StatefulWidget {
  final EventController eventController;
  
  const CourseListPanel({
    Key? key, 
    required this.eventController,
  }) : super(key: key);

  @override
  State<CourseListPanel> createState() => _CourseListPanelState();
}

class _CourseListPanelState extends State<CourseListPanel> {
  bool _isExpanded = false;

  // Sample courses with different colors
  final List<Map<String, dynamic>> courses = [
    {
      'code': '004401053',
      'name': 'Electrical Circuit Theory',
      'color': Colors.blue.shade700,
    },
    {
      'code': '00440124',
      'name': 'Physical Electronics',
      'color': Colors.green.shade700,
    },
    {
      'code': '00440127',
      'name': 'Semiconductor Device Basics',
      'color': Colors.purple.shade700,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with title and expand/collapse button
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Courses',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ],
              ),
            ),
          ),
          
          // Expandable course list
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _isExpanded 
                ? CrossFadeState.showSecond 
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(height: 0),
            secondChild: Column(
              children: [
                const Divider(height: 1),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    return ListTile(
                      leading: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: course['color'],
                          shape: BoxShape.circle,
                        ),
                      ),
                      title: Text(
                        course['name'],
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        course['code'],
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      dense: true,
                      onTap: () {
                        // Optional: Scroll to this course's time slot
                        // Or perform other actions
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}