import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:privacy_first_nutrition_tracking_app/data/models/food_entry.dart';
import 'package:privacy_first_nutrition_tracking_app/data/models/food_item.dart';
import 'package:privacy_first_nutrition_tracking_app/data/local/storage_helper.dart';
import 'package:privacy_first_nutrition_tracking_app/data/local/food_data_loader.dart';
import 'package:privacy_first_nutrition_tracking_app/data/local/health_alert_service.dart';
import 'package:privacy_first_nutrition_tracking_app/data/services/tts_service.dart';
import 'food_scanner_screen.dart';
import 'package:privacy_first_nutrition_tracking_app/data/services/gemini_service.dart';
import 'dart:async';

class AddFoodScreen extends StatefulWidget {
  final String mealType;
  final FoodEntry? existingEntry;
  final FoodItem? foodItem;
  final int? estimatedWeight;
  final String? detectedFoodName; // Name from scanner without nutrition data

  const AddFoodScreen({
    super.key,
    required this.mealType,
    this.existingEntry,
    this.foodItem,
    this.estimatedWeight,
    this.detectedFoodName,
  });

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  final _servingSizeController = TextEditingController(text: '100');
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _ttsService = TtsService();

  String _servingUnit = 'g';
  List<FoodItem> _allFoods = [];
  List<FoodItem> _searchResults = [];
  FoodItem? _selectedFood;
  bool _isLoading = true;
  bool _showSearchResults = false;
  bool _isManualEntry = false;

  // AI Feedback
  final _geminiService = GeminiService();
  Timer? _aiDebounce;
  Map<String, dynamic>? _aiFeedback;
  bool _isAiLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _loadFoodData();
    if (widget.existingEntry != null) {
      _populateExistingEntry();
    } else if (widget.foodItem != null) {
      _populateFromFoodItem();
    } else if (widget.detectedFoodName != null) {
      _populateFromDetectedName();
    }
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _initializeTts() async {
    await _ttsService.initialize();
    // Load user's preferred language and set it
    final profile = await StorageHelper.getUserProfile();
    if (profile != null && profile.preferredLanguage.isNotEmpty) {
      await _ttsService.setLanguage(profile.preferredLanguage);
    }
  }

  Future<void> _loadFoodData() async {
    setState(() => _isLoading = true);
    try {
      final foods = await FoodDataLoader.loadFoodItems();
      setState(() {
        _allFoods = foods;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isManualEntry = true;
      });
    }
  }

  void _populateExistingEntry() {
    _searchController.text = widget.existingEntry!.name;
    _caloriesController.text = widget.existingEntry!.calories.toString();
    _proteinController.text = widget.existingEntry!.protein.toString();
    _carbsController.text = widget.existingEntry!.carbs.toString();
    _fatController.text = widget.existingEntry!.fat.toString();
    _servingSizeController.text = widget.existingEntry!.servingSize.toString();
    _servingUnit = widget.existingEntry!.servingUnit;
    _isManualEntry = true;
  }

  void _populateFromFoodItem() {
    _selectedFood = widget.foodItem;
    _searchController.text = widget.foodItem!.name;
    // Use estimated weight from scanner if available, otherwise default to 100g
    _servingSizeController.text = (widget.estimatedWeight ?? 100).toString();
    _calculateNutrients();
  }

