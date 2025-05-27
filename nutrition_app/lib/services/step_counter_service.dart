import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:pedometer/pedometer.dart';

class StepCounterService {
  static const String _stepsKey = 'daily_steps';
  static const String _lastResetDateKey = 'last_steps_reset_date';

  final Pedometer _pedometer = Pedometer();
  StreamSubscription<StepCount>? _stepCountSubscription;
  StreamSubscription<PedestrianStatus>? _pedestrianStatusSubscription;

  int _currentSteps = 0;
  DateTime _lastResetDate = DateTime.now();

  // Initialize the service and load saved data
  Future<void> initialize() async {
    await _loadSavedData();
    await _checkAndResetDailySteps();
    _startListening();
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
  void _startListening() {
    _stepCountSubscription?.cancel();
    _stepCountSubscription = Pedometer.stepCountStream.listen(
      (StepCount event) async {
        _currentSteps = event.steps;
        await _saveData();
      },
      onError: (error) {
        print('Error getting step count: $error');
      },
    );

    _pedestrianStatusSubscription?.cancel();
    _pedestrianStatusSubscription = Pedometer.pedestrianStatusStream.listen(
      (PedestrianStatus event) {
        // Handle pedestrian status if needed
      },
      onError: (error) {
        print('Error getting pedestrian status: $error');
      },
    );
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
  void dispose() {
    _stepCountSubscription?.cancel();
    _pedestrianStatusSubscription?.cancel();
  }
}
