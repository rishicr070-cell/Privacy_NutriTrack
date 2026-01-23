import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:privacy_first_nutrition_tracking_app/data/models/food_entry.dart';
import 'package:privacy_first_nutrition_tracking_app/data/local/storage_helper.dart';
import 'package:privacy_first_nutrition_tracking_app/ui/widgets/empty_state_widget.dart';
import 'package:privacy_first_nutrition_tracking_app/ui/widgets/skeleton_loader.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with AutomaticKeepAliveClientMixin {
  List<FoodEntry> _allEntries = [];
  bool _isLoading = true;
  int _selectedDays = 7;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final entries = await StorageHelper.getFoodEntries();
    setState(() {
      _allEntries = entries;
      _isLoading = false;
    });
  }

  List<FoodEntry> get _recentEntries {
    final cutoffDate = DateTime.now().subtract(Duration(days: _selectedDays));
    return _allEntries
        .where((entry) => entry.timestamp.isAfter(cutoffDate))
        .toList();
  }

  Map<String, double> get _dailyCalories {
    final Map<String, double> data = {};
    for (var entry in _recentEntries) {
      final dateKey = DateFormat('yyyy-MM-dd').format(entry.timestamp);
      data[dateKey] = (data[dateKey] ?? 0) + entry.calories;
    }
    return data;
  }

  Map<String, Map<String, double>> get _dailyMacros {
    final Map<String, Map<String, double>> data = {};
    for (var entry in _recentEntries) {
      final dateKey = DateFormat('yyyy-MM-dd').format(entry.timestamp);
      data[dateKey] ??= {'protein': 0, 'carbs': 0, 'fat': 0};
      data[dateKey]!['protein'] =
          (data[dateKey]!['protein'] ?? 0) + entry.protein;
      data[dateKey]!['carbs'] = (data[dateKey]!['carbs'] ?? 0) + entry.carbs;
      data[dateKey]!['fat'] = (data[dateKey]!['fat'] ?? 0) + entry.fat;
    }
    return data;
  }

  double get _averageCalories {
    if (_dailyCalories.isEmpty) return 0;
    return _dailyCalories.values.reduce((a, b) => a + b) /
        _dailyCalories.length;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: _isLoading
          ? CustomScrollView(
              physics: const NeverScrollableScrollPhysics(),
              slivers: [
                _buildAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _buildTimeRangeSelector(),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(child: SkeletonCard(height: 120)),
                            const SizedBox(width: 12),
                            Expanded(child: SkeletonCard(height: 120)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const SkeletonChart(height: 250),
                        const SizedBox(height: 24),
                        const SkeletonChart(height: 250),
                        const SizedBox(height: 24),
                        const SkeletonChart(height: 250),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTimeRangeSelector(),
                          const SizedBox(height: 24),
                          _buildStatsCards(),
                          const SizedBox(height: 24),
                          _buildCaloriesChart(),
                          const SizedBox(height: 24),
                          _buildMacrosChart(),
                          const SizedBox(height: 24),
                          _buildMealDistribution(),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
              colors: [Colors.purple.withAlpha(26), Colors.blue.withAlpha(13)],
            ),
          ),
        ),
        title: const Text(
          'Analytics',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildTimeRangeChip(7, '7 Days'),
          _buildTimeRangeChip(14, '14 Days'),
          _buildTimeRangeChip(30, '30 Days'),
          _buildTimeRangeChip(90, '90 Days'),
        ],
      ),
    );
  }

  Widget _buildTimeRangeChip(int days, String label) {
    final isSelected = _selectedDays == days;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (selected) {
          setState(() {
            _selectedDays = days;
          });
        },
        selectedColor: Theme.of(context).colorScheme.primary,
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

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Avg Calories',
            '${_averageCalories.toInt()}',
            'kcal/day',
            Icons.local_fire_department,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Total Entries',
            '${_recentEntries.length}',
            'meals',
            Icons.restaurant,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(128),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaloriesChart() {
    if (_dailyCalories.isEmpty) {
      return _buildEmptyChart('No calorie data available');
    }

    final sortedDates = _dailyCalories.keys.toList()..sort();
    final maxCalories = _dailyCalories.values.reduce((a, b) => a > b ? a : b);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daily Calories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withAlpha(26),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Calories',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxCalories / 4,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(26),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 45,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withAlpha(128),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= sortedDates.length)
                            return const Text('');
                          final date = DateTime.parse(
                            sortedDates[value.toInt()],
                          );
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat('M/d').format(date),
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withAlpha(128),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        sortedDates.length,
                        (index) => FlSpot(
                          index.toDouble(),
                          _dailyCalories[sortedDates[index]]!,
                        ),
                      ),
                      isCurved: true,
                      color: Colors.orange,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: Colors.orange,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.orange.withAlpha(26),
                      ),
                    ),
                  ],
                  minY: 0,
                  maxY: maxCalories * 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacrosChart() {
    if (_dailyMacros.isEmpty) {
      return _buildEmptyChart('No macro data available');
    }

    final sortedDates = _dailyMacros.keys.toList()..sort();
    final allValues = _dailyMacros.values
        .expand((m) => [m['protein']!, m['carbs']!, m['fat']!])
        .toList();
    final maxValue = allValues.reduce((a, b) => a > b ? a : b);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daily Macros',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Row(
                  children: [
                    _buildLegendItem('Protein', const Color(0xFF4ECDC4)),
                    const SizedBox(width: 12),
                    _buildLegendItem('Carbs', const Color(0xFFFFBE0B)),
                    const SizedBox(width: 12),
                    _buildLegendItem('Fat', const Color(0xFFFF006E)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha(26),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}g',
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withAlpha(128),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= sortedDates.length)
                            return const Text('');
                          final date = DateTime.parse(
                            sortedDates[value.toInt()],
                          );
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat('M/d').format(date),
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withAlpha(128),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    _buildMacroLine(
                      sortedDates,
                      'protein',
                      const Color(0xFF4ECDC4),
                    ),
                    _buildMacroLine(
                      sortedDates,
                      'carbs',
                      const Color(0xFFFFBE0B),
                    ),
                    _buildMacroLine(
                      sortedDates,
                      'fat',
                      const Color(0xFFFF006E),
                    ),
                  ],
                  minY: 0,
                  maxY: maxValue * 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartBarData _buildMacroLine(
    List<String> dates,
    String macro,
    Color color,
  ) {
    return LineChartBarData(
      spots: List.generate(
        dates.length,
        (index) =>
            FlSpot(index.toDouble(), _dailyMacros[dates[index]]![macro]!),
      ),
      isCurved: true,
      color: color,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 3,
            color: Colors.white,
            strokeWidth: 1.5,
            strokeColor: color,
          );
        },
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildMealDistribution() {
    final mealCounts = <String, int>{};
    for (var entry in _recentEntries) {
      mealCounts[entry.mealType] = (mealCounts[entry.mealType] ?? 0) + 1;
    }

    if (mealCounts.isEmpty) {
      return _buildEmptyChart('No meal data available');
    }

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Meal Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _buildPieSections(mealCounts),
                  sectionsSpace: 2,
                  centerSpaceRadius: 60,
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: mealCounts.entries.map((entry) {
                final mealInfo = _getMealInfo(entry.key);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: mealInfo['color'],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${mealInfo['name']}: ${entry.value}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(Map<String, int> mealCounts) {
    final total = mealCounts.values.reduce((a, b) => a + b);

    return mealCounts.entries.map((entry) {
      final mealInfo = _getMealInfo(entry.key);
      final percentage = (entry.value / total * 100).toStringAsFixed(0);

      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '$percentage%',
        color: mealInfo['color'],
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Map<String, dynamic> _getMealInfo(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return {'name': 'Breakfast', 'color': Colors.orange};
      case 'lunch':
        return {'name': 'Lunch', 'color': Colors.green};
      case 'dinner':
        return {'name': 'Dinner', 'color': Colors.blue};
      case 'snack':
        return {'name': 'Snack', 'color': Colors.purple};
      default:
        return {'name': 'Other', 'color': Colors.grey};
    }
  }

  Widget _buildEmptyChart(String message) {
    return EmptyStateWidget(
      type: EmptyStateType.noData,
      title: 'No Data Yet',
      message: message,
    );
  }
}
