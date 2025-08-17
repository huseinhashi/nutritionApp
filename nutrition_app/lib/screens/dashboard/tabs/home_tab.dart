import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nutrition_app/providers/health_profile_provider.dart';
import 'package:nutrition_app/providers/food_entry_provider.dart';
import 'package:nutrition_app/providers/water_intake_provider.dart';
import 'package:nutrition_app/providers/step_counter_provider.dart';
import 'package:nutrition_app/providers/language_provider.dart';
import 'package:nutrition_app/screens/health_profile_form_screen.dart';
import 'package:nutrition_app/screens/log_meal_screen.dart';
import 'package:nutrition_app/utils/AppColor.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  void initState() {
    super.initState();
    // Fetch data when the tab is initialized
    Future.microtask(() {
      context.read<FoodEntryProvider>().fetchFoodEntries();
      context.read<WaterIntakeProvider>().fetchWaterIntake();
      context.read<StepCounterProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer5<
      HealthProfileProvider,
      FoodEntryProvider,
      WaterIntakeProvider,
      StepCounterProvider,
      LanguageProvider
    >(
      builder:
          (
            context,
            healthProfileProvider,
            foodEntryProvider,
            waterIntakeProvider,
            stepCounterProvider,
            languageProvider,
            child,
          ) {
            // Show loading indicator while checking profile
            if (healthProfileProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Show profile completion prompt if profile doesn't exist
            if (!healthProfileProvider.hasProfile) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.health_and_safety,
                        size: 80,
                        color: primaryColor.withOpacity(0.5),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        languageProvider.getText('complete_profile_title'),
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        languageProvider.getText('complete_profile_desc'),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const HealthProfileFormScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(
                          languageProvider.getText('complete_profile'),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Show normal home content if profile exists
            final healthProfile = healthProfileProvider.profile!;

            // Get actual data from providers
            final todayCalories = foodEntryProvider.getTodayTotalCalories();
            final todayWaterMl = waterIntakeProvider.getTodayTotalMl();
            final todaySteps = stepCounterProvider.getCurrentSteps();

            // Get targets from health profile
            final targetCalories = healthProfile['dailyCalories'] ?? 2000;
            final targetWaterMl = healthProfile['dailyWaterMl'] ?? 2500;
            final targetSteps = healthProfile['dailySteps'] ?? 10000;

            return Scaffold(
              appBar: AppBar(
                title: Text(
                  languageProvider.getText('home'),
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                automaticallyImplyLeading: false,
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Daily Summary Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              languageProvider.getText('daily_summary'),
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildSummaryItem(
                                  context,
                                  languageProvider.getText('calories'),
                                  todayCalories.toStringAsFixed(0),
                                  targetCalories.toString(),
                                  Icons.local_fire_department,
                                  Colors.orange,
                                  todayCalories / targetCalories,
                                  languageProvider,
                                ),
                                _buildSummaryItem(
                                  context,
                                  languageProvider.getText('water_intake'),
                                  '${todayWaterMl.toStringAsFixed(0)}ml',
                                  '${targetWaterMl}ml',
                                  Icons.water_drop,
                                  Colors.blue,
                                  todayWaterMl / targetWaterMl,
                                  languageProvider,
                                ),
                                _buildSummaryItem(
                                  context,
                                  languageProvider.getText('steps_count'),
                                  todaySteps.toString(),
                                  targetSteps.toString(),
                                  Icons.directions_walk,
                                  Colors.green,
                                  todaySteps / targetSteps,
                                  languageProvider,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Quick Actions Section
                    Text(
                      languageProvider.getText('quick_actions'),
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionButton(
                            context,
                            languageProvider.getText('log_meal'),
                            Icons.add_circle_outline,
                            primaryColor,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LogMealScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String title,
    String current,
    String target,
    IconData icon,
    Color color,
    double progress,
    LanguageProvider languageProvider,
  ) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                strokeWidth: 4,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Icon(icon, color: color, size: 24),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          current,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        Text(
          '${languageProvider.getText('of')} $target',
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
        ),
        Text(
          '${(progress * 100).clamp(0.0, 100.0).toStringAsFixed(0)}%',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: progress >= 1.0 ? Colors.green : color,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
