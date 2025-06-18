import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:nutrition_app/providers/step_counter_provider.dart';
import 'package:nutrition_app/providers/health_profile_provider.dart';
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
            content: Text('Error initializing step counter: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final healthProfileProvider = context.watch<HealthProfileProvider>();
    final healthProfile = healthProfileProvider.profile;
    // Default to 10,000 steps if no goal is set
    final dailyStepGoal = healthProfile?['dailySteps'] ?? 10000;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Step Counter',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeStepCounter,
          ),
        ],
      ),
      body: Consumer<StepCounterProvider>(
        builder: (context, provider, _) {
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
                    'Error: ${provider.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.initialize(),
                    child: const Text('Retry'),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Today\'s Progress',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: textPrimaryColor,
                                  ),
                                ),
                              ),
                              Text(
                                '$currentSteps / $dailyStepGoal steps',
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
                                  backgroundColor:
                                      primaryColor.withOpacity(0.2),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    progress > 1.0 ? Colors.red : primaryColor,
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
                                    'Completed',
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
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: _buildInfoItem(
                                    icon: Icons.directions_walk,
                                    label: 'Steps',
                                    value: currentSteps.toString(),
                                  ),
                                ),
                                Expanded(
                                  child: _buildInfoItem(
                                    icon: Icons.timer,
                                    label: 'Goal',
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
                            'Walking Tips',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildTipItem(
                            'Take short walks during breaks',
                            Icons.timer_outlined,
                          ),
                          _buildTipItem(
                            'Use stairs instead of elevators',
                            Icons.stairs_outlined,
                          ),
                          _buildTipItem(
                            'Park further from your destination',
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
        Text(
          label,
          style: GoogleFonts.poppins(
            color: textSecondaryColor,
          ),
        ),
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
              style: GoogleFonts.poppins(
                color: textSecondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
