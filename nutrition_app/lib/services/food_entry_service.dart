import 'dart:io';
import 'package:nutrition_app/services/api_client.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

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

  Future<List<Map<String, dynamic>>> addFoodEntryFromImage(
      File imageFile) async {
    try {
      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${_apiClient.baseUrl}/food-entries/image'),
      );

      // Add image file
      final stream = http.ByteStream(imageFile.openRead());
      final length = await imageFile.length();
      final multipartFile = http.MultipartFile(
        'image',
        stream,
        length,
        filename: 'food_image.jpg',
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(multipartFile);

      // Add authorization header
      final headers = _apiClient.headers.map(
        (key, value) => MapEntry(key, value.toString()),
      );
      request.headers.addAll(headers);

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to analyze image');
      }

      // Parse successful response
      final responseData = json.decode(response.body);
      print('Response data: $responseData'); // Debug log

      if (!responseData['success']) {
        throw Exception(responseData['message'] ?? 'Failed to process image');
      }

      // Get the food entries directly from data
      final foodEntries = responseData['data'];
      print('Food entries: $foodEntries'); // Debug log

      if (foodEntries == null || !(foodEntries is List)) {
        print('No food entries found or invalid format'); // Debug log
        return [];
      }

      // Transform the data to match the UI requirements
      final transformedEntries = foodEntries.map((item) {
        print('Processing item: $item'); // Debug log
        return {
          'name': item['foodName'] ?? 'Unknown',
          'namesom': item['foodNameSomali'] ?? 'Unknown',
          'portionsize': item['portionSize'] ?? 'N/A',
          'calories': item['calories']?.toDouble() ?? 0.0,
          'protein': item['protein']?.toDouble() ?? 0.0,
          'carbs': item['carbohydrates']?.toDouble() ?? 0.0,
          'fat': item['fat']?.toDouble() ?? 0.0,
        };
      }).toList();

      print('Transformed entries: $transformedEntries'); // Debug log
      return transformedEntries;
    } catch (e) {
      print('Error in addFoodEntryFromImage: $e'); // Debug log
      rethrow;
    }
  }
}
