import 'package:nutrition_app/services/api_client.dart';

class WaterIntakeService {
  final ApiClient _apiClient;

  WaterIntakeService(this._apiClient);

  // Add water intake
  Future<Map<String, dynamic>> addWaterIntake({
    required double intakeAmount,
    required String intakeDate,
  }) async {
    try {
      final response = await _apiClient.request(
        method: 'POST',
        path: '/water-intake',
        data: {
          'intake_amount': intakeAmount,
          'intake_date': intakeDate,
        },
      );

      if (!response['success']) {
        throw Exception(response['message']);
      }

      return response['data'];
    } catch (e) {
      rethrow;
    }
  }

  // Get water intake entries
  Future<Map<String, List<dynamic>>> getWaterIntake({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final Map<String, dynamic>? queryParams;
      if (startDate != null && endDate != null) {
        queryParams = {
          'start_date': startDate,
          'end_date': endDate,
        };
      } else {
        queryParams = null;
      }

      final response = await _apiClient.request(
        method: 'GET',
        path: '/water-intake',
        queryParameters: queryParams,
      );

      if (!response['success']) {
        throw Exception(response['message']);
      }

      // Convert the response data to the expected format
      final Map<String, List<dynamic>> groupedEntries = {};
      final Map<String, dynamic> data = response['data'];

      data.forEach((date, entries) {
        groupedEntries[date] = List<dynamic>.from(entries);
      });

      return groupedEntries;
    } catch (e) {
      rethrow;
    }
  }

  // Delete water intake entry
  Future<void> deleteWaterIntake(int id) async {
    try {
      final response = await _apiClient.request(
        method: 'DELETE',
        path: '/water-intake/$id',
      );

      if (!response['success']) {
        throw Exception(response['message']);
      }
    } catch (e) {
      rethrow;
    }
  }
}
