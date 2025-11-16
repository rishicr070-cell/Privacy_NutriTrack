import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/food_entry.dart';
import '../models/user_profile.dart';
import '../utils/storage_helper.dart';
import '../widgets/nutrition_ring_chart.dart';
import '../widgets/meal_section.dart';
import '../widgets/water_tracker.dart';
import 'add_food_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  List<FoodEntry> _todayEntries = [];
  UserProfile? _userProfile;
  int _waterIntake = 0;
  bool _isLoading = true;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _loadData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final entries = await StorageHelper.getFoodEntries();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    final todayEntries = entries.where((entry) {
      final entryDate = DateFormat('yyyy-MM-dd').format(entry.timestamp);
      return entryDate == today;
    }).toList();

    final profile = await StorageHelper.getUserProfile();
    final waterData = await StorageHelper.getWaterIntake();
    
    setState(() {
      _todayEntries = todayEntries;
      _userProfile = profile;
      _waterIntake = waterData[today] ?? 0;
      _isLoading = false;
    });

    _fadeController.forward();
    _slideController.forward();
  }

  double get _totalCalories =>
      _todayEntries.fold(0, (sum, entry) => sum + entry.calories);
  
  double get _totalProtein =>
      _todayEntries.fold(0, (sum, entry) => sum + entry.protein);
  
  double get _totalCarbs =>
      _todayEntries.fold(0, (sum, entry) => sum + entry.carbs);
  
  double get _totalFat =>
      _todayEntries.fold(0, (sum, entry) => sum + entry.fat);

  List<FoodEntry> _getEntriesForMeal(String mealType) {
    return _todayEntries.where((entry) => entry.mealType == mealType).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading your nutrition...',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            )
          : _buildMainContent(),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildMainContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: RefreshIndicator(
          onRefresh: () async {
            _fadeController.reset();
            _slideController.reset();
            await _loadData();
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeSection(),
                      const SizedBox(height: 24),
                      _buildQuickStats(),
                      const SizedBox(height: 24),
                      _buildNutritionOverview(),
                      const SizedBox(height: 24),
                      WaterTracker(
                        currentIntake: _waterIntake,
                        goal: _userProfile?.dailyWaterGoal ?? 2000,
                        onIntakeChanged: (newIntake) {
                          setState(() => _waterIntake = newIntake);
                          final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
                          StorageHelper.saveWaterIntake(today, newIntake);
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildMealsSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 160,
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
                const Color(0xFF00C9FF).withOpacity(0.15),
                const Color(0xFF92FE9D).withOpacity(0.08),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 20, right: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF00C9FF),
                            Color(0xFF92FE9D),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00C9FF).withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.eco_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Color(0xFF00C9FF),
                              Color(0xFF92FE9D),
                            ],
                          ).createShader(bounds),
                          child: const Text(
                            'NutriTrack',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -1.5,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        Text(
                          'Your Health Companion',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF00C9FF),
                            Color(0xFF92FE9D),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 12, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('EEEE, MMM d').format(DateTime.now()),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final calorieGoal = _userProfile?.dailyCalorieGoal ?? 2000;
    final calorieProgress = (_totalCalories / calorieGoal).clamp(0.0, 1.0);
    
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0.0, end: calorieProgress),
      builder: (context, value, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF00C9FF),
                Color(0xFF92FE9D),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00C9FF).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userProfile != null
                              ? 'Hello, ${_userProfile!.name}! 👋'
                              : 'Welcome! 👋',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _totalCalories > 0
                              ? 'You\'ve logged ${_totalCalories.toInt()} calories today'
                              : 'Start tracking your nutrition',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _totalCalories > calorieGoal * 0.8
                          ? Icons.check_circle
                          : Icons.restaurant_menu,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_totalCalories.toInt()} kcal',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${calorieGoal.toInt()} kcal goal',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(child: _buildQuickStatCard('Meals', '${_todayEntries.length}', Icons.restaurant, const Color(0xFFFF6B6B))),
        const SizedBox(width: 12),
        Expanded(child: _buildQuickStatCard('Protein', '${_totalProtein.toInt()}g', Icons.fitness_center, const Color(0xFF4ECDC4))),
        const SizedBox(width: 12),
        Expanded(child: _buildQuickStatCard('Water', '${(_waterIntake / 1000).toStringAsFixed(1)}L', Icons.water_drop, const Color(0xFF45B7D1))),
      ],
    );
  }

  Widget _buildQuickStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionOverview() {
    final calorieGoal = _userProfile?.dailyCalorieGoal ?? 2000;
    final proteinGoal = _userProfile?.dailyProteinGoal ?? 150;
    final carbsGoal = _userProfile?.dailyCarbsGoal ?? 200;
    final fatGoal = _userProfile?.dailyFatGoal ?? 65;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).cardColor,
              Theme.of(context).cardColor.withOpacity(0.8),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.donut_large, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Today\'s Nutrition',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF00C9FF).withOpacity(0.2),
                          const Color(0xFF92FE9D).withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_totalCalories.toInt()} / ${calorieGoal.toInt()}',
                      style: const TextStyle(
                        color: Color(0xFF00C9FF),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              NutritionRingChart(
                calories: _totalCalories,
                protein: _totalProtein,
                carbs: _totalCarbs,
                fat: _totalFat,
                calorieGoal: calorieGoal,
                proteinGoal: proteinGoal,
                carbsGoal: carbsGoal,
                fatGoal: fatGoal,
              ),
              const SizedBox(height: 24),
              _buildMacroRow('Protein', _totalProtein, proteinGoal, const Color(0xFF4ECDC4)),
              const SizedBox(height: 16),
              _buildMacroRow('Carbs', _totalCarbs, carbsGoal, const Color(0xFFFFBE0B)),
              const SizedBox(height: 16),
              _buildMacroRow('Fat', _totalFat, fatGoal, const Color(0xFFFF006E)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroRow(String name, double current, double goal, Color color) {
    final percentage = (current / goal).clamp(0.0, 1.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            Text(
              '${current.toInt()}g / ${goal.toInt()}g',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
          tween: Tween(begin: 0.0, end: percentage),
          builder: (context, value, child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 10,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMealsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.restaurant, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Today\'s Meals',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        MealSection(
          title: 'Breakfast',
          icon: Icons.wb_sunny_rounded,
          color: const Color(0xFFFFBE0B),
          entries: _getEntriesForMeal('breakfast'),
          onAddPressed: () => _navigateToAddFood('breakfast'),
          onDeleteEntry: _deleteEntry,
        ),
        const SizedBox(height: 16),
        MealSection(
          title: 'Lunch',
          icon: Icons.lunch_dining_rounded,
          color: const Color(0xFF4ECDC4),
          entries: _getEntriesForMeal('lunch'),
          onAddPressed: () => _navigateToAddFood('lunch'),
          onDeleteEntry: _deleteEntry,
        ),
        const SizedBox(height: 16),
        MealSection(
          title: 'Dinner',
          icon: Icons.dinner_dining_rounded,
          color: const Color(0xFF45B7D1),
          entries: _getEntriesForMeal('dinner'),
          onAddPressed: () => _navigateToAddFood('dinner'),
          onDeleteEntry: _deleteEntry,
        ),
        const SizedBox(height: 16),
        MealSection(
          title: 'Snacks',
          icon: Icons.cookie_rounded,
          color: const Color(0xFFFF006E),
          entries: _getEntriesForMeal('snack'),
          onAddPressed: () => _navigateToAddFood('snack'),
          onDeleteEntry: _deleteEntry,
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00C9FF).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToAddFood('breakfast'),
          borderRadius: BorderRadius.circular(30),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: Colors.white, size: 24),
                SizedBox(width: 8),
                Text(
                  'Add Food',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToAddFood(String mealType) async {
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => AddFoodScreen(mealType: mealType),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
      ),
    );

    if (result == true) {
      _fadeController.reset();
      _slideController.reset();
      _loadData();
    }
  }

  Future<void> _deleteEntry(String id) async {
    await StorageHelper.deleteFoodEntry(id);
    _fadeController.reset();
    _slideController.reset();
    _loadData();
  }
}
