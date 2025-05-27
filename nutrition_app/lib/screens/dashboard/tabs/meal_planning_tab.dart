import 'package:flutter/material.dart';
import 'package:nutrition_app/utils/AppColor.dart';
import 'package:google_fonts/google_fonts.dart';

class MealPlanningTab extends StatelessWidget {
  const MealPlanningTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Meal Planning',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false, // This disables the back button

        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to create meal plan screen
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Meal Plan Card
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Current Meal Plan',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textPrimaryColor,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Weight Loss',
                            style: GoogleFonts.poppins(
                              color: primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Week of March 18 - March 24',
                      style: GoogleFonts.poppins(
                        color: textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildMealPlanProgress(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Weekly Schedule
            Text(
              'Weekly Schedule',
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
              itemCount: 7,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ExpansionTile(
                    title: Text(
                      _getDayName(index),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    children: [
                      _buildMealItem(
                        mealType: 'Breakfast',
                        mealName: 'Oatmeal with Berries',
                        calories: '350',
                        time: '8:00 AM',
                      ),
                      _buildMealItem(
                        mealType: 'Lunch',
                        mealName: 'Grilled Chicken Salad',
                        calories: '450',
                        time: '12:30 PM',
                      ),
                      _buildMealItem(
                        mealType: 'Dinner',
                        mealName: 'Salmon with Vegetables',
                        calories: '550',
                        time: '7:00 PM',
                      ),
                      _buildMealItem(
                        mealType: 'Snack',
                        mealName: 'Greek Yogurt with Nuts',
                        calories: '200',
                        time: '3:00 PM',
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealPlanProgress() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daily Target',
              style: GoogleFonts.poppins(
                color: textSecondaryColor,
              ),
            ),
            Text(
              '1,800 / 2,000 cal',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: 0.9,
          backgroundColor: primaryColor.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          borderRadius: BorderRadius.circular(4),
          minHeight: 8,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMacroItem('Protein', '120g', '45%'),
            _buildMacroItem('Carbs', '200g', '40%'),
            _buildMacroItem('Fat', '60g', '15%'),
          ],
        ),
      ],
    );
  }

  Widget _buildMacroItem(String label, String value, String percentage) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: textSecondaryColor,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: textPrimaryColor,
          ),
        ),
        Text(
          percentage,
          style: GoogleFonts.poppins(
            color: primaryColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMealItem({
    required String mealType,
    required String mealName,
    required String calories,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
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
                  mealType,
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
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: GoogleFonts.poppins(
                  color: textSecondaryColor,
                  fontSize: 12,
                ),
              ),
              Text(
                '$calories cal',
                style: GoogleFonts.poppins(
                  color: primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getDayName(int index) {
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[index];
  }
}
