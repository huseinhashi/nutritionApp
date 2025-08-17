import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:nutrition_app/providers/step_counter_provider.dart';
import 'package:nutrition_app/providers/health_profile_provider.dart';
import 'package:nutrition_app/providers/language_provider.dart';
import 'package:nutrition_app/utils/AppColor.dart';

class StepCounterTab extends StatefulWidget {
  const StepCounterTab({Key? key}) : super(key: key);

  @override
  State<StepCounterTab> createState() => _StepCounterTabState();
}

class _StepCounterTabState extends State<StepCounterTab> {
  @override
  void initState() {
    super.initState();
    // Initialize step counter when tab is opened
    _initializeStepCounter();
  }

  Future<void> _initializeStepCounter() async {
    try {
      await context.read<StepCounterProvider>().initialize();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${context.read<LanguageProvider>().getText('error_initializing_step_counter')}: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<
      HealthProfileProvider,
      StepCounterProvider,
      LanguageProvider
    >(
      builder: (context, healthProfileProvider, stepCounterProvider, languageProvider, _) {
        final healthProfile = healthProfileProvider.profile;
        // Default to 10,000 steps if no goal is set
        final dailyStepGoal = healthProfile?['dailySteps'] ?? 10000;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              languageProvider.getText('step_counter'),
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _initializeStepCounter,
              ),
            ],
          ),
          body: Builder(
            builder: (context) {
              final provider = stepCounterProvider;

              if (!provider.isInitialized) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${languageProvider.getText('error')}: ${provider.error}',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => provider.initialize(),
                        child: Text(languageProvider.getText('retry')),
                      ),
                    ],
                  ),
                );
              }

              final currentSteps = provider.getCurrentSteps();
              final progress = currentSteps / dailyStepGoal;

              return RefreshIndicator(
                onRefresh: () => provider.initialize(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Daily Progress Card
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      languageProvider.getText(
                                        'today_progress',
                                      ),
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: textPrimaryColor,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '$currentSteps / $dailyStepGoal ${languageProvider.getText('steps_count').toLowerCase()}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: progress > 1.0
                                          ? Colors.red
                                          : primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    height: 200,
                                    width: 200,
                                    child: CircularProgressIndicator(
                                      value: progress.clamp(0.0, 1.0),
                                      strokeWidth: 12,
                                      backgroundColor: primaryColor.withOpacity(
                                        0.2,
                                      ),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        progress > 1.0
                                            ? Colors.red
                                            : primaryColor,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        '${(progress * 100).toStringAsFixed(0)}%',
                                        style: GoogleFonts.poppins(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: progress > 1.0
                                              ? Colors.red
                                              : primaryColor,
                                        ),
                                      ),
                                      Text(
                                        progress >= 1.0
                                            ? languageProvider.getText(
                                                'completed',
                                              )
                                            : languageProvider.getText(
                                                'in_progress',
                                              ),
                                        style: GoogleFonts.poppins(
                                          color: textSecondaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // Step Information
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Expanded(
                                      child: _buildInfoItem(
                                        icon: Icons.directions_walk,
                                        label: languageProvider.getText(
                                          'steps_count',
                                        ),
                                        value: currentSteps.toString(),
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildInfoItem(
                                        icon: Icons.timer,
                                        label: languageProvider.getText(
                                          'step_goal',
                                        ),
                                        value: dailyStepGoal.toString(),
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
                      // Tips Card
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
                                languageProvider.getText('walking_tips'),
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimaryColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildTipItem(
                                languageProvider.getText('take_short_walks'),
                                Icons.timer_outlined,
                              ),
                              _buildTipItem(
                                languageProvider.getText('use_stairs'),
                                Icons.stairs_outlined,
                              ),
                              _buildTipItem(
                                languageProvider.getText('park_further'),
                                Icons.directions_walk_outlined,
                              ),
                            ],
                          ),
                        ),
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

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: primaryColor, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textPrimaryColor,
          ),
        ),
        Text(label, style: GoogleFonts.poppins(color: textSecondaryColor)),
      ],
    );
  }

  Widget _buildTipItem(String tip, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: GoogleFonts.poppins(color: textSecondaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
