import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

class StepCounterService {
  static const String _stepsKey = 'daily_steps';
  static const String _lastResetDateKey = 'last_steps_reset_date';

  Stream<StepCount>? _stepCountStream;
  Stream<PedestrianStatus>? _pedestrianStatusStream;
  StreamSubscription<StepCount>? _stepCountSubscription;
  StreamSubscription<PedestrianStatus>? _pedestrianStatusSubscription;

  int _currentSteps = 0;
  DateTime _lastResetDate = DateTime.now();
  String? _error;

  String? get error => _error;

  // Initialize the service and load saved data
  Future<void> initialize() async {
    try {
      // Request permissions first
      await _requestPermissions();

      await _loadSavedData();
      await _checkAndResetDailySteps();
      await _startListening();
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  // Request necessary permissions
  Future<void> _requestPermissions() async {
    if (await Permission.activityRecognition.request().isGranted) {
      print('Activity recognition permission granted');
    } else {
      throw Exception('Activity recognition permission not granted');
    }
  }

  // Load saved steps and last reset date
  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    _currentSteps = prefs.getInt(_stepsKey) ?? 0;
    final lastResetDateStr = prefs.getString(_lastResetDateKey);
    if (lastResetDateStr != null) {
      _lastResetDate = DateTime.parse(lastResetDateStr);
    }
  }

  // Save current steps and last reset date
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_stepsKey, _currentSteps);
    await prefs.setString(_lastResetDateKey, _lastResetDate.toIso8601String());
  }

  // Check if we need to reset steps for a new day
  Future<void> _checkAndResetDailySteps() async {
    final now = DateTime.now();
    if (!_isSameDay(now, _lastResetDate)) {
      _currentSteps = 0;
      _lastResetDate = now;
      await _saveData();
    }
  }

  // Start listening to step count updates
  Future<void> _startListening() async {
    try {
      // Cancel existing subscriptions
      await _stepCountSubscription?.cancel();
      await _pedestrianStatusSubscription?.cancel();

      // Initialize streams
      _stepCountStream = Pedometer.stepCountStream;
      _pedestrianStatusStream = Pedometer.pedestrianStatusStream;

      // Listen to step count stream
      _stepCountSubscription = _stepCountStream?.listen(
        (StepCount event) async {
          print('Step count event received: ${event.steps}');
          _currentSteps = event.steps;
          await _saveData();
        },
        onError: (error) {
          _error = 'Error getting step count: $error';
          print(_error);
        },
      );

      // Listen to pedestrian status stream
      _pedestrianStatusSubscription = _pedestrianStatusStream?.listen(
        (PedestrianStatus event) {
          print('Pedestrian status: ${event.status}');
        },
        onError: (error) {
          print('Error getting pedestrian status: $error');
        },
      );
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  // Get current step count
  int getCurrentSteps() {
    return _currentSteps;
  }

  // Get today's date
  String getTodayDate() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  // Check if two dates are the same day
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Dispose of subscriptions
  Future<void> dispose() async {
    await _stepCountSubscription?.cancel();
    await _pedestrianStatusSubscription?.cancel();
  }
}
