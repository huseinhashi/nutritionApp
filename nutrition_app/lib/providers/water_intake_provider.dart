import 'package:flutter/foundation.dart';
import 'package:nutrition_app/services/water_intake_service.dart';

class WaterIntakeProvider with ChangeNotifier {
  final WaterIntakeService _waterIntakeService;
  Map<String, List<dynamic>>? _entries;
  bool _isLoading = false;
  String? _error;

  WaterIntakeProvider(this._waterIntakeService);

  Map<String, List<dynamic>>? get entries => _entries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Add water intake
  Future<void> addWaterIntake({
    required double intakeAmount,
    required String intakeDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _waterIntakeService.addWaterIntake(
        intakeAmount: intakeAmount,
        intakeDate: intakeDate,
      );
      await fetchWaterIntake(); // Refresh the list
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch water intake entries
  Future<void> fetchWaterIntake({String? startDate, String? endDate}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _entries = await _waterIntakeService.getWaterIntake(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      _error = e.toString();
      _entries = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete water intake entry
  Future<void> deleteWaterIntake(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _waterIntakeService.deleteWaterIntake(id);
      await fetchWaterIntake(); // Refresh the list
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get today's total water intake
  double getTodayTotal() {
    if (_entries == null) return 0;

    final today = DateTime.now().toIso8601String().split('T')[0];
    final todayEntries = _entries![today];

    if (todayEntries == null) return 0;

    return todayEntries.fold<double>(
      0,
      (sum, entry) => sum + (entry['intakeAmount'] as double),
    );
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
