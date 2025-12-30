import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/food_entry.dart';
import '../models/user_profile.dart';
import '../utils/storage_helper.dart';
import '../widgets/nutrition_ring_chart.dart';
import '../widgets/meal_section.dart';
import '../widgets/water_tracker.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/animated_progress_ring.dart';
import '../widgets/animated_counter.dart';
import '../widgets/empty_state_widget.dart';
import 'add_food_screen.dart';
import 'ai_insights_screen.dart';
import 'food_scanner_screen.dart';
import '../widgets/steps_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
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
          ? CustomScrollView(
              physics: const NeverScrollableScrollPhysics(),
              slivers: [
                _buildModernAppBar(),
                const SliverToBoxAdapter(child: SkeletonHomeScreen()),
              ],
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
                        child: AnimationLimiter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: AnimationConfiguration.toStaggeredList(
                              duration: const Duration(milliseconds: 600),
                              childAnimationBuilder: (widget) => SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(child: widget),
                              ),
                              children: [
                                _buildWelcomeCard(),
                                const SizedBox(height: 20),
                                _buildQuickActions(),
                                const SizedBox(height: 20),
                                _buildQuickStats(),
                                const SizedBox(height: 24),
                                _buildNutritionOverview(),
                                const SizedBox(height: 24),
                                _buildAiCoachCard(),
                                const SizedBox(height: 24),
                                WaterTracker(
                                  currentIntake: _waterIntake,
                                  goal: _userProfile?.dailyWaterGoal ?? 2000,
                                  onIntakeChanged: (newIntake) {
                                    setState(() => _waterIntake = newIntake);
                                    final today = DateFormat(
                                      'yyyy-MM-dd',
                                    ).format(DateTime.now());
                                    StorageHelper.saveWaterIntake(
                                      today,
                                      newIntake,
                                    );
                                  },
                                ),
                                const SizedBox(height: 24),
                                const StepsWidget(stepGoal: 10000),
                                const SizedBox(height: 24),
                                _buildMealsSection(),
                              ],
                            ),
                          ),
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
      expandedHeight: 120,
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
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00C9FF).withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.eco_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)],
                            ).createShader(bounds),
                            child: const Text(
                              'NutriTrack',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.8,
                                height: 1.0,
                              ),
                            ),
                          ),
                          Text(
                            'Your Health Companion',
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.5),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  DateFormat('EEEE, MMMM d').format(DateTime.now()),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
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
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AnimatedCounter(
                          value: _totalCalories,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ' / ${calorieGoal.toInt()}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'calories today',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
              AnimatedProgressRing(
                progress: percentage / 100,
                size: 80,
                strokeWidth: 8,
                startColor: Colors.white,
                endColor: Colors.white.withOpacity(0.7),
                showMilestones: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedCounter(
                      value: percentage,
                      suffix: '%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Scan Food - HIGHLIGHTED
            Expanded(
              flex: 2,
              child: _buildQuickActionCard(
                icon: Icons.camera_alt_rounded,
                label: 'Scan Food',
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FoodScannerScreen(),
                    ),
                  );
                },
                isHighlighted: true,
              ),
            ),
            const SizedBox(width: 12),
            // Add Food
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.add_circle_outline,
                label: 'Add Food',
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade600],
                ),
                onTap: () => _navigateToAddFood('breakfast'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // AI Insights
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.psychology_rounded,
                label: 'AI Insights',
                gradient: LinearGradient(
                  colors: [Colors.purple.shade400, Colors.purple.shade600],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AiInsightsScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            // Search Foods
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.search_rounded,
                label: 'Search',
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                ),
                onTap: () {
                  // Navigate to search tab (index 1)
                  DefaultTabController.of(context).animateTo(1);
                },
              ),
            ),
            const SizedBox(width: 12),
            // Profile
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.person_rounded,
                label: 'Profile',
                gradient: LinearGradient(
                  colors: [Colors.orange.shade400, Colors.orange.shade600],
                ),
                onTap: () {
                  // Navigate to profile tab (index 3)
                  DefaultTabController.of(context).animateTo(3);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Gradient gradient,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(isHighlighted ? 20 : 16),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withOpacity(0.3),
                blurRadius: isHighlighted ? 12 : 8,
                offset: Offset(0, isHighlighted ? 6 : 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: isHighlighted ? 36 : 28),
              SizedBox(height: isHighlighted ? 12 : 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isHighlighted ? 16 : 13,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
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
        border: Border.all(color: color.withOpacity(0.2), width: 1),
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

  Widget _buildAiCoachCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade400, Colors.purple.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AiInsightsScreen()),
          ),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI Nutrition Coach',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Get personalized insights based on your goals',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withOpacity(0.7),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMealsSection() {
    // Check if there are any meals logged
    if (_todayEntries.isEmpty) {
      return EmptyStateWidget(
        type: EmptyStateType.noMeals,
        onActionPressed: () => _navigateToAddFood('breakfast'),
      );
    }

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
        AnimationLimiter(
          child: Column(
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 100),
              childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 30.0,
                child: FadeInAnimation(child: widget),
              ),
              children: [
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
            ),
          ),
        ),
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
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> _navigateToAddFood(String mealType) async {
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AddFoodScreen(mealType: mealType),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
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
