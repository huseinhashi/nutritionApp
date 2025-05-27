import 'package:flutter/material.dart';
import 'package:nutrition_app/utils/AppColor.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:nutrition_app/providers/water_intake_provider.dart';
import 'package:nutrition_app/providers/health_profile_provider.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class WaterIntakeTab extends StatefulWidget {
  const WaterIntakeTab({Key? key}) : super(key: key);

  @override
  State<WaterIntakeTab> createState() => _WaterIntakeTabState();
}

class _WaterIntakeTabState extends State<WaterIntakeTab> {
  @override
  void initState() {
    super.initState();
    // Initialize timezone data
    tz.initializeTimeZones();
    // Fetch water intake data when the tab is opened
    Future.microtask(
        () => context.read<WaterIntakeProvider>().fetchWaterIntake());
  }

  Future<void> _refreshData() async {
    try {
      await context.read<WaterIntakeProvider>().fetchWaterIntake();
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

  // Convert UTC time to local time
  DateTime _toLocalTime(String utcTime) {
    final utcDateTime = DateTime.parse(utcTime).toUtc();
    return utcDateTime.toLocal();
  }

  // Format time in 12-hour format with AM/PM
  String _formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  Future<void> _showAddWaterDialog(BuildContext context, double amount) async {
    final provider = context.read<WaterIntakeProvider>();
    final now = DateTime.now();
    final intakeDate = DateFormat('yyyy-MM-dd').format(now);

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Water Intake'),
        content: Text(
            'Are you sure you want to add ${(amount * 1000).toStringAsFixed(0)}ml of water?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ADD'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await provider.addWaterIntake(
        intakeAmount: amount,
        intakeDate: intakeDate,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Water intake added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context, int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text(
            'Are you sure you want to delete this water intake entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: errorColor),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final provider = context.read<WaterIntakeProvider>();
    try {
      await provider.deleteWaterIntake(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _showCustomAmountDialog(BuildContext context) async {
    final TextEditingController controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Amount'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount (ml)',
              suffixText: 'ml',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an amount';
              }
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return 'Please enter a valid amount';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final amount =
                    double.parse(controller.text) / 1000; // Convert ml to L
                Navigator.pop(context);
                _showAddWaterDialog(context, amount);
              }
            },
            child: const Text('ADD'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final healthProfileProvider = context.watch<HealthProfileProvider>();
    final healthProfile = healthProfileProvider.profile;
    final dailyWaterGoal =
        healthProfile?['dailyWaterMl'] ?? 2500; // Default to 2.5L if no profile
    final dailyWaterGoalL = dailyWaterGoal / 1000; // Convert ml to L

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Water Intake',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<WaterIntakeProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${provider.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchWaterIntake(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final todayTotal = provider.getTodayTotal();
          final progress = todayTotal / dailyWaterGoalL;

          return RefreshIndicator(
            onRefresh: _refreshData,
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
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Today\'s Progress',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimaryColor,
                                ),
                              ),
                              Text(
                                '${todayTotal.toStringAsFixed(1)}L / ${dailyWaterGoalL.toStringAsFixed(1)}L',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: waterColor,
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
                                  backgroundColor: waterColor.withOpacity(0.2),
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(waterColor),
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    '${(progress * 100).toStringAsFixed(0)}%',
                                    style: GoogleFonts.poppins(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: waterColor,
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
                          // Quick Add Buttons with tooltips
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Tooltip(
                                message: 'Add 250ml (1 cup)',
                                child: _buildQuickAddButton(
                                  context,
                                  amount: 0.25,
                                  label: '250ml',
                                ),
                              ),
                              Tooltip(
                                message: 'Add 500ml (2 cups)',
                                child: _buildQuickAddButton(
                                  context,
                                  amount: 0.5,
                                  label: '500ml',
                                ),
                              ),
                              Tooltip(
                                message: 'Add 750ml (3 cups)',
                                child: _buildQuickAddButton(
                                  context,
                                  amount: 0.75,
                                  label: '750ml',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Recent Entries
                  Text(
                    'Recent Entries',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (provider.entries == null || provider.entries!.isEmpty)
                    Center(
                      child: Text(
                        'No entries yet',
                        style: GoogleFonts.poppins(
                          color: textSecondaryColor,
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: provider.entries!.length,
                      itemBuilder: (context, index) {
                        final date = provider.entries!.keys.elementAt(index);
                        final entries = provider.entries![date]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                DateFormat('EEEE, MMMM d')
                                    .format(DateTime.parse(date)),
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  color: textSecondaryColor,
                                ),
                              ),
                            ),
                            ...entries.map((entry) {
                              final localTime =
                                  _toLocalTime(entry['createdAt']);
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: waterColor.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.water_drop,
                                      color: waterColor,
                                    ),
                                  ),
                                  title: Text(
                                    '${(entry['intakeAmount'] as double).toStringAsFixed(1)}L',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    _formatTime(localTime),
                                    style: GoogleFonts.poppins(
                                      color: textSecondaryColor,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () => _showDeleteConfirmation(
                                        context, entry['id']),
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCustomAmountDialog(context),
        backgroundColor: waterColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildQuickAddButton(
    BuildContext context, {
    required double amount,
    required String label,
  }) {
    return ElevatedButton(
      onPressed: () => _showAddWaterDialog(context, amount),
      style: ElevatedButton.styleFrom(
        backgroundColor: waterColor.withOpacity(0.1),
        foregroundColor: waterColor,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.water_drop, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
