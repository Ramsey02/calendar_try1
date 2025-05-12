import 'package:flutter/material.dart';

class SemesterDiagram extends StatefulWidget {
  const SemesterDiagram({Key? key}) : super(key: key);

  @override
  State<SemesterDiagram> createState() => _SemesterDiagramState();
}

class _SemesterDiagramState extends State<SemesterDiagram> {
  // Sample data structure for semester courses
  // In a real implementation, this would come from your backend or local database
  final List<Map<String, dynamic>> semesters = [
    {
      'semester': 1,
      'courses': [
        {
          'code': '03240033',
          'name': 'אלגברה לינארית מ',
          'credits': 3.0,
          'color': Colors.blue.shade700,
        },
        {
          'code': '01040031',
          'name': 'חשבון אינפיניטסימלי 1מ',
          'credits': 5.5,
          'color': Colors.teal.shade700,
        },
        {
          'code': '01040166',
          'name': 'אלגברה אמ',
          'credits': 5.5,
          'color': Colors.amber.shade700,
        },
        {
          'code': '03240114',
          'name': 'מבוא למדעי המחשב מ',
          'credits': 4.0,
          'color': Colors.green.shade700,
        },
        {
          'code': '03240129',
          'name': 'מבוא לתורת הקבוצות ואוטומטים למדמח',
          'credits': 3.0,
          'color': Colors.purple.shade700,
        },
      ],
    },
    {
      'semester': 2,
      'courses': [
        {
          'code': '01140071',
          'name': 'פיסיקה 1מל',
          'credits': 3.5,
          'color': Colors.orange.shade700,
        },
        {
          'code': '01040032',
          'name': 'חשבון אינפיניטסימלי 2מ',
          'credits': 5.0,
          'color': Colors.indigo.shade700,
        },
        {
          'code': '02340125',
          'name': 'אלגוריתמים נומריים',
          'credits': 3.0,
          'color': Colors.red.shade700,
        },
        {
          'code': '02340124',
          'name': 'מבוא לתכנות מערכות',
          'credits': 4.0,
          'color': Colors.cyan.shade700,
        },
        {
          'code': '02340141',
          'name': 'קומבינטוריקה למדעי המחשב',
          'credits': 3.0,
          'color': Colors.deepPurple.shade700,
        },
      ],
    },
    {
      'semester': 3,
      'courses': [
        {
          'code': '00940142',
          'name': 'הסתברות מ',
          'credits': 4.0,
          'color': Colors.blue.shade800,
        },
        {
          'code': '01040134',
          'name': 'אלגברה מודרנית ח',
          'credits': 2.5,
          'color': Colors.teal.shade800,
        },
        {
          'code': '02340292',
          'name': 'לוגיקה למדעי המחשב',
          'credits': 3.0,
          'color': Colors.red.shade800,
        },
        {
          'code': '02340218',
          'name': 'מבני נתונים 1',
          'credits': 3.0,
          'color': Colors.green.shade800,
        },
        {
          'code': '00440252',
          'name': 'אמינות ובדיקות - תוכנה ונושאי המחשב',
          'credits': 5.0,
          'color': Colors.purple.shade800,
        },
      ],
    },
    {
      'semester': 4,
      'courses': [
        {
          'code': '02340247',
          'name': 'אלגוריתמים 1',
          'credits': 3.0,
          'color': Colors.blue.shade900,
        },
        {
          'code': '02340123',
          'name': 'מערכות הפעלה',
          'credits': 4.5,
          'color': Colors.teal.shade900,
        },
        {
          'code': '02340118',
          'name': 'ארגון ותכנות המחשב',
          'credits': 3.0,
          'color': Colors.green.shade900,
        },
      ],
    },
    {
      'semester': 5,
      'courses': [
        {
          'code': '02340343',
          'name': 'תורת החישוביות',
          'credits': 3.0,
          'color': Colors.orange.shade900,
        },
        {
          'code': '02340267',
          'name': 'מבנה מחשבים רב מעבדים',
          'credits': 3.0,
          'color': Colors.red.shade900,
        },
        {
          'code': '02360360',
          'name': 'תורת הקומפילציה',
          'credits': 3.0,
          'color': Colors.purple.shade900,
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Detect device orientation
    final orientation = MediaQuery.of(context).orientation;
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Degree Progress',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: semesters.length,
                itemBuilder: (context, index) {
                  final semester = semesters[index];
                  return orientation == Orientation.portrait
                      ? _buildVerticalSemesterSection(context, semester)
                      : _buildHorizontalSemesterSection(context, semester);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Vertical layout for portrait mode (original implementation)
  Widget _buildVerticalSemesterSection(BuildContext context, Map<String, dynamic> semester) {
    // Calculate total credits for this semester
    double totalCredits = 0;
    for (final course in semester['courses']) {
      totalCredits += course['credits'];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 20, bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Semester ${semester['semester']}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${totalCredits.toStringAsFixed(1)} credits',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Grid of courses
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.6,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: semester['courses'].length,
          itemBuilder: (context, index) {
            final course = semester['courses'][index];
            return _buildCourseCard(context, course);
          },
        ),
        const SizedBox(height: 10),
        const Divider(),
      ],
    );
  }
  
  // Horizontal layout for landscape mode (new implementation)
  Widget _buildHorizontalSemesterSection(BuildContext context, Map<String, dynamic> semester) {
    double totalCredits = 0;
    for (final course in semester['courses']) {
      totalCredits += course['credits'];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 20, bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Semester ${semester['semester']}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${totalCredits.toStringAsFixed(1)} credits',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Horizontal scrollable list of courses
        SizedBox(
          height: 120, // Fixed height for each course row
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: semester['courses'].length,
            itemBuilder: (context, index) {
              final course = semester['courses'][index];
              return _buildHorizontalCourseCard(context, course);
            },
          ),
        ),
        const SizedBox(height: 10),
        const Divider(),
      ],
    );
  }

  // Vertical course card for portrait mode
  Widget _buildCourseCard(BuildContext context, Map<String, dynamic> course) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: course['color'],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    course['code'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${course['credits']}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              course['name'],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Horizontal course card for landscape mode
  Widget _buildHorizontalCourseCard(BuildContext context, Map<String, dynamic> course) {
    return Container(
      width: 200, // Fixed width for horizontal cards
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: course['color'],
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      course['code'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${course['credits']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                course['name'],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}