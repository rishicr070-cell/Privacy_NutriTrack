import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:privacy_first_nutrition_tracking_app/data/models/food_item.dart';
import 'package:privacy_first_nutrition_tracking_app/data/local/food_data_loader.dart';
import 'package:privacy_first_nutrition_tracking_app/data/models/food_entry.dart';
import 'package:privacy_first_nutrition_tracking_app/data/local/storage_helper.dart';
import 'package:privacy_first_nutrition_tracking_app/ui/widgets/empty_state_widget.dart';
import 'add_food_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  List<FoodItem> _searchResults = [];
  bool _isSearching = false;
  String _selectedMealType = 'breakfast';
  late Future<List<FoodItem>> _foodItemsFuture;
  List<FoodItem> _allFoodItems = [];
  Set<String> _favoriteFoods = {};
  List<String> _recentFoods = [];
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentTabIndex = _tabController.index;
        });
      }
    });
    _foodItemsFuture = FoodDataLoader.loadFoodItems();
    _foodItemsFuture.then((items) {
      setState(() {
        _allFoodItems = items;
      });
    });
    _loadFavoritesAndRecent();
  }

  Future<void> _loadFavoritesAndRecent() async {
    final favorites = await StorageHelper.getFavoriteFoods();
    final recent = await StorageHelper.getRecentFoods(limit: 20);
    setState(() {
      _favoriteFoods = favorites;
      _recentFoods = recent;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
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
      List<FoodItem> results = _allFoodItems
          .where(
            (food) => food.foodName.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();

      // Filter by tab
      if (_currentTabIndex == 1) {
        // Favorites tab
        results = results
            .where((food) => _favoriteFoods.contains(food.foodName))
            .toList();
      } else if (_currentTabIndex == 2) {
        // Recent tab
        results = results
            .where((food) => _recentFoods.contains(food.foodName))
            .toList();
      }

      _searchResults = results;
    });
  }

  Future<void> _toggleFavorite(String foodName) async {
    await StorageHelper.toggleFavoriteFood(foodName);
    await _loadFavoritesAndRecent();
    // Refresh search if needed
    if (_searchController.text.isNotEmpty) {
      _performSearch(_searchController.text);
    }
  }

  Future<void> _addFoodFromSearch(FoodItem food) async {
    final entry = FoodEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: food.foodName,
      calories: food.energyKcal,
      protein: food.proteinG,
      carbs: food.carbG,
      fat: food.fatG,
      servingSize: 100,
      servingUnit: 'g',
      timestamp: DateTime.now(),
      mealType: _selectedMealType,
    );

    await StorageHelper.saveFoodEntry(entry);
    await _loadFavoritesAndRecent(); // Refresh recent foods

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Barcode scanner is not available on web. Please use mobile app.',
          ),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
  }

  List<FoodItem> _getDisplayFoods() {
    if (_currentTabIndex == 1) {
      // Favorites
      return _allFoodItems
          .where((food) => _favoriteFoods.contains(food.foodName))
          .toList();
    } else if (_currentTabIndex == 2) {
      // Recent
      return _allFoodItems
          .where((food) => _recentFoods.contains(food.foodName))
          .toList();
    }
    return _allFoodItems.take(10).toList();
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
                  _buildTabBar(),
                  const SizedBox(height: 16),
                  _buildMealTypeSelector(),
                  const SizedBox(height: 24),
                  FutureBuilder<List<FoodItem>>(
                    future: _foodItemsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error loading food data: ${snapshot.error}',
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No food data found.'));
                      } else {
                        if (_isSearching && _searchResults.isEmpty) {
                          return _buildNoResults();
                        } else if (_searchResults.isNotEmpty) {
                          return _buildSearchResults();
                        } else if (_searchController.text.isEmpty) {
                          return _buildDefaultView();
                        } else {
                          return _buildDefaultView();
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
              colors: [Colors.green.withAlpha(26), Colors.blue.withAlpha(13)],
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
    return TextField(
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: Theme.of(context).cardColor,
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade400, Colors.blue.shade400],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Theme.of(
          context,
        ).colorScheme.onSurface.withOpacity(0.6),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.restaurant_menu, size: 18),
                const SizedBox(width: 6),
                const Text('All'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, size: 18),
                const SizedBox(width: 6),
                Text('Fav (${_favoriteFoods.length})'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.history, size: 18),
                const SizedBox(width: 4),
                Text('(${_recentFoods.length})'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealTypeSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildMealTypeChip(
            'breakfast',
            'Breakfast',
            Icons.wb_sunny_rounded,
            Colors.orange,
          ),
          _buildMealTypeChip(
            'lunch',
            'Lunch',
            Icons.lunch_dining_rounded,
            Colors.green,
          ),
          _buildMealTypeChip(
            'dinner',
            'Dinner',
            Icons.dinner_dining_rounded,
            Colors.blue,
          ),
          _buildMealTypeChip(
            'snack',
            'Snack',
            Icons.cookie_rounded,
            Colors.purple,
          ),
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
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: isSelected ? Colors.white : color),
              const SizedBox(width: 6),
              Text(label),
            ],
          ),
        ),
        onSelected: (selected) {
          setState(() {
            _selectedMealType = value;
          });
        },
        selectedColor: color,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected
              ? Colors.white
              : Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return EmptyStateWidget(
      type: EmptyStateType.noSearchResults,
      onActionPressed: () {
        _searchController.clear();
        _performSearch('');
      },
    );
  }

  Widget _buildDefaultView() {
    final displayFoods = _getDisplayFoods();

    if (displayFoods.isEmpty) {
      if (_currentTabIndex == 1) {
        return _buildEmptyFavorites();
      } else if (_currentTabIndex == 2) {
        return _buildEmptyRecent();
      } else {
        return EmptyStateWidget(
          type: EmptyStateType.searchPrompt,
          onActionPressed: _showBarcodeScanner,
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _currentTabIndex == 1
              ? 'Your Favorite Foods'
              : _currentTabIndex == 2
              ? 'Recently Added Foods'
              : 'Popular Foods',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ...displayFoods.map((food) => _buildFoodCard(food)),
      ],
    );
  }

  Widget _buildEmptyFavorites() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.star_outline, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No Favorites Yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the star icon on any food to add it to your favorites for quick access!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyRecent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No Recent Foods',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Foods you add will appear here for quick logging!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search Results (${_searchResults.length})',
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

  Widget _buildFoodCard(FoodItem food) {
    final isFavorite = _favoriteFoods.contains(food.foodName);

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
                  color: Theme.of(context).colorScheme.primary.withAlpha(26),
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
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(153),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'P: ${food.proteinG}g • C: ${food.carbG}g • F: ${food.fatG}g',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(128),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.star : Icons.star_outline,
                  color: isFavorite ? Colors.amber : Colors.grey,
                  size: 28,
                ),
                onPressed: () => _toggleFavorite(food.foodName),
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
