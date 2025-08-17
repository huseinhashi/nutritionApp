import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutrition_app/utils/AppColor.dart';
import 'package:provider/provider.dart';
import 'package:nutrition_app/providers/food_entry_provider.dart';
import 'package:nutrition_app/providers/language_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class LogMealScreen extends StatefulWidget {
  const LogMealScreen({super.key});

  @override
  State<LogMealScreen> createState() => _LogMealScreenState();
}

class _LogMealScreenState extends State<LogMealScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _error;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>>? _analyzedFoodItems;

  Future<bool> _requestPermission(ImageSource source) async {
    final languageProvider = context.read<LanguageProvider>();

    if (source == ImageSource.camera) {
      // Check if permission is already granted
      var status = await Permission.camera.status;
      if (status.isGranted) {
        return true;
      }

      // Request permission
      status = await Permission.camera.request();
      if (status.isGranted) {
        return true;
      }

      // If permanently denied, show settings dialog
      if (status.isPermanentlyDenied) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                languageProvider.getText('camera_permission_required'),
              ),
              content: Text(
                languageProvider.getText('camera_permission_message'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(languageProvider.getText('cancel')),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    openAppSettings();
                  },
                  child: Text(languageProvider.getText('settings')),
                ),
              ],
            ),
          );
        }
      }
      return false;
    } else {
      // Check if permission is already granted
      var status = await Permission.photos.status;
      if (status.isGranted) {
        return true;
      }

      // Request permission
      status = await Permission.photos.request();
      if (status.isGranted) {
        return true;
      }

      // If permanently denied, show settings dialog
      if (status.isPermanentlyDenied) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                languageProvider.getText('photo_library_permission_required'),
              ),
              content: Text(
                languageProvider.getText('photo_library_permission_message'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(languageProvider.getText('cancel')),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    openAppSettings();
                  },
                  child: Text(languageProvider.getText('settings')),
                ),
              ],
            ),
          );
        }
      }
      return false;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final languageProvider = context.read<LanguageProvider>();

    try {
      // Request permission first
      final hasPermission = await _requestPermission(source);
      if (!hasPermission) {
        setState(() {
          _error = languageProvider.getText('permission_denied');
        });
        return;
      }

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _error = null;
        });
      }
    } on PlatformException catch (e) {
      setState(() {
        _error =
            '${languageProvider.getText('failed_pick_image')}: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _error = '${languageProvider.getText('unexpected_error')}: $e';
      });
    }
  }

  Future<void> _submitFoodEntry() async {
    final languageProvider = context.read<LanguageProvider>();

    if (_selectedImage == null) {
      setState(() {
        _error = languageProvider.getText('please_select_image');
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _analyzedFoodItems = null;
    });

    try {
      final foodEntryProvider = Provider.of<FoodEntryProvider>(
        context,
        listen: false,
      );
      final result = await foodEntryProvider.addFoodEntryFromImage(
        _selectedImage!,
      );

      if (result.isEmpty) {
        setState(() {
          _error = languageProvider.getText('no_food_detected');
        });
        return;
      }

      setState(() {
        _analyzedFoodItems = result;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(languageProvider.getText('food_analyzed_success')),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${languageProvider.getText('error')}: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          languageProvider.getText('log_meal'),
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                        languageProvider.getText('take_upload_photo'),
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_selectedImage != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _pickImage(ImageSource.camera),
                              icon: const Icon(Icons.camera_alt),
                              label: Text(
                                languageProvider.getText('take_photo'),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _pickImage(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library),
                              label: Text(languageProvider.getText('upload')),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: GoogleFonts.poppins(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _submitFoodEntry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                languageProvider.getText('analyze_food'),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_analyzedFoodItems != null) ...[
                const SizedBox(height: 24),
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
                          languageProvider.getText('analyzed_food_items'),
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _analyzedFoodItems!.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final item = _analyzedFoodItems![index];
                            return Card(
                              margin: EdgeInsets.zero,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['name'] ??
                                                    languageProvider.getText(
                                                      'unknown',
                                                    ),
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${languageProvider.getText('somali')}: ${item['namesom'] ?? languageProvider.getText('unknown')}',
                                                style: GoogleFonts.poppins(
                                                  color: textSecondaryColor,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${languageProvider.getText('portion')}: ${item['portionsize'] ?? 'N/A'}',
                                                style: GoogleFonts.poppins(
                                                  color: textSecondaryColor,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        _buildNutrientChip(
                                          'Cal',
                                          '${item['calories']?.toStringAsFixed(0) ?? 'N/A'}',
                                        ),
                                        _buildNutrientChip(
                                          'Protein',
                                          '${item['protein']?.toStringAsFixed(1) ?? 'N/A'}g',
                                        ),
                                        _buildNutrientChip(
                                          'Carbs',
                                          '${item['carbs']?.toStringAsFixed(1) ?? 'N/A'}g',
                                        ),
                                        _buildNutrientChip(
                                          'Fat',
                                          '${item['fat']?.toStringAsFixed(1) ?? 'N/A'}g',
                                        ),
                                        _buildNutrientChip(
                                          'Vit A',
                                          '${item['vitaminA']?.toStringAsFixed(1) ?? 'N/A'}μg',
                                        ),
                                        _buildNutrientChip(
                                          'Vit C',
                                          '${item['vitaminC']?.toStringAsFixed(1) ?? 'N/A'}mg',
                                        ),
                                        _buildNutrientChip(
                                          'Calcium',
                                          '${item['calcium']?.toStringAsFixed(1) ?? 'N/A'}mg',
                                        ),
                                        _buildNutrientChip(
                                          'Iron',
                                          '${item['iron']?.toStringAsFixed(1) ?? 'N/A'}mg',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // Detailed Nutrition Breakdown
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            languageProvider.getText(
                                              'detailed_nutrition',
                                            ),
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              color: primaryColor,
                                            ),
                                          ),
                                          const SizedBox(height: 8),

                                          // Macronutrients
                                          _buildNutritionRow(
                                            languageProvider.getText(
                                              'calories',
                                            ),
                                            '${item['calories']?.toStringAsFixed(0) ?? 'N/A'} cal',
                                          ),
                                          _buildNutritionRow(
                                            'Protein',
                                            '${item['protein']?.toStringAsFixed(1) ?? 'N/A'}g',
                                          ),
                                          _buildNutritionRow(
                                            'Carbohydrates',
                                            '${item['carbs']?.toStringAsFixed(1) ?? 'N/A'}g',
                                          ),
                                          _buildNutritionRow(
                                            'Fat',
                                            '${item['fat']?.toStringAsFixed(1) ?? 'N/A'}g',
                                          ),

                                          const Divider(height: 16),

                                          // Vitamins
                                          Text(
                                            languageProvider.getText(
                                              'vitamins',
                                            ),
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                              color: textSecondaryColor,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          _buildNutritionRow(
                                            'Vitamin A',
                                            '${item['vitaminA']?.toStringAsFixed(1) ?? 'N/A'} μg',
                                          ),
                                          _buildNutritionRow(
                                            'Vitamin C',
                                            '${item['vitaminC']?.toStringAsFixed(1) ?? 'N/A'} mg',
                                          ),

                                          const Divider(height: 16),

                                          // Minerals
                                          Text(
                                            languageProvider.getText(
                                              'minerals',
                                            ),
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                              color: textSecondaryColor,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          _buildNutritionRow(
                                            'Calcium',
                                            '${item['calcium']?.toStringAsFixed(1) ?? 'N/A'} mg',
                                          ),
                                          _buildNutritionRow(
                                            'Iron',
                                            '${item['iron']?.toStringAsFixed(1) ?? 'N/A'} mg',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutrientChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: $value',
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 13, color: textSecondaryColor),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
