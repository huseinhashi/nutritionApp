class NutritionResource {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String? videoId;
  final String? articleUrl;
  final String category;
  final DateTime dateAdded;

  NutritionResource({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.videoId,
    this.articleUrl,
    required this.category,
    required this.dateAdded,
  });
}

// Sample data for nutrition resources
final List<NutritionResource> nutritionResources = [
  // Videos - Fixed: Using only video IDs instead of full URLs
  NutritionResource(
    id: 'v1',
    title: 'Cuntooyinka La Isticmaalo Si Looga Faaiideysto Caafimaadkaaga',
    description:
        'Waxaa lagu sharxi doonaa sida loo isticmaalo cuntooyinka si looga faaiideysto caafimaadkaaga.',
    videoId: 'I1dv2bOYhds', // Just the video ID
    category: 'video',
    dateAdded: DateTime(2024, 3, 1),
  ),
  NutritionResource(
    id: 'v2',
    title: 'Sida Looga Dhigto Cuntadaada Mid La Isticmaalo',
    description:
        'Waxaa lagu sharxi doonaa sida loo sameeyo cuntooyin la isticmaalo oo la isticmaalo.',
    videoId: 'I1dv2bOYhds', // Just the video ID
    category: 'video',
    dateAdded: DateTime(2024, 3, 2),
  ),
  // Add more videos with proper video IDs here...

  // Articles
  NutritionResource(
    id: 'a1',
    title: 'Muhiimadda Cuntada La Isticmaalo',
    description:
        'Maqaal ku saabsan muhiimadda cuntada la isticmaalo iyo sida ay u saameeyaan caafimaadkaaga.',
    articleUrl: 'https://jn.nutrition.org/',
    category: 'article',
    dateAdded: DateTime(2024, 3, 1),
  ),
  NutritionResource(
    id: 'a2',
    title: 'Sida Looga Dhigto Cuntadaada Mid La Isticmaalo',
    description:
        'Maqaal ku saabsan sida loo sameeyo cuntooyin la isticmaalo oo la isticmaalo.',
    articleUrl: 'https://pmc.ncbi.nlm.nih.gov/articles/PMC9785741/',
    category: 'article',
    dateAdded: DateTime(2024, 3, 2),
  ),
  // Add more articles here...
];

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

// Helper function to get resources by category
List<NutritionResource> getResourcesByCategory(String category) {
  return nutritionResources
      .where((resource) => resource.category == category)
      .toList();
}

// Helper function to get resources by search query
List<NutritionResource> searchResources(String query) {
  final lowercaseQuery = query.toLowerCase();
  return nutritionResources.where((resource) {
    return resource.title.toLowerCase().contains(lowercaseQuery) ||
        resource.description.toLowerCase().contains(lowercaseQuery);
  }).toList();
}
