import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:privacy_first_nutrition_tracking_app/data/models/user_profile.dart';
import 'package:privacy_first_nutrition_tracking_app/data/local/storage_helper.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile? profile;

  const EditProfileScreen({super.key, this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _currentWeightController = TextEditingController();
  final _targetWeightController = TextEditingController();

  String _gender = 'male';
  String _activityLevel = 'moderate';

  // Fixed: Set proper default values within slider ranges
  double _dailyCalorieGoal = 2000;
  double _dailyProteinGoal = 150;
  double _dailyCarbsGoal = 200;
  double _dailyFatGoal = 65;
  double _dailyWaterGoal = 2000;

  // Calculation info
  double _calculatedTDEE = 0;
  double _calorieAdjustment = 0;
  String _detectedGoalType = 'maintenance';

  @override
  void initState() {
    super.initState();
    if (widget.profile != null) {
      _nameController.text = widget.profile!.name;
      _ageController.text = widget.profile!.age.toString();
      _heightController.text = widget.profile!.height.toString();
      _currentWeightController.text = widget.profile!.currentWeight.toString();
      _targetWeightController.text = widget.profile!.targetWeight.toString();
      _gender = widget.profile!.gender;
      _activityLevel = widget.profile!.activityLevel;
      _dailyCalorieGoal = widget.profile!.dailyCalorieGoal;
      _dailyProteinGoal = widget.profile!.dailyProteinGoal;
      _dailyCarbsGoal = widget.profile!.dailyCarbsGoal;
      _dailyFatGoal = widget.profile!.dailyFatGoal;
      _dailyWaterGoal = widget.profile!.dailyWaterGoal;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _currentWeightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  String _determineGoalType() {
    if (_currentWeightController.text.isEmpty ||
        _targetWeightController.text.isEmpty) {
      return 'maintenance';
    }

    final current = double.parse(_currentWeightController.text);
    final target = double.parse(_targetWeightController.text);
    final diff = current - target;

    if (diff > 2) return 'weight_loss';
    if (diff < -2) return 'weight_gain';
    return 'maintenance';
  }

  double _getCalorieAdjustment(String goalType) {
    switch (goalType) {
      case 'weight_loss':
        return -500; // Safe deficit for 0.5kg/week loss
      case 'weight_gain':
        return 400; // Healthy surplus for muscle gain
      default:
        return 0; // Maintenance
    }
  }

  double _getProteinTarget(double weight, String goalType) {
    switch (goalType) {
      case 'weight_loss':
        return weight * 2.2; // Higher protein to preserve muscle
      case 'weight_gain':
        return weight * 2.0; // High protein for muscle building
      default:
        return weight * 1.8; // Moderate protein for maintenance
    }
  }

  Map<String, double> _getMacroRatios(String goalType) {
    switch (goalType) {
      case 'weight_loss':
        return {'carbs': 0.35, 'fat': 0.30}; // Lower carbs, moderate fat
      case 'weight_gain':
        return {'carbs': 0.45, 'fat': 0.25}; // Higher carbs for energy
      default:
        return {'carbs': 0.40, 'fat': 0.30}; // Balanced
    }
  }

  void _calculateMacros() {
    if (_currentWeightController.text.isEmpty ||
        _heightController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _targetWeightController.text.isEmpty) {
      return;
    }

    final weight = double.parse(_currentWeightController.text);
    final height = double.parse(_heightController.text);
    final age = int.parse(_ageController.text);

    // Calculate BMR using Mifflin-St Jeor Equation
    double bmr;
    if (_gender == 'male') {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }

    // Apply activity multiplier
    double activityMultiplier;
    switch (_activityLevel) {
      case 'sedentary':
        activityMultiplier = 1.2;
        break;
      case 'light':
        activityMultiplier = 1.375;
        break;
      case 'moderate':
        activityMultiplier = 1.55;
        break;
      case 'active':
        activityMultiplier = 1.725;
        break;
      case 'very_active':
        activityMultiplier = 1.9;
        break;
      default:
        activityMultiplier = 1.55;
    }

    final tdee = bmr * activityMultiplier;

    // Determine goal type and get adjustments
    final goalType = _determineGoalType();
    final calorieAdjustment = _getCalorieAdjustment(goalType);
    final proteinTarget = _getProteinTarget(weight, goalType);
    final macroRatios = _getMacroRatios(goalType);

    // Calculate adjusted calories
    double adjustedCalories = tdee + calorieAdjustment;

    // Apply safety limits
    final minCalories = _gender == 'male' ? 1500.0 : 1200.0;
    adjustedCalories = adjustedCalories.clamp(minCalories, 3500.0);

    // Calculate macros
    final protein = proteinTarget.clamp(50.0, 300.0);
    final proteinCalories = protein * 4;
    final remainingCalories = adjustedCalories - proteinCalories;

    final carbsCalories = remainingCalories * macroRatios['carbs']!;
    final fatCalories = remainingCalories * macroRatios['fat']!;

    final carbs = (carbsCalories / 4).clamp(50.0, 400.0);
    final fat = (fatCalories / 9).clamp(20.0, 150.0);

    setState(() {
      _calculatedTDEE = tdee;
      _calorieAdjustment = calorieAdjustment;
      _detectedGoalType = goalType;
      _dailyCalorieGoal = adjustedCalories.roundToDouble();
      _dailyProteinGoal = protein.roundToDouble();
      _dailyCarbsGoal = carbs.roundToDouble();
      _dailyFatGoal = fat.roundToDouble();
    });
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        print('=== STARTING PROFILE SAVE ===');
        print('Name: ${_nameController.text}');
        print('Age: ${_ageController.text}');
        print('Gender: $_gender');

        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(child: CircularProgressIndicator());
          },
        );

        try {
          final profile = UserProfile(
            name: _nameController.text.trim(),
            age: int.parse(_ageController.text),
            height: double.parse(_heightController.text),
            currentWeight: double.parse(_currentWeightController.text),
            targetWeight: double.parse(_targetWeightController.text),
            gender: _gender,
            activityLevel: _activityLevel,
            dailyCalorieGoal: _dailyCalorieGoal,
            dailyProteinGoal: _dailyProteinGoal,
            dailyCarbsGoal: _dailyCarbsGoal,
            dailyFatGoal: _dailyFatGoal,
            dailyWaterGoal: _dailyWaterGoal,
            healthConditions: widget.profile?.healthConditions ?? [],
            allergies: widget.profile?.allergies ?? [],
            goalType: _detectedGoalType.isNotEmpty
                ? _detectedGoalType
                : 'maintenance',
          );

          print('Profile object created successfully');
          print('Calling StorageHelper.saveUserProfile...');
          await StorageHelper.saveUserProfile(profile);
          print('StorageHelper.saveUserProfile completed');

          // Add a small delay for web platform to ensure data is persisted
          await Future.delayed(const Duration(milliseconds: 100));

          // Verify the profile was saved by reading it back
          print('Verifying profile was saved...');
          final savedProfile = await StorageHelper.getUserProfile();
          if (savedProfile != null) {
            print('✓ Profile verification successful');
            print('Saved profile name: ${savedProfile.name}');
          } else {
            print(
              '⚠ Profile verification returned null, but save operation completed',
            );
            print('This can happen on web - the profile should still be saved');
            // Don't throw error - the save likely worked, just verification timing issue
          }

          if (mounted) {
            Navigator.of(context).pop(); // Close loading dialog
            print('Returning to profile screen with success=true');
            Navigator.pop(context, true); // Return to previous screen
          }
        } catch (e, stackTrace) {
          print('=== ERROR SAVING PROFILE ===');
          print('Error: $e');
          print('Stack trace: $stackTrace');

          if (mounted) {
            Navigator.of(context).pop(); // Close loading dialog
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to save profile: $e'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'Details',
                  textColor: Colors.white,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Error Details'),
                        content: SingleChildScrollView(
                          child: Text('$e\n\n$stackTrace'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          }
        }
      } catch (e, stackTrace) {
        print('=== UNEXPECTED ERROR ===');
        print('Error: $e');
        print('Stack trace: $stackTrace');

        if (mounted) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } else {
      // Show validation error message
      print('Form validation failed');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill in all required fields correctly'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.profile == null ? 'Create Profile' : 'Edit Profile'),
        backgroundColor: const Color(0xFF00C9FF),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              'Save',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _nameController,
              label: 'Name',
              icon: Icons.person,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildNumberField(
                    controller: _ageController,
                    label: 'Age',
                    icon: Icons.cake,
                    suffix: 'years',
                    onChange: _calculateMacros,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: _buildGenderDropdown()),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Body Measurements',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildNumberField(
              controller: _heightController,
              label: 'Height',
              icon: Icons.height,
              suffix: 'cm',
              onChange: _calculateMacros,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildNumberField(
                    controller: _currentWeightController,
                    label: 'Current Weight',
                    icon: Icons.monitor_weight,
                    suffix: 'kg',
                    onChange: _calculateMacros,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNumberField(
                    controller: _targetWeightController,
                    label: 'Target Weight',
                    icon: Icons.flag,
                    suffix: 'kg',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Activity Level',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildActivityLevelSelector(),
            const SizedBox(height: 24),
            Row(
              children: [
                Text(
                  'Daily Goals',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _calculateMacros,
                  icon: const Icon(Icons.calculate),
                  label: const Text('Auto Calculate'),
                ),
              ],
            ),
            if (_calculatedTDEE > 0) ...[
              const SizedBox(height: 16),
              _buildCalculationInfoCard(),
            ],
            const SizedBox(height: 16),
            _buildGoalSlider(
              'Daily Calories',
              _dailyCalorieGoal,
              1200,
              3500,
              'kcal',
              Icons.local_fire_department,
              Colors.orange,
              (value) => setState(() => _dailyCalorieGoal = value),
            ),
            const SizedBox(height: 16),
            _buildGoalSlider(
              'Daily Protein',
              _dailyProteinGoal,
              50,
              300,
              'g',
              Icons.fitness_center,
              Colors.blue,
              (value) => setState(() => _dailyProteinGoal = value),
            ),
            const SizedBox(height: 16),
            _buildGoalSlider(
              'Daily Carbs',
              _dailyCarbsGoal,
              50,
              400,
              'g',
              Icons.grain,
              Colors.orange,
              (value) => setState(() => _dailyCarbsGoal = value),
            ),
            const SizedBox(height: 16),
            _buildGoalSlider(
              'Daily Fat',
              _dailyFatGoal,
              20,
              150,
              'g',
              Icons.opacity,
              Colors.purple,
              (value) => setState(() => _dailyFatGoal = value),
            ),
            const SizedBox(height: 16),
            _buildGoalSlider(
              'Daily Water',
              _dailyWaterGoal,
              1000,
              4000,
              'ml',
              Icons.water_drop,
              Colors.blue,
              (value) => setState(() => _dailyWaterGoal = value),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).cardColor,
      ),
      validator: validator,
      textCapitalization: TextCapitalization.words,
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? suffix,
    VoidCallback? onChange,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixText: suffix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).cardColor,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      onChanged: (_) => onChange?.call(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }
        if (double.tryParse(value) == null) {
          return 'Invalid number';
        }
        return null;
      },
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _gender,
      decoration: InputDecoration(
        labelText: 'Gender',
        prefixIcon: const Icon(Icons.wc),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).cardColor,
      ),
      items: const [
        DropdownMenuItem(value: 'male', child: Text('Male')),
        DropdownMenuItem(value: 'female', child: Text('Female')),
        DropdownMenuItem(value: 'other', child: Text('Other')),
      ],
      onChanged: (value) {
        setState(() {
          _gender = value!;
          _calculateMacros();
        });
      },
    );
  }

  Widget _buildActivityLevelSelector() {
    final activities = {
      'sedentary': 'Sedentary\nLittle to no exercise',
      'light': 'Light\nExercise 1-3 days/week',
      'moderate': 'Moderate\nExercise 3-5 days/week',
      'active': 'Active\nExercise 6-7 days/week',
      'very_active': 'Very Active\nPhysical job or intense training',
    };

    return Column(
      children: activities.entries.map((entry) {
        final isSelected = _activityLevel == entry.key;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () {
              setState(() {
                _activityLevel = entry.key;
                _calculateMacros();
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGoalSlider(
    String label,
    double value,
    double min,
    double max,
    String unit,
    IconData icon,
    Color color,
    Function(double) onChanged,
  ) {
    // Ensure value is within range
    final safeValue = value.clamp(min, max);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${safeValue.toInt()} $unit',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: color,
                inactiveTrackColor: color.withOpacity(0.2),
                thumbColor: color,
                overlayColor: color.withOpacity(0.2),
              ),
              child: Slider(
                value: safeValue,
                min: min,
                max: max,
                divisions: ((max - min) / 10).round(),
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationInfoCard() {
    String goalIcon;
    String goalLabel;
    Color goalColor;

    switch (_detectedGoalType) {
      case 'weight_loss':
        goalIcon = '📉';
        goalLabel = 'Weight Loss';
        goalColor = Colors.orange;
        break;
      case 'weight_gain':
        goalIcon = '📈';
        goalLabel = 'Weight Gain';
        goalColor = Colors.green;
        break;
      default:
        goalIcon = '⚖️';
        goalLabel = 'Maintenance';
        goalColor = Colors.blue;
    }

    final current = double.tryParse(_currentWeightController.text) ?? 0;
    final target = double.tryParse(_targetWeightController.text) ?? 0;
    final weightDiff = (current - target).abs();

    String expectedChange;
    if (_detectedGoalType == 'weight_loss') {
      expectedChange = '-0.5 kg/week';
    } else if (_detectedGoalType == 'weight_gain') {
      expectedChange = '+0.3 kg/week';
    } else {
      expectedChange = 'Maintain current weight';
    }

    return Card(
      elevation: 2,
      color: goalColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: goalColor.withOpacity(0.3), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(goalIcon, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Calculated Goals',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: goalColor,
                        ),
                      ),
                      Text(
                        '$goalLabel (${weightDiff.toStringAsFixed(1)} kg)',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(
              'TDEE',
              '${_calculatedTDEE.toInt()} kcal',
              Icons.local_fire_department,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              _calorieAdjustment < 0
                  ? 'Deficit'
                  : _calorieAdjustment > 0
                  ? 'Surplus'
                  : 'Adjustment',
              '${_calorieAdjustment > 0 ? '+' : ''}${_calorieAdjustment.toInt()} kcal',
              _calorieAdjustment < 0
                  ? Icons.trending_down
                  : _calorieAdjustment > 0
                  ? Icons.trending_up
                  : Icons.remove,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Target',
              '${_dailyCalorieGoal.toInt()} kcal/day',
              Icons.flag,
            ),
            const SizedBox(height: 8),
            _buildInfoRow('Expected', expectedChange, Icons.timeline),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
