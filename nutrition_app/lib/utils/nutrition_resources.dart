import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class NutritionResource {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String? videoId;
  final String? articleUrl;
  final String category;
  final String resourceType;
  final List<String> tags;
  final DateTime dateAdded;

  NutritionResource({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.videoId,
    this.articleUrl,
    required this.category,
    required this.resourceType,
    required this.tags,
    required this.dateAdded,
  });

  factory NutritionResource.fromJson(Map<String, dynamic> json) {
    return NutritionResource(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
      videoId: json['videoId'],
      articleUrl: json['articleUrl'],
      category: json['category'],
      resourceType: json['resourceType'],
      tags: (json['tags'] as List).map((e) => e.toString()).toList(),
      dateAdded: DateTime.parse(json['dateAdded']),
    );
  }
}

// Global variable to store loaded resources
List<NutritionResource> _nutritionResources = [];

// Load nutrition resources from JSON file
Future<List<NutritionResource>> loadNutritionResources() async {
  if (_nutritionResources.isNotEmpty) {
    return _nutritionResources;
  }

  try {
    final raw = await rootBundle.loadString(
      'assets/data/nutrition_resources.json',
    );
    final decoded = json.decode(raw) as Map<String, dynamic>;
    final list = (decoded['resources'] as List)
        .map((e) => NutritionResource.fromJson(e as Map<String, dynamic>))
        .toList();

    // Sort newest first
    list.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));

    _nutritionResources = list;
    return list;
  } catch (e) {
    print('Error loading nutrition resources: $e');
    return [];
  }
}

// Get all loaded resources
List<NutritionResource> get nutritionResources => _nutritionResources;

// Available categories
final List<String> resourceCategories = [
  'weight_loss',
  'muscle_gain',
  'healthy_eating',
  'meal_planning',
  'nutrition',
  'exercise',
];

// Helper function to get category display name
String getCategoryDisplayName(String category) {
  switch (category) {
    case 'weight_loss':
      return 'Weight Loss';
    case 'muscle_gain':
      return 'Muscle Gain';
    case 'healthy_eating':
      return 'Healthy Eating';
    case 'meal_planning':
      return 'Meal Planning';
    case 'nutrition':
      return 'Nutrition';
    case 'exercise':
      return 'Exercise';
    default:
      return category;
  }
}

// Helper function to get resources by category
List<NutritionResource> getResourcesByCategory(String category) {
  return _nutritionResources
      .where((resource) => resource.category == category)
      .toList();
}

// Helper function to get resources by type
List<NutritionResource> getResourcesByType(String type) {
  return _nutritionResources
      .where((resource) => resource.resourceType == type)
      .toList();
}

// Helper function to get resources by search query
List<NutritionResource> searchResources(String query) {
  final lowercaseQuery = query.toLowerCase();
  return _nutritionResources.where((resource) {
    return resource.title.toLowerCase().contains(lowercaseQuery) ||
        resource.description.toLowerCase().contains(lowercaseQuery) ||
        resource.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
  }).toList();
}

// Helper function to get filtered resources
List<NutritionResource> getFilteredResources({
  String? category,
  String? type,
  String? searchQuery,
}) {
  var resources = _nutritionResources;

  if (category != null) {
    resources = resources.where((r) => r.category == category).toList();
  }

  if (type != null) {
    resources = resources.where((r) => r.resourceType == type).toList();
  }

  if (searchQuery != null && searchQuery.isNotEmpty) {
    resources = searchResources(
      searchQuery,
    ).where((r) => resources.contains(r)).toList();
  }

  return resources;
}

// Helper function to extract video ID from YouTube URL
String extractVideoIdFromUrl(String url) {
  // Handle different YouTube URL formats
  final regExp = RegExp(
    r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
    caseSensitive: false,
  );
  final match = regExp.firstMatch(url);
  return match?.group(1) ?? '';
}

// Helper function to get YouTube thumbnail URL
String getYouTubeThumbnailUrl(String videoId) {
  return 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
}

// Helper function to get YouTube video URL
String getYouTubeVideoUrl(String videoId) {
  return 'https://www.youtube.com/watch?v=$videoId';
}