  void _populateFromDetectedName() {
    // For detected food without nutrition data (manual entry mode)
    _searchController.text = widget.detectedFoodName!;
    _servingSizeController.text = (widget.estimatedWeight ?? 100).toString();
    _isManualEntry = true;
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _showSearchResults = false;
        _selectedFood = null;
      });
      return;
    }

    setState(() {
      _searchResults = _allFoods
          .where((food) {
            final nameMatch = food.name.toLowerCase().contains(query);
            final categoryMatch =
                food.category?.toLowerCase().contains(query) ?? false;
            return nameMatch || categoryMatch;
          })
          .take(10)
          .toList();
      _showSearchResults = _searchResults.isNotEmpty;
    });

    if (_searchResults.isEmpty) {
      _triggerAiAnalysis();
    }
  }

  void _triggerAiAnalysis() {
    if (_aiDebounce?.isActive ?? false) _aiDebounce!.cancel();

    _aiDebounce = Timer(const Duration(milliseconds: 1500), () async {
      if (_searchController.text.isEmpty || _caloriesController.text.isEmpty)
        return;

      setState(() => _isAiLoading = true);

      final profile = await StorageHelper.getUserProfile();
      if (profile == null) return;

      final feedback = await _geminiService.analyzeFoodEntry(
        profile: profile,
        foodName: _searchController.text,
        calories: double.tryParse(_caloriesController.text) ?? 0,
        protein: double.tryParse(_proteinController.text) ?? 0,
        carbs: double.tryParse(_carbsController.text) ?? 0,
        fat: double.tryParse(_fatController.text) ?? 0,
      );

      if (mounted) {
        setState(() {
          _aiFeedback = feedback;
          _isAiLoading = false;
        });
      }
    });
  }

  void _selectFood(FoodItem food) {
    setState(() {
      _selectedFood = food;
      _searchController.text = food.name;
      _showSearchResults = false;
      _isManualEntry = false;
    });

    _calculateNutrients();
  }

  void _calculateNutrients() {
    if (_selectedFood == null) return;

    final servingSize = double.tryParse(_servingSizeController.text) ?? 100;
    final multiplier = servingSize / 100;

    setState(() {
      _caloriesController.text = (_selectedFood!.calories * multiplier)
          .toStringAsFixed(1);
      _proteinController.text = (_selectedFood!.protein * multiplier)
          .toStringAsFixed(1);
      _carbsController.text = (_selectedFood!.carbs * multiplier)
          .toStringAsFixed(1);
      _fatController.text = (_selectedFood!.fat * multiplier).toStringAsFixed(
        1,
      );
    });

    _triggerAiAnalysis();
  }

  void _switchToManualEntry() {
    setState(() {
      _isManualEntry = true;
      _selectedFood = null;
      _showSearchResults = false;
      if (_caloriesController.text.isEmpty) {
        _caloriesController.clear();
        _proteinController.clear();
        _carbsController.clear();
        _fatController.clear();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _servingSizeController.dispose();
    _ttsService.stop();
    super.dispose();
  }

  Future<void> _openFoodScanner() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => const FoodScannerScreen()),
    );

    if (result != null && mounted) {
      setState(() {
        _searchController.text = result['name'] as String;
        _isManualEntry = true;
      });
    }
  }

  Future<void> _saveFood() async {
    if (_formKey.currentState!.validate()) {
      final foodItem = FoodItem(
        foodCode: 'manual_entry',
        foodName: _searchController.text.trim(),
        energyKcal: double.parse(_caloriesController.text),
        proteinG: double.parse(_proteinController.text),
        carbG: double.parse(_carbsController.text),
        fatG: double.parse(_fatController.text),
      );

      final servingSize = double.parse(_servingSizeController.text);

      final profile = await StorageHelper.getUserProfile();
      final alerts = HealthAlertService.checkFoodAlerts(
        foodItem,
        profile,
        servingSize,
      );

      if (alerts.any((alert) => alert.severity == HealthAlertSeverity.danger)) {
        final shouldContinue = await _showHealthAlertDialog(alerts);
        if (!shouldContinue) {
          return;
        }
      } else if (alerts.isNotEmpty) {
        await _showHealthWarningDialog(alerts);
      }

      final entry = FoodEntry(
        id:
            widget.existingEntry?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _searchController.text.trim(),
        calories: double.parse(_caloriesController.text),
        protein: double.parse(_proteinController.text),
        carbs: double.parse(_carbsController.text),
        fat: double.parse(_fatController.text),
        servingSize: double.parse(_servingSizeController.text),
        servingUnit: _servingUnit,
        timestamp: widget.existingEntry?.timestamp ?? DateTime.now(),
        mealType: widget.mealType,
      );

      if (widget.existingEntry != null) {
        await StorageHelper.updateFoodEntry(entry);
      } else {
        await StorageHelper.saveFoodEntry(entry);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  String _formatAlertForSpeech(HealthAlert alert) {
    String cleanTitle = alert.title.replaceAll(RegExp(r'[^\w\s]'), '');
    String cleanMessage = alert.message.replaceAll(RegExp(r'[^\w\s.,!?]'), '');
    return '$cleanTitle. $cleanMessage';
  }

  Future<bool> _showHealthAlertDialog(List<HealthAlert> alerts) async {
    final dangerAlerts = alerts
        .where((a) => a.severity == HealthAlertSeverity.danger)
        .toList();

    if (dangerAlerts.isNotEmpty) {
      final speechText = _formatAlertForSpeech(dangerAlerts.first);

      // Get user's preferred language and translate if needed
      final profile = await StorageHelper.getUserProfile();
      final preferredLang = profile?.preferredLanguage ?? 'en-US';

      // Translate the alert to user's preferred language
      final translatedText = await _geminiService.translateText(
        speechText,
        preferredLang,
      );

      await _ttsService.speak(translatedText ?? speechText);
    }

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            icon: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 48,
            ),
            title: const Text(
              '⚠️ Health Warning',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'This food may not be suitable for your health conditions:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  ...dangerAlerts.map(
                    (alert) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alert.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            alert.message,
                            style: TextStyle(color: Colors.red.shade800),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Consider consulting your doctor before consuming this food.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _ttsService.stop();
                  Navigator.pop(context, false);
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _ttsService.stop();
                  Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Add Anyway',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _showHealthWarningDialog(List<HealthAlert> alerts) async {
    if (alerts.isNotEmpty) {
      final speechText = _formatAlertForSpeech(alerts.first);

      // Get user's preferred language and translate if needed
      final profile = await StorageHelper.getUserProfile();
      final preferredLang = profile?.preferredLanguage ?? 'en-US';

      // Translate the alert to user's preferred language
      final translatedText = await _geminiService.translateText(
        speechText,
        preferredLang,
      );

      await _ttsService.speak(translatedText ?? speechText);
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.info_outline, color: Colors.orange, size: 48),
        title: const Text(
          'ℹ️ Nutrition Information',
          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please be aware:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              ...alerts.map(
                (alert) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alert.message,
                        style: TextStyle(color: Colors.orange.shade800),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              _ttsService.stop();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'Understood',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingEntry != null ? 'Edit Food' : 'Add Food'),
        backgroundColor: _getMealTypeColor(),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _openFoodScanner,
            icon: const Icon(Icons.camera_alt),
            tooltip: 'Scan Food',
          ),
          if (!_isManualEntry && _selectedFood == null && _allFoods.isNotEmpty)
            TextButton.icon(
              onPressed: _switchToManualEntry,
              icon: const Icon(Icons.edit, color: Colors.white, size: 18),
              label: const Text(
                'Manual',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          TextButton(
            onPressed: _saveFood,
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
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading food database...'),
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: Stack(
                children: [
                  ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildMealTypeChip(),
                      const SizedBox(height: 24),
                      _buildSearchField(),
                      if (_selectedFood != null) ...[
                        const SizedBox(height: 16),
                        _buildSelectedFoodCard(),
                      ],
                      const SizedBox(height: 24),
                      _buildServingSizeRow(),
                      const SizedBox(height: 24),
                      if (_isManualEntry || _selectedFood != null) ...[
                        _buildNutritionalInfo(),
                      ],
                      const SizedBox(height: 24),
                      if (!_isManualEntry &&
                          _selectedFood == null &&
                          _allFoods.isNotEmpty)
                        _buildQuickAddButtons(),
                      const SizedBox(height: 16),
                      _buildAiFeedbackBubble(),
                      const SizedBox(height: 32),
                    ],
                  ),
                  if (_showSearchResults && _searchResults.isNotEmpty)
                    _buildSearchResultsOverlay(),
                ],
              ),
            ),
    );
  }

  Color _getMealTypeColor() {
    switch (widget.mealType) {
      case 'breakfast':
        return const Color(0xFFFFBE0B);
      case 'lunch':
        return const Color(0xFF4ECDC4);
      case 'dinner':
        return const Color(0xFF45B7D1);
      case 'snack':
        return const Color(0xFFFF006E);
      default:
        return Colors.grey;
    }
  }

  Widget _buildMealTypeChip() {
    final mealTypeInfo = _getMealTypeInfo(widget.mealType);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            mealTypeInfo['color'].withAlpha(51),
            mealTypeInfo['color'].withAlpha(26),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: mealTypeInfo['color'].withAlpha(77),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(mealTypeInfo['icon'], color: mealTypeInfo['color']),
          const SizedBox(width: 8),
          Text(
            mealTypeInfo['name'],
            style: TextStyle(
              color: mealTypeInfo['color'],
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getMealTypeInfo(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return {
          'name': 'Breakfast',
          'icon': Icons.wb_sunny_rounded,
          'color': const Color(0xFFFFBE0B),
        };
      case 'lunch':
        return {
          'name': 'Lunch',
          'icon': Icons.lunch_dining_rounded,
          'color': const Color(0xFF4ECDC4),
        };
      case 'dinner':
        return {
          'name': 'Dinner',
          'icon': Icons.dinner_dining_rounded,
          'color': const Color(0xFF45B7D1),
        };
      case 'snack':
        return {
          'name': 'Snack',
          'icon': Icons.cookie_rounded,
          'color': const Color(0xFFFF006E),
        };
      default:
        return {'name': 'Meal', 'icon': Icons.restaurant, 'color': Colors.grey};
    }
  }

  Widget _buildSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.search, color: _getMealTypeColor()),
            const SizedBox(width: 8),
            Text(
              _allFoods.isEmpty ? 'Enter Food Name' : 'Search Food',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: _allFoods.isEmpty
                ? 'Enter food name manually...'
                : 'Type to search from ${_allFoods.length} foods...',
            prefixIcon: Icon(Icons.restaurant_menu, color: _getMealTypeColor()),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _selectedFood = null;
                        _showSearchResults = false;
                      });
                    },
                  )
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: _getMealTypeColor(), width: 2),
            ),
            filled: true,
            fillColor: Theme.of(context).cardColor,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a food name';
            }
            return null;
          },
          textCapitalization: TextCapitalization.words,
        ),
      ],
    );
  }

  Widget _buildSearchResultsOverlay() {
    return Positioned(
      top: 160,
      left: 20,
      right: 20,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 300),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _getMealTypeColor().withAlpha(77)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.all(8),
            itemCount: _searchResults.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final food = _searchResults[index];
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getMealTypeColor().withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.fastfood,
                    color: _getMealTypeColor(),
                    size: 20,
                  ),
                ),
                title: Text(
                  food.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Per 100g: ${food.calories.toInt()} kcal • P: ${food.protein.toInt()}g C: ${food.carbs.toInt()}g F: ${food.fat.toInt()}g',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(153),
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: _getMealTypeColor(),
                ),
                onTap: () => _selectFood(food),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedFoodCard() {
    if (_selectedFood == null) return const SizedBox.shrink();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _getMealTypeColor().withAlpha(26),
              _getMealTypeColor().withAlpha(13),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _getMealTypeColor().withAlpha(77)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: _getMealTypeColor()),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedFood!.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Nutritional values per 100g:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildNutrientChip(
                  '${_selectedFood!.calories.toInt()} kcal',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
                _buildNutrientChip(
                  'P: ${_selectedFood!.protein.toInt()}g',
                  Icons.fitness_center,
                  Colors.blue,
                ),
                _buildNutrientChip(
                  'C: ${_selectedFood!.carbs.toInt()}g',
                  Icons.grain,
                  Colors.amber,
                ),
                _buildNutrientChip(
                  'F: ${_selectedFood!.fat.toInt()}g',
                  Icons.opacity,
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServingSizeRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.straighten, color: _getMealTypeColor()),
            const SizedBox(width: 8),
            const Text(
              'Serving Size',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _servingSizeController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (double.tryParse(value) == null) return 'Invalid';
                  return null;
                },
                onChanged: (value) {
                  if (_selectedFood != null && value.isNotEmpty) {
                    _calculateNutrients();
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _servingUnit,
                decoration: InputDecoration(
                  labelText: 'Unit',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                ),
                items: ['g', 'ml', 'oz', 'cup', 'piece', 'serving']
                    .map(
                      (unit) =>
                          DropdownMenuItem(value: unit, child: Text(unit)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() => _servingUnit = value!);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNutritionalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.restaurant, color: _getMealTypeColor()),
            const SizedBox(width: 8),
            const Text(
              'Nutritional Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildNumberField(
          controller: _caloriesController,
          label: 'Calories',
          icon: Icons.local_fire_department,
          suffix: 'kcal',
          color: Colors.orange,
          readOnly: !_isManualEntry,
          onChanged: (val) => _triggerAiAnalysis(),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildNumberField(
                controller: _proteinController,
                label: 'Protein',
                icon: Icons.fitness_center,
                suffix: 'g',
                color: Colors.blue,
                readOnly: !_isManualEntry,
                onChanged: (val) => _triggerAiAnalysis(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildNumberField(
                controller: _carbsController,
                label: 'Carbs',
                icon: Icons.grain,
                suffix: 'g',
                color: Colors.amber,
                readOnly: !_isManualEntry,
                onChanged: (val) => _triggerAiAnalysis(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildNumberField(
          controller: _fatController,
          label: 'Fat',
          icon: Icons.opacity,
          suffix: 'g',
          color: Colors.purple,
          readOnly: !_isManualEntry,
          onChanged: (val) => _triggerAiAnalysis(),
        ),
      ],
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String suffix,
    required Color color,
    bool readOnly = false,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: color),
        suffixText: suffix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: readOnly ? color.withAlpha(13) : Theme.of(context).cardColor,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required';
        if (double.tryParse(value) == null) return 'Invalid';
        return null;
      },
    );
  }

  Widget _buildQuickAddButtons() {
    final commonFoods = _allFoods
        .where((food) {
          final name = food.name.toLowerCase();
          return name.contains('banana') ||
              name.contains('apple') ||
              name.contains('egg') ||
              name.contains('chicken') ||
              name.contains('rice') ||
              name.contains('milk');
        })
        .take(6)
        .toList();

    if (commonFoods.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.flash_on, color: _getMealTypeColor()),
            const SizedBox(width: 8),
            const Text(
              'Quick Add',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: commonFoods.map((food) {
            return ActionChip(
              label: Text(food.name),
              avatar: Icon(
                Icons.flash_on,
                size: 16,
                color: _getMealTypeColor(),
              ),
              backgroundColor: _getMealTypeColor().withAlpha(26),
              side: BorderSide(color: _getMealTypeColor().withAlpha(77)),
              onPressed: () => _selectFood(food),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAiFeedbackBubble() {
    if (_isAiLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.purple.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Gemini is analyzing...',
              style: TextStyle(
                fontSize: 13,
                color: Colors.purple.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_aiFeedback == null) return const SizedBox.shrink();

    final isGood = _aiFeedback!['isGood'] ?? true;
    final message = _aiFeedback!['message'] ?? '';
    final suggestion = _aiFeedback!['suggestion'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isGood ? Colors.green : Colors.orange).withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isGood ? Colors.green : Colors.orange).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isGood ? Icons.check_circle_outline : Icons.lightbulb_outline,
                color: isGood ? Colors.green : Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                isGood ? 'AI Approval' : 'AI Tip',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isGood
                      ? Colors.green.shade700
                      : Colors.orange.shade800,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.psychology_outlined,
                size: 16,
                color: Colors.purple,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(fontSize: 13, height: 1.4)),
          if (suggestion != null) ...[
            const SizedBox(height: 8),
            Text(
              'Tip: $suggestion',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
