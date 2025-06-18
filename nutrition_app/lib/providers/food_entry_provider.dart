import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:nutrition_app/services/food_entry_service.dart';

class FoodEntryProvider with ChangeNotifier {
  final FoodEntryService _foodEntryService;
  Map<String, List<Map<String, dynamic>>> _entries = {};
  bool _isLoading = false;
  String? _error;

  FoodEntryProvider(this._foodEntryService);

  // Getters
  Map<String, List<Map<String, dynamic>>> get entries => _entries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Helper function to safely convert to double
  double _safeToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }

  // Calculate total calories for a specific date
  double getTotalCaloriesForDate(String date) {
    if (!_entries.containsKey(date)) return 0;
    return _entries[date]!.fold<double>(
      0,
      (total, entry) => total + _safeToDouble(entry['calories']),
    );
  }

  // Calculate total macros for a specific date
  Map<String, double> getTotalMacrosForDate(String date) {
    if (!_entries.containsKey(date)) {
      return {'protein': 0, 'carbs': 0, 'fat': 0};
    }

    return _entries[date]!.fold<Map<String, double>>(
      {'protein': 0, 'carbs': 0, 'fat': 0},
      (totals, entry) {
        return {
          'protein': totals['protein']! + _safeToDouble(entry['protein']),
          'carbs': totals['carbs']! + _safeToDouble(entry['carbohydrates']),
          'fat': totals['fat']! + _safeToDouble(entry['fat']),
        };
      },
    );
  }

  // Add a new food entry
  Future<void> addFoodEntry({
    String? foodName,
    String? foodNameSomali,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _foodEntryService.addFoodEntry(
        foodName: foodName,
        foodNameSomali: foodNameSomali,
      );
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch food entries
  Future<void> fetchFoodEntries({
    String? startDate,
    String? endDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final entries = await _foodEntryService.getFoodEntries(
        startDate: startDate,
        endDate: endDate,
      );

      _entries = entries;
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a food entry
  Future<void> deleteFoodEntry(int id, String date) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _foodEntryService.deleteFoodEntry(id);

      // Remove the entry from the local state
      if (_entries.containsKey(date)) {
        _entries[date]!.removeWhere((entry) => entry['id'] == id);
        if (_entries[date]!.isEmpty) {
          _entries.remove(date);
        }
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Add food entry from image
  Future<List<Map<String, dynamic>>> addFoodEntryFromImage(
      File imageFile) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _foodEntryService.addFoodEntryFromImage(imageFile);
      await fetchFoodEntries(); // Refresh entries after adding
      return result;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
