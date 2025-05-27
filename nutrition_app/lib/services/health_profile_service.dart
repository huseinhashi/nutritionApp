import 'package:nutrition_app/services/api_client.dart';

class HealthProfileService {
  final ApiClient _apiClient;

  HealthProfileService(this._apiClient);

  Future<Map<String, dynamic>> createOrUpdateProfile({
    required int age,
    required String gender,
    required double weight,
    required double height,
    required String goal,
    required String activityLevel,
  }) async {
    try {
      final response = await _apiClient.request(
        method: 'POST',
        path: '/health-profile',
        data: {
          'age': age,
          'gender': gender,
          'weight': weight,
          'height': height,
          'goal': goal,
          'activityLevel': activityLevel, // <-- Make sure this is included!
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

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _apiClient.request(
        method: 'GET',
        path: '/health-profile',
      );

      if (!response['success']) {
        throw Exception(response['message']);
      }

      return response['data'];
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> hasProfile() async {
    try {
      await getProfile();
      return true;
    } catch (e) {
      return false;
    }
  }
}
