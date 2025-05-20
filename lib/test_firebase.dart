// test_firebase.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseTest extends StatefulWidget {
  @override
  _FirebaseTestState createState() => _FirebaseTestState();
}

class _FirebaseTestState extends State<FirebaseTest> {
  String _result = "Testing...";

  @override
  void initState() {
    super.initState();
    _testFirebase();
  }

  Future<void> _testFirebase() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('students')
          .doc('user123')
          .get();
      
      if (doc.exists) {
        setState(() {
          _result = "Successfully connected! Student name: ${doc.data()?['Name'] ?? 'No name found'}";
        });
      } else {
        setState(() {
          _result = "Connected but document not found";
        });
      }
    } catch (e) {
      setState(() {
        _result = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Firebase Test")),
      body: Center(child: Text(_result)),
    );
  }
}