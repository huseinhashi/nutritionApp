import 'package:flutter/foundation.dart';
import 'package:nutrition_app/services/step_counter_service.dart';

class StepCounterProvider with ChangeNotifier {
  final StepCounterService _stepCounterService;
  bool _isInitialized = false;
  String? _error;

  StepCounterProvider(this._stepCounterService);

  bool get isInitialized => _isInitialized;
  String? get error => _error ?? _stepCounterService.error;

  // Initialize the step counter
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _stepCounterService.initialize();
      _isInitialized = true;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _isInitialized = false;
    }
    notifyListeners();
  }

  // Get current steps
  int getCurrentSteps() {
    return _stepCounterService.getCurrentSteps();
  }

  // Get today's date
  String getTodayDate() {
    return _stepCounterService.getTodayDate();
  }

  // Calculate progress percentage based on health profile goal
  double calculateProgress(int dailyGoal) {
    final currentSteps = getCurrentSteps();
    return (currentSteps / dailyGoal).clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    _stepCounterService.dispose();
    super.dispose();
  }
}
