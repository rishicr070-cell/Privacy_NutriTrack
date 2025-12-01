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

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  List<FoodEntry> _todayEntries = [];
  UserProfile? _userProfile;
  int _waterIntake = 0;
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
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
    
    _animationController.forward();
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
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 1500),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading your nutrition data...',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              color: Theme.of(context).colorScheme.primary,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildModernAppBar(),
                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildWelcomeCard(),
                            const SizedBox(height: 20),
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
                  ),
                ],
              ),
            ),
      floatingActionButton: _buildModernFAB(),
    );
  }

  Widget _buildModernAppBar() {
    return SliverAppBar(
      expandedHeight: 100,
      floating: true,
      pinned: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.15),
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NutriTrack',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE, MMMM d').format(DateTime.now()),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    final calorieGoal = _userProfile?.dailyCalorieGoal ?? 2000;
    final percentage = (_totalCalories / calorieGoal * 100).clamp(0.0, 100.0);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.wb_sunny_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userProfile != null
                          ? 'Hello, ${_userProfile!.name}! 👋'
                          : 'Welcome Back! 👋',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getMotivationalMessage(percentage),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_totalCalories.toInt()} / ${calorieGoal.toInt()} kcal',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${percentage.toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMotivationalMessage(double percentage) {
    if (percentage < 30) return "Let's fuel your day! 🚀";
    if (percentage < 70) return "You're making great progress! 💪";
    if (percentage < 100) return "Almost there, keep it up! ⭐";
    return "Goal crushed! Amazing work! 🎉";
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.local_fire_department,
            label: 'Calories',
            value: _totalCalories.toInt().toString(),
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.fitness_center,
            label: 'Protein',
            value: '${_totalProtein.toInt()}g',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.restaurant,
            label: 'Meals',
            value: _todayEntries.length.toString(),
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
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

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.pie_chart_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Nutrition Overview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
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
          _buildMacroRow('Protein', _totalProtein, proteinGoal, Colors.blue),
          const SizedBox(height: 16),
          _buildMacroRow('Carbs', _totalCarbs, carbsGoal, Colors.orange),
          const SizedBox(height: 16),
          _buildMacroRow('Fat', _totalFat, fatGoal, Colors.purple),
        ],
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
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
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
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Stack(
          children: [
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            FractionallySizedBox(
              widthFactor: percentage,
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.restaurant_menu,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
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
          color: const Color(0xFFFF9500),
          entries: _getEntriesForMeal('breakfast'),
          onAddPressed: () => _navigateToAddFood('breakfast'),
          onDeleteEntry: _deleteEntry,
        ),
        const SizedBox(height: 12),
        MealSection(
          title: 'Lunch',
          icon: Icons.lunch_dining_rounded,
          color: const Color(0xFF34C759),
          entries: _getEntriesForMeal('lunch'),
          onAddPressed: () => _navigateToAddFood('lunch'),
          onDeleteEntry: _deleteEntry,
        ),
        const SizedBox(height: 12),
        MealSection(
          title: 'Dinner',
          icon: Icons.dinner_dining_rounded,
          color: const Color(0xFF007AFF),
          entries: _getEntriesForMeal('dinner'),
          onAddPressed: () => _navigateToAddFood('dinner'),
          onDeleteEntry: _deleteEntry,
        ),
        const SizedBox(height: 12),
        MealSection(
          title: 'Snacks',
          icon: Icons.cookie_rounded,
          color: const Color(0xFFAF52DE),
          entries: _getEntriesForMeal('snack'),
          onAddPressed: () => _navigateToAddFood('snack'),
          onDeleteEntry: _deleteEntry,
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildModernFAB() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () => _navigateToAddFood('breakfast'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(Icons.add_rounded, size: 28),
        label: const Text(
          'Add Food',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
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
          const curve = Curves.easeOutCubic;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  Future<void> _deleteEntry(String id) async {
    await StorageHelper.deleteFoodEntry(id);
    _loadData();
  }
}
