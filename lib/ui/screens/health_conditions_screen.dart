import 'package:flutter/material.dart';
import 'package:privacy_first_nutrition_tracking_app/data/models/user_profile.dart';
import 'package:privacy_first_nutrition_tracking_app/data/local/storage_helper.dart';
import 'package:privacy_first_nutrition_tracking_app/data/local/health_alert_service.dart';

class HealthConditionsScreen extends StatefulWidget {
  final UserProfile? profile;

  const HealthConditionsScreen({super.key, this.profile});

  @override
  State<HealthConditionsScreen> createState() => _HealthConditionsScreenState();
}

class _HealthConditionsScreenState extends State<HealthConditionsScreen> {
  late List<String> _selectedConditions;
  late List<String> _selectedAllergies;
  final _customAllergyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedConditions = widget.profile?.healthConditions ?? [];
    _selectedAllergies = widget.profile?.allergies ?? [];
  }

  @override
  void dispose() {
    _customAllergyController.dispose();
    super.dispose();
  }

  Future<void> _saveAndReturn() async {
    if (widget.profile != null) {
      final updatedProfile = widget.profile!.copyWith(
        healthConditions: _selectedConditions,
        allergies: _selectedAllergies,
      );
      await StorageHelper.saveUserProfile(updatedProfile);
    }
    
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  void _addCustomAllergy() {
    final allergy = _customAllergyController.text.trim();
    if (allergy.isNotEmpty && !_selectedAllergies.contains(allergy)) {
      setState(() {
        _selectedAllergies.add(allergy);
        _customAllergyController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final conditions = HealthAlertService.getAllHealthConditions();
    final commonAllergies = HealthAlertService.getCommonAllergies();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Conditions'),
        backgroundColor: const Color(0xFF00C9FF),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _saveAndReturn,
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildInfoCard(),
          const SizedBox(height: 24),
          _buildConditionsSection(conditions),
          const SizedBox(height: 32),
          _buildAllergiesSection(commonAllergies),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(77),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.info_outline, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Personalized Health Alerts',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Select your health conditions and allergies. We\'ll alert you when adding foods that may not be suitable for you.',
              style: TextStyle(
                color: Colors.white.withAlpha(242),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionsSection(List<Map<String, String>> conditions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.medical_services, color: Colors.red, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Health Conditions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: conditions.map((condition) {
                final isSelected = _selectedConditions.contains(condition['id']);
                return CheckboxListTile(
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedConditions.add(condition['id']!);
                      } else {
                        _selectedConditions.remove(condition['id']);
                      }
                    });
                  },
                  title: Text(
                    '${condition['icon']} ${condition['name']}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  activeColor: const Color(0xFF00C9FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                );
              }).toList(),
            ),
          ),
        ),
        if (_selectedConditions.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(26),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withAlpha(77)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_selectedConditions.length} condition(s) selected. You\'ll receive alerts for unsuitable foods.',
                    style: const TextStyle(fontSize: 13, color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAllergiesSection(List<String> commonAllergies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Food Allergies',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Common Allergies',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: commonAllergies.map((allergy) {
                    final isSelected = _selectedAllergies.contains(allergy);
                    return FilterChip(
                      label: Text(allergy),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedAllergies.add(allergy);
                          } else {
                            _selectedAllergies.remove(allergy);
                          }
                        });
                      },
                      selectedColor: Colors.orange.withAlpha(51),
                      checkmarkColor: Colors.orange,
                      side: BorderSide(
                        color: isSelected
                            ? Colors.orange
                            : Colors.grey.withAlpha(77),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),
                const Text(
                  'Add Custom Allergy',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _customAllergyController,
                        decoration: InputDecoration(
                          hintText: 'e.g., Sesame, Mustard',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _addCustomAllergy,
                      icon: const Icon(Icons.add),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF00C9FF),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (_selectedAllergies.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Selected Allergies',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedAllergies.map((allergy) {
              return Chip(
                label: Text(allergy),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  setState(() {
                    _selectedAllergies.remove(allergy);
                  });
                },
                backgroundColor: Colors.red.withAlpha(26),
                side: BorderSide(color: Colors.red.withAlpha(77)),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
