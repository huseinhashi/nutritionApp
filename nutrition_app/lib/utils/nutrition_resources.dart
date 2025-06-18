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
}

// Sample data for nutrition resources
final List<NutritionResource> nutritionResources = [
  // Videos
  NutritionResource(
    id: 'v1',
    title: 'Cuntooyinka La Isticmaalo Si Looga Faaiideysto Caafimaadkaaga',
    description:
        'Waxaa lagu sharxi doonaa sida loo isticmaalo cuntooyinka si looga faaiideysto caafimaadkaaga.',
    videoId: 'I1dv2bOYhds',
    category: 'weight_loss',
    resourceType: 'video',
    tags: ['weight_loss', 'healthy_eating', 'nutrition'],
    dateAdded: DateTime(2024, 3, 1),
  ),
  NutritionResource(
    id: 'v2',
    title: 'Sida Looga Dhigto Cuntadaada Mid La Isticmaalo',
    description:
        'Waxaa lagu sharxi doonaa sida loo sameeyo cuntooyin la isticmaalo oo la isticmaalo.',
    videoId: 'I1dv2bOYhds',
    category: 'muscle_gain',
    resourceType: 'video',
    tags: ['muscle_gain', 'protein', 'workout'],
    dateAdded: DateTime(2024, 3, 2),
  ),
  NutritionResource(
    id: 'v3',
    title: 'Healthy Meal Planning for Weight Management',
    description:
        'Learn how to plan your meals for effective weight management.',
    videoId: 'I1dv2bOYhds',
    category: 'weight_loss',
    resourceType: 'video',
    tags: ['weight_loss', 'meal_planning', 'healthy_eating'],
    dateAdded: DateTime(2024, 3, 3),
  ),

  // Articles
  NutritionResource(
    id: 'a1',
    title: 'Muhiimadda Cuntada La Isticmaalo',
    description:
        'Maqaal ku saabsan muhiimadda cuntada la isticmaalo iyo sida ay u saameeyaan caafimaadkaaga.',
    articleUrl: 'https://jn.nutrition.org/',
    category: 'healthy_eating',
    resourceType: 'article',
    tags: ['healthy_eating', 'nutrition', 'wellness'],
    dateAdded: DateTime(2024, 3, 1),
  ),
  NutritionResource(
    id: 'a2',
    title: 'Sida Looga Dhigto Cuntadaada Mid La Isticmaalo',
    description:
        'Maqaal ku saabsan sida loo sameeyo cuntooyin la isticmaalo oo la isticmaalo.',
    articleUrl: 'https://pmc.ncbi.nlm.nih.gov/articles/PMC9785741/',
    category: 'muscle_gain',
    resourceType: 'article',
    tags: ['muscle_gain', 'protein', 'nutrition'],
    dateAdded: DateTime(2024, 3, 2),
  ),
  NutritionResource(
    id: 'a3',
    title: 'Weight Loss Strategies That Work',
    description: 'Evidence-based strategies for sustainable weight loss.',
    articleUrl: 'https://example.com/weight-loss',
    category: 'weight_loss',
    resourceType: 'article',
    tags: ['weight_loss', 'diet', 'exercise'],
    dateAdded: DateTime(2024, 3, 3),
  ),
];

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
  return nutritionResources
      .where((resource) => resource.category == category)
      .toList();
}

// Helper function to get resources by type
List<NutritionResource> getResourcesByType(String type) {
  return nutritionResources
      .where((resource) => resource.resourceType == type)
      .toList();
}

// Helper function to get resources by search query
List<NutritionResource> searchResources(String query) {
  final lowercaseQuery = query.toLowerCase();
  return nutritionResources.where((resource) {
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
  var resources = nutritionResources;

  if (category != null) {
    resources = resources.where((r) => r.category == category).toList();
  }

  if (type != null) {
    resources = resources.where((r) => r.resourceType == type).toList();
  }

  if (searchQuery != null && searchQuery.isNotEmpty) {
    resources = searchResources(searchQuery)
        .where((r) => resources.contains(r))
        .toList();
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
