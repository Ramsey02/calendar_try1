// utils/network_util.dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class NetworkUtil with ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  bool _isConnected = true;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  // Constructor
  NetworkUtil() {
    _initConnectivity();
    _connectivitySubscription = 
        _connectivity.onConnectivityChanged.listen((results) {
      if (results.isNotEmpty) {
        _updateConnectionStatus(results.first);
      }
    });
  }

  // Getters
  bool get isConnected => _isConnected;

  // Initialize connectivity checking
  Future<void> _initConnectivity() async {
    List<ConnectivityResult> results;
    try {
      results = await _connectivity.checkConnectivity();
      if (results.isNotEmpty) {
        _updateConnectionStatus(results.first);
      }
    } catch (e) {
      debugPrint('Connectivity check failed: $e');
      _isConnected = false;
      notifyListeners();
    }
  }

  // Update connection status based on connectivity result
  void _updateConnectionStatus(ConnectivityResult result) {
    final wasConnected = _isConnected;
    
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.ethernet:
        _isConnected = true;
        break;
      default:
        _isConnected = false;
        break;
    }
    
    // Only notify if there was a change
    if (wasConnected != _isConnected) {
      notifyListeners();
    }
  }

  // Dispose resources
  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}