// pages/gpa_calculator_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import '../services/auth_service.dart';

class GpaCalculatorPage extends StatefulWidget {
  const GpaCalculatorPage({Key? key}) : super(key: key);

  @override
  _GpaCalculatorPageState createState() => _GpaCalculatorPageState();
}

class _GpaCalculatorPageState extends State<GpaCalculatorPage> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _courses = [];
  double _currentGpa = 0.0;
  double _simulatedGpa = 0.0;
  bool _showWhatIf = false;
  
  @override
  void initState() {
    super.initState();
    _loadCourses();
  }
  
  Future<void> _loadCourses() async {
    setState(() {
      _isLoading = true;
    });
    
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    final userId = _authService.currentUser?.uid ?? '';
    
    if (userId.isNotEmpty) {
      try {
        // Get all courses
        final courses = await studentProvider.getCourses(userId);
        
        // Calculate current GPA
        final gpa = await studentProvider.calculateGPA(userId);
        
        setState(() {
          _courses = courses;
          _currentGpa = gpa;
          _simulatedGpa = gpa; // Start with current GPA for simulation
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading courses: $e')),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Calculate simulated GPA based on user-modified grades
  void _calculateSimulatedGPA() {
    double totalPoints = 0;
    double totalCredits = 0;
    
    for (var course in _courses) {
      if (course['Status'] == 'Completed' || course['SimulatedGrade'] != null) {
        final credits = course['Credits'] ?? 3.0; // Default to 3.0 credits
        final grade = course['SimulatedGrade'] ?? course['Final_grade'] ?? 0;
        
        if (grade > 0) {
          totalPoints += credits * grade;
          totalCredits += credits;
        }
      }
    }
    
    setState(() {
      _simulatedGpa = totalCredits > 0 ? totalPoints / totalCredits : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GPA Calculator'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadCourses,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading 
          ? Center(child: CircularProgressIndicator())
          : _courses.isEmpty
              ? _buildEmptyState()
              : _buildCalculator(),
      floatingActionButton: _courses.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _showWhatIf = !_showWhatIf;
                  
                  // Reset simulated grades when toggling off
                  if (!_showWhatIf) {
                    for (var course in _courses) {
                      course.remove('SimulatedGrade');
                    }
                    _simulatedGpa = _currentGpa;
                  }
                });
              },
              tooltip: _showWhatIf ? 'Exit Simulation' : 'What-If Simulator',
              child: Icon(
                _showWhatIf ? Icons.close : Icons.science,
              ),
            )
          : null,
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calculate,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No courses found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add courses to calculate your GPA',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCalculator() {
    return Column(
      children: [
        // GPA Display
        Container(
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                _showWhatIf ? 'What-If GPA Simulator' : 'Current GPA',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _showWhatIf 
                        ? _simulatedGpa.toStringAsFixed(2) 
                        : _currentGpa.toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '/ 100',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              if (_showWhatIf)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Current GPA: ${_currentGpa.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // Course list
        Expanded(
          child: ListView.builder(
            itemCount: _courses.length,
            itemBuilder: (context, index) {
              final course = _courses[index];
              return _buildCourseItem(course, index);
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildCourseItem(Map<String, dynamic> course, int index) {
    final isActive = course['Status'] == 'Active';
    final isCompleted = course['Status'] == 'Completed';
    final hasGrade = (course['Final_grade'] != null && course['Final_grade'] > 0) || 
                     course['SimulatedGrade'] != null;
    
    final displayGrade = course['SimulatedGrade'] ?? course['Final_grade'] ?? 0;
    final courseCredits = course['Credits'] ?? 3.0;
    
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        title: Text(
          course['Name'] ?? 'Unknown Course',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${course['Course_Id'] ?? ''} · ${courseCredits.toString()} credits'),
            if (_showWhatIf && (isActive || isCompleted))
              Slider(
                value: course['SimulatedGrade'] ?? course['Final_grade']?.toDouble() ?? 0,
                min: 0,
                max: 100,
                divisions: 100,
                label: (course['SimulatedGrade'] ?? course['Final_grade'] ?? 0).round().toString(),
                onChanged: (value) {
                  setState(() {
                    course['SimulatedGrade'] = value;
                    _calculateSimulatedGPA();
                  });
                },
              ),
          ],
        ),
        trailing: hasGrade
            ? Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getGradeColor(displayGrade),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  displayGrade.round().toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              )
            : course['SimulatedGrade'] != null
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getGradeColor(course['SimulatedGrade']),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      course['SimulatedGrade'].round().toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )
                : Text(
                    isActive ? 'In Progress' : 'No Grade',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
        enabled: _showWhatIf && (isActive || isCompleted),
      ),
    );
  }
  
  Color _getGradeColor(double grade) {
    if (grade >= 90) return Colors.green;
    if (grade >= 80) return Colors.lightGreen;
    if (grade >= 70) return Colors.amber;
    if (grade >= 60) return Colors.orange;
    if (grade >= 50) return Colors.deepOrange;
    return Colors.red;
  }
}