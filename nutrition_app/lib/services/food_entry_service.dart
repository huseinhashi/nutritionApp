import 'package:nutrition_app/services/api_client.dart';

class FoodEntryService {
  final ApiClient _apiClient;

  FoodEntryService(this._apiClient);

  Future<void> addFoodEntry({
    String? foodName,
    String? foodNameSomali,
  }) async {
    try {
      final response = await _apiClient.request(
        method: 'POST',
        path: '/food-entries',
        data: {
          if (foodName != null && foodName.isNotEmpty) 'food_name': foodName,
          if (foodNameSomali != null && foodNameSomali.isNotEmpty)
            'food_name_somali': foodNameSomali,
        },
      );

      if (!response['success']) {
        throw Exception(response['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>> getFoodEntries({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final Map<String, dynamic>? queryParams;
      if (startDate != null || endDate != null) {
        queryParams = {};
        if (startDate != null) queryParams['startDate'] = startDate;
        if (endDate != null) queryParams['endDate'] = endDate;
      } else {
        queryParams = null;
      }

      final response = await _apiClient.request(
        method: 'GET',
        path: '/food-entries',
        queryParameters: queryParams,
      );

      if (!response['success']) {
        throw Exception(response['message']);
      }

      // The backend returns entries in the data.entries field
      final Map<String, dynamic> entries = response['data']['entries'];

      // Convert the entries to the expected format
      final Map<String, List<Map<String, dynamic>>> groupedEntries = {};

      entries.forEach((date, entryList) {
        if (entryList is List) {
          groupedEntries[date] = entryList
              .map((entry) => Map<String, dynamic>.from(entry))
              .toList();
        }
      });

      return groupedEntries;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteFoodEntry(int id) async {
    try {
      final response = await _apiClient.request(
        method: 'DELETE',
        path: '/food-entries/$id',
      );

      if (!response['success']) {
        throw Exception(response['message']);
      }
    } catch (e) {
      rethrow;
    }
  }
}
