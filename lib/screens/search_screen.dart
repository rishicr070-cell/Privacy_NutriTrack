import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:privacy_first_nutrition_tracking_app/models/food_item.dart';
import 'package:privacy_first_nutrition_tracking_app/utils/food_data_loader.dart';
// import 'package:mobile_scanner/mobile_scanner.dart'; // Disabled for web compatibility
import '../models/food_entry.dart';
import '../utils/storage_helper.dart';
import 'add_food_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with AutomaticKeepAliveClientMixin {
  final _searchController = TextEditingController();
  List<FoodItem> _searchResults = [];
  bool _isSearching = false;
  String _selectedMealType = 'breakfast';
  late Future<List<FoodItem>> _foodItemsFuture;
  List<FoodItem> _allFoodItems = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _foodItemsFuture = FoodDataLoader.loadFoodItems();
    _foodItemsFuture.then((items) {
      setState(() {
        _allFoodItems = items;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults = _allFoodItems
          .where((food) =>
              food.foodName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _addFoodFromSearch(FoodItem food) async {
    final entry = FoodEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: food.foodName,
      calories: food.energyKcal,
      protein: food.proteinG,
      carbs: food.carbG,
      fat: food.fatG,
      servingSize: 100, // Assuming 100g serving, you can adjust this
      servingUnit: 'g',
      timestamp: DateTime.now(),
      mealType: _selectedMealType,
    );

    await StorageHelper.saveFoodEntry(entry);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${food.foodName} added to $_selectedMealType'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showBarcodeScanner() {
    if (kIsWeb) {
      // Barcode scanner not available on web
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Barcode scanner is not available on web. Please use mobile app.'),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    /* Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BarcodeScannerScreen(
          onBarcodeDetected: (barcode) {
            // In a real app, you'd lookup the barcode in a database
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Scanned: $barcode'),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ),
    ); */
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 16),
                  _buildMealTypeSelector(),
                  const SizedBox(height: 24),
                  FutureBuilder<List<FoodItem>>(
                    future: _foodItemsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error loading food data: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No food data found.'));
                      } else {
                        if (_isSearching && _searchResults.isEmpty) {
                          return _buildNoResults();
                        } else if (_searchResults.isNotEmpty) {
                          return _buildSearchResults();
                        } else {
                          return _buildCategorySections();
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 100,
      floating: true,
      pinned: false,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.green.withOpacity(0.1),
                Colors.blue.withOpacity(0.05),
              ],
            ),
          ),
        ),
        title: const Text(
          'Search Foods',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: _performSearch,
            decoration: InputDecoration(
              hintText: 'Search for foods...', 
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _performSearch('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              filled: true,
              fillColor: Theme.of(context).cardColor,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            onPressed: _showBarcodeScanner,
            tooltip: 'Scan Barcode',
          ),
        ),
      ],
    );
  }

  Widget _buildMealTypeSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildMealTypeChip('breakfast', 'Breakfast', Icons.wb_sunny_rounded, Colors.orange),
          _buildMealTypeChip('lunch', 'Lunch', Icons.lunch_dining_rounded, Colors.green),
          _buildMealTypeChip('dinner', 'Dinner', Icons.dinner_dining_rounded, Colors.blue),
          _buildMealTypeChip('snack', 'Snack', Icons.cookie_rounded, Colors.purple),
        ],
      ),
    );
  }

  Widget _buildMealTypeChip(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedMealType == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: isSelected ? Colors.white : color),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
        onSelected: (selected) {
          setState(() {
            _selectedMealType = value;
          });
        },
        selectedColor: color,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.search_off,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No foods found',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddFoodScreen(mealType: _selectedMealType),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Custom Food'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search Results',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ..._searchResults.map((food) => _buildFoodCard(food)),
      ],
    );
  }

  Widget _buildCategorySections() {
    // For simplicity, we are not grouping by category from the CSV data yet.
    // This can be implemented later.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Foods',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ..._allFoodItems.take(10).map((food) => _buildFoodCard(food)), // Show first 10 items
      ],
    );
  }

  Widget _buildFoodCard(FoodItem food) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      child: InkWell(
        onTap: () => _addFoodFromSearch(food),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.restaurant,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.foodName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '100g • ${food.energyKcal.toInt()} kcal',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'P: ${food.proteinG}g • C: ${food.carbG}g • F: ${food.fatG}g',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.add_circle,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* Barcode scanner disabled for web compatibility
class BarcodeScannerScreen extends StatelessWidget {
  final Function(String) onBarcodeDetected;

  const BarcodeScannerScreen({
    super.key,
    required this.onBarcodeDetected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        backgroundColor: Colors.black,
      ),
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              onBarcodeDetected(barcode.rawValue!); 
              Navigator.pop(context);
              break;
            }
          }
        },
      ),
    );
  }
}
*/
