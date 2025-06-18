import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nutrition_app/providers/health_profile_provider.dart';
import 'package:nutrition_app/utils/AppColor.dart';
import 'package:google_fonts/google_fonts.dart';

class HealthProfileFormScreen extends StatefulWidget {
  final bool isUpdate;
  const HealthProfileFormScreen({Key? key, this.isUpdate = false})
      : super(key: key);

  @override
  State<HealthProfileFormScreen> createState() =>
      _HealthProfileFormScreenState();
}

class _HealthProfileFormScreenState extends State<HealthProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  String _selectedGender = 'male';
  String _selectedGoal = 'weight_loss';
  String _selectedActivityLevel = 'moderately_active';
  String? _bmiCategory;
  String? _healthWarning;
  List<String> _availableGoals = ['weight_loss', 'maintenance', 'muscle_gain'];

  @override
  void initState() {
    super.initState();
    if (widget.isUpdate) {
      _loadProfile();
    }
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  double _calculateBMI(double weight, double height) {
    // Height in meters
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal weight';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  void _updateBMIAndGoals() {
    if (_weightController.text.isNotEmpty &&
        _heightController.text.isNotEmpty) {
      final weight = double.tryParse(_weightController.text);
      final height = double.tryParse(_heightController.text);

      if (weight != null && height != null) {
        final bmi = _calculateBMI(weight, height);
        final category = _getBMICategory(bmi);
        setState(() {
          _bmiCategory = category;
          _availableGoals = _getAvailableGoals(category, bmi);

          // Update selected goal if current goal is not available
          if (!_availableGoals.contains(_selectedGoal)) {
            _selectedGoal = _availableGoals.first;
          }

          // Set health warning based on BMI
          _healthWarning = _getHealthWarning(category, bmi);
        });
      }
    }
  }

  List<String> _getAvailableGoals(String bmiCategory, double bmi) {
    switch (bmiCategory) {
      case 'Underweight':
        return ['muscle_gain', 'maintenance'];
      case 'Normal weight':
        return ['weight_loss', 'maintenance', 'muscle_gain'];
      case 'Overweight':
        return ['weight_loss', 'maintenance'];
      case 'Obese':
        return ['weight_loss'];
      default:
        return ['maintenance'];
    }
  }

  String _getHealthWarning(String bmiCategory, double bmi) {
    switch (bmiCategory) {
      case 'Underweight':
        return 'Your BMI indicates you are underweight. Consider focusing on healthy weight gain and muscle building.';
      case 'Overweight':
        return 'Your BMI indicates you are overweight. Focus on gradual weight loss through a balanced diet and regular exercise.';
      case 'Obese':
        return 'Your BMI indicates obesity. Please consult with a healthcare provider before starting any weight loss program.';
      default:
        return '';
    }
  }

  Future<void> _loadProfile() async {
    final provider = Provider.of<HealthProfileProvider>(context, listen: false);
    await provider.fetchProfile();
    if (provider.profile != null) {
      final profile = provider.profile!;
      _ageController.text = profile['age'].toString();
      _weightController.text = profile['weight'].toString();
      _heightController.text = profile['height'].toString();
      _selectedGender = profile['gender'];
      _selectedGoal = profile['goal'];
      _selectedActivityLevel = profile['activity_level'];
      _updateBMIAndGoals();
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final provider =
          Provider.of<HealthProfileProvider>(context, listen: false);

      try {
        await provider.createOrUpdateProfile(
          age: int.parse(_ageController.text),
          gender: _selectedGender,
          weight: double.parse(_weightController.text),
          height: double.parse(_heightController.text),
          goal: _selectedGoal,
          activityLevel: _selectedActivityLevel,
        );

        if (mounted && provider.error == null) {
          if (widget.isUpdate) {
            Navigator.pop(context);
          } else {
            Navigator.pushReplacementNamed(context, '/dashboard');
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.error ?? 'Failed to save profile'),
              backgroundColor: errorColor,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HealthProfileProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isUpdate ? 'Update Health Profile' : 'Complete Your Profile',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!widget.isUpdate)
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
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Age
                    TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Age',
                        prefixIcon:
                            Icon(Icons.cake_outlined, color: primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your age';
                        }
                        final age = int.tryParse(value);
                        if (age == null || age < 13 || age > 120) {
                          return 'Age must be between 13 and 120';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Gender
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: InputDecoration(
                        labelText: 'Gender',
                        prefixIcon:
                            Icon(Icons.person_outline, color: primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'male', child: Text('Male')),
                        DropdownMenuItem(
                            value: 'female', child: Text('Female')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedGender = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Weight
                    TextFormField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _updateBMIAndGoals(),
                      decoration: InputDecoration(
                        labelText: 'Weight (kg)',
                        prefixIcon: Icon(Icons.monitor_weight_outlined,
                            color: primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your weight';
                        }
                        final weight = double.tryParse(value);
                        if (weight == null || weight < 20 || weight > 300) {
                          return 'Weight must be between 20 and 300 kg';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Height
                    TextFormField(
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _updateBMIAndGoals(),
                      decoration: InputDecoration(
                        labelText: 'Height (cm)',
                        prefixIcon: Icon(Icons.height, color: primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your height';
                        }
                        final height = double.tryParse(value);
                        if (height == null || height < 100 || height > 250) {
                          return 'Height must be between 100 and 250 cm';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // BMI Category and Warning
                    if (_bmiCategory != null) ...[
                      Card(
                        color: _getBMICardColor(_bmiCategory!),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BMI Category: $_bmiCategory',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              if (_healthWarning != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  _healthWarning!,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Goal
                    DropdownButtonFormField<String>(
                      value: _selectedGoal,
                      decoration: InputDecoration(
                        labelText: 'Goal',
                        prefixIcon:
                            Icon(Icons.flag_outlined, color: primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: _availableGoals.map((goal) {
                        return DropdownMenuItem(
                          value: goal,
                          child: Text(_getGoalDisplayName(goal)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedGoal = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Activity Level
                    DropdownButtonFormField<String>(
                      value: _selectedActivityLevel,
                      decoration: InputDecoration(
                        labelText: 'Activity Level',
                        prefixIcon:
                            Icon(Icons.directions_run, color: primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'lightly_active',
                          child: Text('Lightly Active'),
                        ),
                        DropdownMenuItem(
                          value: 'moderately_active',
                          child: Text('Moderately Active'),
                        ),
                        DropdownMenuItem(
                          value: 'very_active',
                          child: Text('Very Active'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedActivityLevel = value);
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    ElevatedButton(
                      onPressed: provider.isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: provider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : Text(
                              widget.isUpdate
                                  ? 'Update Profile'
                                  : 'Complete Profile',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  String _getGoalDisplayName(String goal) {
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

  Color _getBMICardColor(String category) {
    switch (category) {
      case 'Underweight':
        return Colors.orange;
      case 'Normal weight':
        return Colors.green;
      case 'Overweight':
        return Colors.orange;
      case 'Obese':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
