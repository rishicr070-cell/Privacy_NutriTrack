import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user_profile.dart';
import '../utils/storage_helper.dart';

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

  void _calculateMacros() {
    if (_currentWeightController.text.isEmpty || _heightController.text.isEmpty || _ageController.text.isEmpty) {
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

    setState(() {
      _dailyCalorieGoal = tdee.roundToDouble().clamp(1200, 3500);
      _dailyProteinGoal = (weight * 2).roundToDouble().clamp(50, 300);
      _dailyCarbsGoal = ((tdee * 0.4) / 4).roundToDouble().clamp(50, 400);
      _dailyFatGoal = ((tdee * 0.3) / 9).roundToDouble().clamp(20, 150);
    });
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final profile = UserProfile(
        name: _nameController.text,
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
      );

      await StorageHelper.saveUserProfile(profile);

      if (mounted) {
        Navigator.pop(context, true);
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
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
                Expanded(
                  child: _buildGenderDropdown(),
                ),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
      value: _gender,
      decoration: InputDecoration(
        labelText: 'Gender',
        prefixIcon: const Icon(Icons.wc),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: isSelected ? Theme.of(context).colorScheme.primary : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
}
