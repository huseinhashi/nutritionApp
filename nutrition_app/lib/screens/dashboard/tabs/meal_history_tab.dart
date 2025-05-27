import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:nutrition_app/providers/food_entry_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutrition_app/utils/AppColor.dart';

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
            content: Text('Error refreshing data: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Meal History',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<FoodEntryProvider>(
        builder: (context, foodEntryProvider, _) {
          if (foodEntryProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (foodEntryProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${foodEntryProvider.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      foodEntryProvider.clearError();
                      foodEntryProvider.fetchFoodEntries();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (foodEntryProvider.entries.isEmpty) {
            return const Center(
              child: Text('No food entries yet. Add your first meal!'),
            );
          }

          // Get the first entry's date for the summary
          final firstDate = foodEntryProvider.entries.keys.first;
          final dailySummary = foodEntryProvider.entries[firstDate]!;
          final totalCalories =
              foodEntryProvider.getTotalCaloriesForDate(firstDate);
          final totalMacros =
              foodEntryProvider.getTotalMacrosForDate(firstDate);

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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('MMMM d, y')
                                .format(DateTime.parse(firstDate)),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              color: textPrimaryColor,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () {
                              // TODO: Implement date picker
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // // Nutrition Summary
                  // Text(
                  //   'Nutrition Summary',
                  //   style: GoogleFonts.poppins(
                  //     fontSize: 18,
                  //     fontWeight: FontWeight.bold,
                  //     color: textPrimaryColor,
                  //   ),
                  // ),
                  // const SizedBox(height: 16),
                  // Card(
                  //   elevation: 2,
                  //   shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.circular(12),
                  //   ),
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(16.0),
                  //     child: Column(
                  //       children: [
                  //         _buildNutritionSummaryItem(
                  //           label: 'Total Calories',
                  //           value: '${totalCalories.toStringAsFixed(0)}',
                  //           target: '2,000',
                  //           color: primaryColor,
                  //         ),
                  //         const Divider(height: 24),
                  //         _buildNutritionSummaryItem(
                  //           label: 'Total Protein',
                  //           value: '${totalMacros['protein']!.toStringAsFixed(1)}g',
                  //           target: '120g',
                  //           color: successColor,
                  //         ),
                  //         const Divider(height: 24),
                  //         _buildNutritionSummaryItem(
                  //           label: 'Total Carbs',
                  //           value: '${totalMacros['carbs']!.toStringAsFixed(1)}g',
                  //           target: '200g',
                  //           color: warningColor,
                  //         ),
                  //         const Divider(height: 24),
                  //         _buildNutritionSummaryItem(
                  //           label: 'Total Fat',
                  //           value: '${totalMacros['fat']!.toStringAsFixed(1)}g',
                  //           target: '60g',
                  //           color: accentColor,
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(height: 24),

                  // Meal History List
                  Text(
                    'Meal History',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: foodEntryProvider.entries.length,
                    itemBuilder: (context, index) {
                      final date =
                          foodEntryProvider.entries.keys.elementAt(index);
                      final entries = foodEntryProvider.entries[date]!;
                      final dateTotalCalories =
                          foodEntryProvider.getTotalCaloriesForDate(date);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(
                                DateFormat('EEEE, MMMM d')
                                    .format(DateTime.parse(date)),
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              trailing: Text(
                                '${dateTotalCalories.toStringAsFixed(0)} cal',
                                style: GoogleFonts.poppins(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Divider(height: 1),
                            ...entries.map((entry) => _buildMealHistoryItem(
                                  mealName: entry['foodName'],
                                  calories: entry['calories'].toString(),
                                  time: DateFormat('h:mm a').format(
                                    DateTime.parse(entry['createdAt']),
                                  ),
                                  macros: {
                                    'protein': entry['protein'],
                                    'carbs': entry['carbohydrates'],
                                    'fat': entry['fat'],
                                  },
                                  onDelete: () => _showDeleteConfirmation(
                                    context,
                                    entry['id'],
                                    date,
                                  ),
                                )),
                          ],
                        ),
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
  }

  Widget _buildNutritionSummaryItem({
    required String label,
    required String value,
    required String target,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                color: textSecondaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$value / $target',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: textPrimaryColor,
              ),
            ),
          ],
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.check_circle,
              color: color,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMealHistoryItem({
    required String mealName,
    required String calories,
    required String time,
    required Map<String, dynamic> macros,
    required VoidCallback onDelete,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 12.0,
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: GoogleFonts.poppins(
                    color: textSecondaryColor,
                    fontSize: 12,
                  ),
                ),
                Text(
                  mealName,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'P: ${macros['protein'].toStringAsFixed(1)}g | '
                  'C: ${macros['carbs'].toStringAsFixed(1)}g | '
                  'F: ${macros['fat'].toStringAsFixed(1)}g',
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
                '$calories cal',
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
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    int entryId,
    String date,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Food Entry'),
        content: const Text(
          'Are you sure you want to delete this food entry? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<FoodEntryProvider>().deleteFoodEntry(entryId, date);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Food entry deleted successfully'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete food entry: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }
}
