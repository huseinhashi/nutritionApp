import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:nutrition_app/providers/food_entry_provider.dart';
import 'package:nutrition_app/providers/language_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutrition_app/utils/AppColor.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MealHistoryTab extends StatefulWidget {
  const MealHistoryTab({super.key});

  @override
  State<MealHistoryTab> createState() => _MealHistoryTabState();
}

class _MealHistoryTabState extends State<MealHistoryTab> {
  @override
  void initState() {
    super.initState();
    // Fetch food entries when the tab is initialized
    Future.microtask(() {
      context.read<FoodEntryProvider>().fetchFoodEntries();
    });
  }

  Future<void> _refreshData() async {
    try {
      await context.read<FoodEntryProvider>().fetchFoodEntries();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${context.read<LanguageProvider>().getText('error_refreshing_data')}: $e',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showFoodDetailDialog(
    Map<String, dynamic> entry,
    LanguageProvider languageProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        entry['foodName'] ?? 'Unknown Food',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textPrimaryColor,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (entry['foodNameSomali'] != null)
                  Text(
                    'Somali: ${entry['foodNameSomali']}',
                    style: GoogleFonts.poppins(
                      color: textSecondaryColor,
                      fontSize: 14,
                    ),
                  ),
                const SizedBox(height: 16),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Food Image
                        if (entry['imageUrl'] != null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: entry['imageUrl']!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                height: 200,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 200,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(
                                    Icons.error,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Portion Size
                        if (entry['portionSize'] != null)
                          Text(
                            '${languageProvider.getText('portion_size')}: ${entry['portionSize']}',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: primaryColor,
                            ),
                          ),
                        const SizedBox(height: 16),

                        // Nutrition Details
                        Text(
                          languageProvider.getText('nutrition_info'),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Calories
                        _buildNutritionRow(
                          languageProvider.getText('calories'),
                          '${entry['calories']?.toStringAsFixed(0) ?? 'N/A'} cal',
                        ),

                        // Macronutrients
                        _buildNutritionRow(
                          'Protein',
                          '${entry['protein']?.toStringAsFixed(1) ?? 'N/A'}g',
                        ),
                        _buildNutritionRow(
                          'Carbohydrates',
                          '${entry['carbohydrates']?.toStringAsFixed(1) ?? 'N/A'}g',
                        ),
                        _buildNutritionRow(
                          'Fat',
                          '${entry['fat']?.toStringAsFixed(1) ?? 'N/A'}g',
                        ),

                        // Vitamins
                        _buildNutritionRow(
                          'Vitamin A',
                          '${entry['vitaminA']?.toStringAsFixed(1) ?? 'N/A'} μg',
                        ),
                        _buildNutritionRow(
                          'Vitamin C',
                          '${entry['vitaminC']?.toStringAsFixed(1) ?? 'N/A'} mg',
                        ),

                        // Minerals
                        _buildNutritionRow(
                          'Calcium',
                          '${entry['calcium']?.toStringAsFixed(1) ?? 'N/A'} mg',
                        ),
                        _buildNutritionRow(
                          'Iron',
                          '${entry['iron']?.toStringAsFixed(1) ?? 'N/A'} mg',
                        ),

                        const SizedBox(height: 16),

                        // Time
                        if (entry['createdAt'] != null)
                          Text(
                            'Added: ${DateFormat('MMM d, y h:mm a').format(DateTime.parse(entry['createdAt']))}',
                            style: GoogleFonts.poppins(
                              color: textSecondaryColor,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(color: textSecondaryColor, fontSize: 14),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealHistoryItem(
    Map<String, dynamic> entry,
    VoidCallback onDelete,
    LanguageProvider languageProvider,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _showFoodDetailDialog(entry, languageProvider),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Food Image or Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: entry['imageUrl'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: entry['imageUrl']!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Icon(Icons.fastfood, color: primaryColor),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.fastfood, color: primaryColor),
                        ),
                      )
                    : Icon(Icons.fastfood, color: primaryColor),
              ),
              const SizedBox(width: 12),
              // Food Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry['foodName'] ?? languageProvider.getText('unknown'),
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'P: ${entry['protein']?.toStringAsFixed(1) ?? '0'}g | '
                      'C: ${entry['carbohydrates']?.toStringAsFixed(1) ?? '0'}g | '
                      'F: ${entry['fat']?.toStringAsFixed(1) ?? '0'}g',
                      style: GoogleFonts.poppins(
                        color: textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${entry['calories']?.toStringAsFixed(0) ?? '0'} cal',
                    style: GoogleFonts.poppins(
                      color: primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: onDelete,
                    color: Colors.red,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    int entryId,
    String date,
    LanguageProvider languageProvider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(languageProvider.getText('delete')),
        content: Text(
          'Are you sure you want to delete this food entry? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(languageProvider.getText('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(languageProvider.getText('delete')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<FoodEntryProvider>().deleteFoodEntry(entryId, date);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                languageProvider.getText('food_entry_deleted_success'),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${languageProvider.getText('failed_delete_food_entry')}: $e',
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<FoodEntryProvider, LanguageProvider>(
      builder: (context, foodEntryProvider, languageProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              languageProvider.getText('meal_history'),
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            automaticallyImplyLeading: false,
          ),
          body: Builder(
            builder: (context) {
              if (foodEntryProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (foodEntryProvider.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${languageProvider.getText('error')}: ${foodEntryProvider.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          foodEntryProvider.clearError();
                          foodEntryProvider.fetchFoodEntries();
                        },
                        child: Text(languageProvider.getText('retry')),
                      ),
                    ],
                  ),
                );
              }

              if (foodEntryProvider.entries.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.restaurant, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        languageProvider.getText('no_meals'),
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        languageProvider.getText('start_tracking'),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _refreshData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Range Selector
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Today\'s Summary',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimaryColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Get today's data
                              Builder(
                                builder: (context) {
                                  final today = DateTime.now()
                                      .toIso8601String()
                                      .split('T')[0];
                                  final todayEntries =
                                      foodEntryProvider.entries[today] ?? [];
                                  final totalCalories = foodEntryProvider
                                      .getTotalCaloriesForDate(today);
                                  final totalMacros = foodEntryProvider
                                      .getTotalMacrosForDate(today);

                                  return Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          _buildSummaryItem(
                                            languageProvider.getText(
                                              'calories',
                                            ),
                                            '${totalCalories.toStringAsFixed(0)} cal',
                                            Icons.local_fire_department,
                                            Colors.orange,
                                          ),
                                          _buildSummaryItem(
                                            'Protein',
                                            '${totalMacros['protein']?.toStringAsFixed(1) ?? '0'}g',
                                            Icons.fitness_center,
                                            Colors.blue,
                                          ),
                                          _buildSummaryItem(
                                            'Carbs',
                                            '${totalMacros['carbs']?.toStringAsFixed(1) ?? '0'}g',
                                            Icons.grain,
                                            Colors.green,
                                          ),
                                          _buildSummaryItem(
                                            'Fat',
                                            '${totalMacros['fat']?.toStringAsFixed(1) ?? '0'}g',
                                            Icons.whatshot,
                                            Colors.red,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        '${todayEntries.length} ${todayEntries.length == 1 ? 'meal' : 'meals'} logged today',
                                        style: GoogleFonts.poppins(
                                          color: textSecondaryColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Today's Meals
                      Text(
                        'Today\'s Meals',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // List of today's meals
                      Builder(
                        builder: (context) {
                          final today = DateTime.now().toIso8601String().split(
                            'T',
                          )[0];
                          final todayEntries =
                              foodEntryProvider.entries[today] ?? [];

                          if (todayEntries.isEmpty) {
                            return Center(
                              child: Text(
                                'No meals logged today',
                                style: GoogleFonts.poppins(
                                  color: textSecondaryColor,
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: todayEntries.map((entry) {
                              return _buildMealHistoryItem(
                                entry,
                                () => _showDeleteConfirmation(
                                  context,
                                  entry['id'],
                                  today,
                                  languageProvider,
                                ),
                                languageProvider,
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textPrimaryColor,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: textSecondaryColor),
        ),
      ],
    );
  }
}
