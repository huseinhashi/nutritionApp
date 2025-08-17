import 'dart:io';
import 'package:nutrition_app/services/api_client.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

class FoodEntryService {
  final ApiClient _apiClient;

  FoodEntryService(this._apiClient);

  // Helper method to get image URL
  String? getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      print('DEBUG: imagePath is null or empty: $imagePath');
      return null;
    }

    // Extract filename from path
    final filename = imagePath.split('/').last;
    // Use direct image route without API versioning
    final baseUrl = _apiClient.baseUrl.replaceAll('/api/v1', '');
    final imageUrl = '$baseUrl/images/$filename';
    print('DEBUG: Converting imagePath: $imagePath to imageUrl: $imageUrl');
    print('DEBUG: Base URL: $baseUrl');
    print('DEBUG: Filename extracted: $filename');
    return imageUrl;
  }

  Future<void> addFoodEntry({String? foodName, String? foodNameSomali}) async {
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
          groupedEntries[date] = entryList.map((entry) {
            final Map<String, dynamic> mappedEntry = Map<String, dynamic>.from(
              entry,
            );
            // Add image URL if imagePath exists
            if (mappedEntry['imagePath'] != null) {
              print('DEBUG: Found imagePath: ${mappedEntry['imagePath']}');
              mappedEntry['imageUrl'] = getImageUrl(mappedEntry['imagePath']);
              print('DEBUG: Generated imageUrl: ${mappedEntry['imageUrl']}');
            } else {
              print(
                'DEBUG: No imagePath found for entry: ${mappedEntry['foodName']}',
              );
            }
            return mappedEntry;
          }).toList();
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
    File imageFile,
  ) async {
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

      // Transform the data to match the UI requirements with all nutrition data
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
          'vitaminA': item['vitaminA']?.toDouble() ?? 0.0,
          'vitaminC': item['vitaminC']?.toDouble() ?? 0.0,
          'calcium': item['calcium']?.toDouble() ?? 0.0,
          'iron': item['iron']?.toDouble() ?? 0.0,
          'imageUrl': getImageUrl(item['imagePath']),
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
