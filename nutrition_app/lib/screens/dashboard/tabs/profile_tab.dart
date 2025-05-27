import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nutrition_app/providers/auth_provider.dart';
import 'package:nutrition_app/providers/health_profile_provider.dart';
import 'package:nutrition_app/screens/health_profile_form_screen.dart';
import 'package:nutrition_app/utils/AppColor.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final healthProfileProvider = Provider.of<HealthProfileProvider>(context);
    final userData = authProvider.userData;
    final healthProfile = healthProfileProvider.profile;
    print(healthProfile);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
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
                            backgroundColor: primaryColor.withOpacity(0.1),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userData?['username'] ?? 'Username',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: textPrimaryColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  userData?['phone'] ?? 'Phone Number',
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
                      'Health Profile',
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
                              label: 'Gender',
                              value: healthProfile['gender'] == 'male'
                                  ? 'Male'
                                  : 'Female',
                            ),
                            const Divider(),
                            _buildProfileItem(
                              icon: Icons.cake_outlined,
                              label: 'Age',
                              value: '${healthProfile['age']} years',
                            ),
                            const Divider(),
                            _buildProfileItem(
                              icon: Icons.monitor_weight_outlined,
                              label: 'Weight',
                              value: '${healthProfile['weight']} kg',
                            ),
                            const Divider(),
                            _buildProfileItem(
                              icon: Icons.height,
                              label: 'Height',
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
                              label: 'Goal',
                              value: _formatGoal(healthProfile['goal']),
                            ),
                            const Divider(),
                            _buildProfileItem(
                              icon: Icons.directions_run,
                              label: 'Activity Level',
                              value: _formatActivityLevel(
                                  healthProfile['activityLevel']),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Nutrition Goals
                    Text(
                      'Nutrition Goals',
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
                              label: 'Daily Calories',
                              current: healthProfile['dailyCalories'],
                              target: healthProfile['dailyCalories'],
                              color: primaryColor,
                            ),
                            const SizedBox(height: 16),
                            _buildNutritionGoalItem(
                              label: 'Daily Water',
                              current: healthProfile['dailyWaterMl'],
                              target: healthProfile['dailyWaterMl'],
                              color: proteinColor,
                            ),
                            const Divider(),
                            _buildNutritionGoalItem(
                              label: 'Daily Steps',
                              current: healthProfile['dailySteps'],
                              target: healthProfile['dailySteps'],
                              color: proteinColor,
                            ),
                            const Divider(),
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
                              'Please complete your health profile to get personalized nutrition recommendations.',
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
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Complete Profile',
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
                    'Settings',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Card(
                  //   elevation: 2,
                  //   shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.circular(12),
                  //   ),
                  //   child: Column(
                  //     children: [
                  //       SwitchListTile(
                  //         title: Text(
                  //           'Notifications',
                  //           style: GoogleFonts.poppins(
                  //             fontWeight: FontWeight.w500,
                  //           ),
                  //         ),
                  //         subtitle: Text(
                  //           'Get reminders for meals and water intake',
                  //           style: GoogleFonts.poppins(
                  //             color: textSecondaryColor,
                  //           ),
                  //         ),
                  //         value: true,
                  //         onChanged: (value) {
                  //           // Toggle notifications
                  //         },
                  //       ),
                  //       const Divider(),
                  //       SwitchListTile(
                  //         title: Text(
                  //           'Dark Mode',
                  //           style: GoogleFonts.poppins(
                  //             fontWeight: FontWeight.w500,
                  //           ),
                  //         ),
                  //         subtitle: Text(
                  //           'Switch to dark theme',
                  //           style: GoogleFonts.poppins(
                  //             color: textSecondaryColor,
                  //           ),
                  //         ),
                  //         value: false,
                  //         onChanged: (value) {
                  //           // Toggle dark mode
                  //         },
                  //       ),
                  //       const Divider(),
                  //       ListTile(
                  //         title: Text(
                  //           'Language',
                  //           style: GoogleFonts.poppins(
                  //             fontWeight: FontWeight.w500,
                  //           ),
                  //         ),
                  //         subtitle: Text(
                  //           'English',
                  //           style: GoogleFonts.poppins(
                  //             color: textSecondaryColor,
                  //           ),
                  //         ),
                  //         trailing:
                  //             const Icon(Icons.arrow_forward_ios, size: 16),
                  //         onTap: () {
                  //           // Show language selection
                  //         },
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // const SizedBox(height: 24),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Logout'),
                            content:
                                const Text('Are you sure you want to logout?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('CANCEL'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('LOGOUT'),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true && context.mounted) {
                          await authProvider.logout();
                          Navigator.pushReplacementNamed(context, '/login');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: errorColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Logout',
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
  }

  String _formatGoal(String goal) {
    switch (goal) {
      case 'weight_loss':
        return 'Weight Loss';
      case 'maintenance':
        return 'Maintenance';
      case 'muscle_gain':
        return 'Muscle Gain';
      default:
        return goal;
    }
  }

  String _formatActivityLevel(String level) {
    switch (level) {
      case 'lightly_active':
        return 'Lightly Active';
      case 'moderately_active':
        return 'Moderately Active';
      case 'very_active':
        return 'Very Active';
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
            child: Icon(
              icon,
              color: primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: textSecondaryColor,
                  ),
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
              style: GoogleFonts.poppins(
                color: textSecondaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
