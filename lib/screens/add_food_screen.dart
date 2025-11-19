import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/food_entry.dart';
import '../models/food_item.dart';
import '../utils/storage_helper.dart';
import '../utils/food_data_loader.dart';

class AddFoodScreen extends StatefulWidget {
  final String mealType;
  final FoodEntry? existingEntry;

  const AddFoodScreen({
    super.key,
    required this.mealType,
    this.existingEntry,
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
  
  String _servingUnit = 'g';
  List<FoodItem> _allFoods = [];
  List<FoodItem> _searchResults = [];
  FoodItem? _selectedFood;
  bool _isLoading = true;
  bool _showSearchResults = false;
  bool _isManualEntry = false;

  @override
  void initState() {
    super.initState();
    _loadFoodData();
    if (widget.existingEntry != null) {
      _populateExistingEntry();
    }
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadFoodData() async {
    setState(() => _isLoading = true);
    try {
      final foods = await FoodDataLoader.loadFoodItems(); // Fixed method name
      setState(() {
        _allFoods = foods;
        _isLoading = false;
      });
    } catch (e) {
      // print('Error loading food data: $e');
      setState(() {
        _isLoading = false;
        _isManualEntry = true; // Fallback to manual entry if loading fails
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
      _searchResults = _allFoods.where((food) {
        final nameMatch = food.name.toLowerCase().contains(query);
        final categoryMatch = food.category?.toLowerCase().contains(query) ?? false;
        return nameMatch || categoryMatch;
      }).take(10).toList();
      _showSearchResults = _searchResults.isNotEmpty;
    });
  }

  void _selectFood(FoodItem food) {
    setState(() {
      _selectedFood = food;
      _searchController.text = food.name;
      _showSearchResults = false;
      _isManualEntry = false;
    });
    
    // Calculate nutrients for current serving size
    _calculateNutrients();
  }

  void _calculateNutrients() {
    if (_selectedFood == null) return;

    final servingSize = double.tryParse(_servingSizeController.text) ?? 100;
    final multiplier = servingSize / 100; // Food data is per 100g

    setState(() {
      _caloriesController.text = (_selectedFood!.calories * multiplier).toStringAsFixed(1);
      _proteinController.text = (_selectedFood!.protein * multiplier).toStringAsFixed(1);
      _carbsController.text = (_selectedFood!.carbs * multiplier).toStringAsFixed(1);
      _fatController.text = (_selectedFood!.fat * multiplier).toStringAsFixed(1);
    });
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
    super.dispose();
  }

  Future<void> _saveFood() async {
    if (_formKey.currentState!.validate()) {
      final entry = FoodEntry(
        id: widget.existingEntry?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingEntry != null ? 'Edit Food' : 'Add Food'),
        backgroundColor: _getMealTypeColor(),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!_isManualEntry && _selectedFood == null && _allFoods.isNotEmpty)
            TextButton.icon(
              onPressed: _switchToManualEntry,
              icon: const Icon(Icons.edit, color: Colors.white, size: 18),
              label: const Text(
                'Manual',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
                      if (!_isManualEntry && _selectedFood == null && _allFoods.isNotEmpty)
                        _buildQuickAddButtons(),
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
          'color': const Color(0xFFFFBE0B)
        };
      case 'lunch':
        return {
          'name': 'Lunch',
          'icon': Icons.lunch_dining_rounded,
          'color': const Color(0xFF4ECDC4)
        };
      case 'dinner':
        return {
          'name': 'Dinner',
          'icon': Icons.dinner_dining_rounded,
          'color': const Color(0xFF45B7D1)
        };
      case 'snack':
        return {
          'name': 'Snack',
          'icon': Icons.cookie_rounded,
          'color': const Color(0xFFFF006E)
        };
      default:
        return {
          'name': 'Meal',
          'icon': Icons.restaurant,
          'color': Colors.grey
        };
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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
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
                  child: Icon(Icons.fastfood, color: _getMealTypeColor(), size: 20),
                ),
                title: Text(
                  food.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Per 100g: ${food.calories.toInt()} kcal • P: ${food.protein.toInt()}g C: ${food.carbs.toInt()}g F: ${food.fat.toInt()}g',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
                  ),
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: _getMealTypeColor()),
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
                _buildNutrientChip('${_selectedFood!.calories.toInt()} kcal', Icons.local_fire_department, Colors.orange),
                _buildNutrientChip('P: ${_selectedFood!.protein.toInt()}g', Icons.fitness_center, Colors.blue),
                _buildNutrientChip('C: ${_selectedFood!.carbs.toInt()}g', Icons.grain, Colors.amber),
                _buildNutrientChip('F: ${_selectedFood!.fat.toInt()}g', Icons.opacity, Colors.purple),
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
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
                initialValue: _servingUnit,
                decoration: InputDecoration(
                  labelText: 'Unit',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                ),
                items: ['g', 'ml', 'oz', 'cup', 'piece', 'serving']
                    .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
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
        fillColor: readOnly 
            ? color.withAlpha(13) 
            : Theme.of(context).cardColor,
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
    final commonFoods = _allFoods.where((food) {
      final name = food.name.toLowerCase();
      return name.contains('banana') ||
          name.contains('apple') ||
          name.contains('egg') ||
          name.contains('chicken') ||
          name.contains('rice') ||
          name.contains('milk');
    }).take(6).toList();

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
              avatar: Icon(Icons.flash_on, size: 16, color: _getMealTypeColor()),
              backgroundColor: _getMealTypeColor().withAlpha(26),
              side: BorderSide(color: _getMealTypeColor().withAlpha(77)),
              onPressed: () => _selectFood(food),
            );
          }).toList(),
        ),
      ],
    );
  }
}
