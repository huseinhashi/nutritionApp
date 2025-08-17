import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nutrition_app/providers/auth_provider.dart';
import 'package:nutrition_app/providers/health_profile_provider.dart';
import 'package:nutrition_app/providers/food_entry_provider.dart';
import 'package:nutrition_app/providers/water_intake_provider.dart';
import 'package:nutrition_app/providers/step_counter_provider.dart';
import 'package:nutrition_app/providers/language_provider.dart';
import 'package:nutrition_app/screens/health_profile_form_screen.dart';
import 'package:nutrition_app/utils/AppColor.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
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
    return Consumer6<
      AuthProvider,
      HealthProfileProvider,
      FoodEntryProvider,
      WaterIntakeProvider,
      StepCounterProvider,
      LanguageProvider
    >(
      builder:
          (
            context,
            authProvider,
            healthProfileProvider,
            foodEntryProvider,
            waterIntakeProvider,
            stepCounterProvider,
            languageProvider,
            child,
          ) {
            final userData = authProvider.userData;
            final healthProfile = healthProfileProvider.profile;

            return Scaffold(
              appBar: AppBar(
                title: Text(
                  languageProvider.getText('profile'),
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const HealthProfileFormScreen(isUpdate: true),
                        ),
                      );
                    },
                  ),
                ],
              ),
              body: healthProfileProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Header
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundColor: primaryColor.withOpacity(
                                      0.1,
                                    ),
                                    child: Text(
                                      userData?['username']
                                              ?.substring(0, 1)
                                              .toUpperCase() ??
                                          'U',
                                      style: GoogleFonts.poppins(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          userData?['username'] ??
                                              languageProvider.getText(
                                                'username',
                                              ),
                                          style: GoogleFonts.poppins(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: textPrimaryColor,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          userData?['phone'] ??
                                              languageProvider.getText(
                                                'phone_number',
                                              ),
                                          style: GoogleFonts.poppins(
                                            color: textSecondaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Health Profile
                          if (healthProfile != null) ...[
                            Text(
                              languageProvider.getText('health_profile'),
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textPrimaryColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    _buildProfileItem(
                                      icon: Icons.person_outline,
                                      label: languageProvider.getText('gender'),
                                      value: healthProfile['gender'] == 'male'
                                          ? languageProvider.getText('male')
                                          : languageProvider.getText('female'),
                                    ),
                                    const Divider(),
                                    _buildProfileItem(
                                      icon: Icons.cake_outlined,
                                      label: languageProvider.getText('age'),
                                      value:
                                          '${healthProfile['age']} ${languageProvider.getText('age').toLowerCase()}',
                                    ),
                                    const Divider(),
                                    _buildProfileItem(
                                      icon: Icons.monitor_weight_outlined,
                                      label: languageProvider.getText('weight'),
                                      value: '${healthProfile['weight']} kg',
                                    ),
                                    const Divider(),
                                    _buildProfileItem(
                                      icon: Icons.height,
                                      label: languageProvider.getText('height'),
                                      value: '${healthProfile['height']} cm',
                                    ),
                                    const Divider(),
                                    _buildProfileItem(
                                      icon: Icons.monitor_heart_outlined,
                                      label: 'BMI',
                                      value: '${healthProfile['bmi']}',
                                    ),
                                    const Divider(),
                                    _buildProfileItem(
                                      icon: Icons.flag_outlined,
                                      label: languageProvider.getText('target'),
                                      value: _formatGoal(
                                        healthProfile['goal'],
                                        languageProvider,
                                      ),
                                    ),
                                    const Divider(),
                                    _buildProfileItem(
                                      icon: Icons.directions_run,
                                      label: languageProvider.getText(
                                        'activity_level',
                                      ),
                                      value: _formatActivityLevel(
                                        healthProfile['activityLevel'],
                                        languageProvider,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Nutrition Goals with Actual Data
                            Text(
                              languageProvider.getText('nutrition_goals'),
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textPrimaryColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    _buildNutritionGoalItem(
                                      label: languageProvider.getText(
                                        'daily_calories',
                                      ),
                                      current: foodEntryProvider
                                          .getTodayTotalCalories()
                                          .toInt(),
                                      target:
                                          healthProfile['dailyCalories'] ??
                                          2000,
                                      color: primaryColor,
                                      languageProvider: languageProvider,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildNutritionGoalItem(
                                      label: languageProvider.getText(
                                        'daily_water',
                                      ),
                                      current: waterIntakeProvider
                                          .getTodayTotalMl()
                                          .toInt(),
                                      target:
                                          healthProfile['dailyWaterMl'] ?? 2500,
                                      color: proteinColor,
                                      languageProvider: languageProvider,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildNutritionGoalItem(
                                      label: languageProvider.getText(
                                        'daily_steps',
                                      ),
                                      current: stepCounterProvider
                                          .getCurrentSteps(),
                                      target:
                                          healthProfile['dailySteps'] ?? 10000,
                                      color: proteinColor,
                                      languageProvider: languageProvider,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ] else ...[
                            // No Health Profile
                            Card(
                              color: primaryColor.withOpacity(0.1),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: primaryColor,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      languageProvider.getText(
                                        'complete_profile_message',
                                      ),
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        color: textPrimaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const HealthProfileFormScreen(),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        languageProvider.getText(
                                          'complete_profile',
                                        ),
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),

                          // Settings
                          Text(
                            languageProvider.getText('settings'),
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Logout Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(
                                      languageProvider.getText('logout'),
                                    ),
                                    content: Text(
                                      languageProvider.getText(
                                        'logout_confirmation',
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: Text(
                                          languageProvider.getText('cancel'),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: Text(
                                          languageProvider.getText('logout'),
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmed == true && context.mounted) {
                                  await authProvider.logout();
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/login',
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: errorColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                languageProvider.getText('logout'),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
            );
          },
    );
  }

  String _formatGoal(String goal, LanguageProvider languageProvider) {
    switch (goal) {
      case 'weight_loss':
        return languageProvider.getText('weight_loss');
      case 'maintenance':
        return languageProvider.getText('maintenance');
      case 'muscle_gain':
        return languageProvider.getText('muscle_gain');
      default:
        return goal;
    }
  }

  String _formatActivityLevel(String level, LanguageProvider languageProvider) {
    switch (level) {
      case 'lightly_active':
        return languageProvider.getText('lightly_active');
      case 'moderately_active':
        return languageProvider.getText('moderately_active');
      case 'very_active':
        return languageProvider.getText('very_active');
      default:
        return level;
    }
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(color: textSecondaryColor),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionGoalItem({
    required String label,
    required int current,
    required int target,
    required Color color,
    required LanguageProvider languageProvider,
  }) {
    final progress = current / target;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: textPrimaryColor,
              ),
            ),
            Text(
              '$current / $target',
              style: GoogleFonts.poppins(color: textSecondaryColor),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 4),
        Text(
          '${(progress * 100).clamp(0.0, 100.0).toStringAsFixed(0)}% ${languageProvider.getText('completed')}',
          style: GoogleFonts.poppins(fontSize: 12, color: textSecondaryColor),
        ),
      ],
    );
  }
}
