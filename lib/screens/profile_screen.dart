import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user_profile.dart';
import '../utils/storage_helper.dart';
import '../theme/theme_manager.dart';
import 'edit_profile_screen.dart';
import 'health_conditions_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  UserProfile? _userProfile;
  Map<String, double> _weightData = {};
  bool _isLoading = true;
  bool _isAiEnabled = false;
  final TextEditingController _geminiApiKeyController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    print('=== LOADING PROFILE DATA ===');
    setState(() => _isLoading = true);

    try {
      print('Calling StorageHelper.getUserProfile()...');
      final profile = await StorageHelper.getUserProfile();
      print(
        'Profile loaded: ${profile != null ? "Found profile for ${profile.name}" : "No profile found"}',
      );

      print('Calling StorageHelper.getWeightData()...');
      final weightData = await StorageHelper.getWeightData();
      print('Weight data loaded: ${weightData.length} entries');

      // Actually let's add a proper one. I'll add getAiEnabled to StorageHelper shortly.
      // For now, let's just get the key.
      final apiKey = await StorageHelper.getGeminiApiKey();

      final aiEnabled = apiKey != null && apiKey.isNotEmpty;

      if (mounted) {
        _geminiApiKeyController.text = apiKey ?? '';
        setState(() {
          _userProfile = profile;
          _weightData = weightData;
          _isAiEnabled = aiEnabled;
          _isLoading = false;
        });
      }

      print('=== PROFILE DATA LOAD COMPLETE ===');
    } catch (e, stackTrace) {
      print('=== ERROR LOADING PROFILE DATA ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _geminiApiKeyController.dispose();
    super.dispose();
  }

  Future<void> _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(profile: _userProfile),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  Future<void> _navigateToHealthConditions() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HealthConditionsScreen(profile: _userProfile),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  void _toggleDarkMode(bool value) {
    if (value != context.read<ThemeManager>().isDarkMode) {
      context.read<ThemeManager>().toggleTheme();
    }
  }

  Future<void> _launchApiStudioUrl() async {
    final url = Uri.parse('https://aistudio.google.com/app/apikey');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch AI Studio link')),
        );
      }
    }
  }

  Future<void> _showWeightDialog() async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Weight'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Weight (kg)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final weight = double.tryParse(controller.text);
              if (weight != null) {
                final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
                await StorageHelper.saveWeight(today, weight);

                if (_userProfile != null) {
                  final updatedProfile = _userProfile!.copyWith(
                    currentWeight: weight,
                  );
                  await StorageHelper.saveUserProfile(updatedProfile);
                }

                if (!mounted) return;
                Navigator.pop(context);
                _loadData();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClearData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear All Data'),
        content: const Text(
          'Are you sure you want to delete all your data? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await StorageHelper.clearAllData();
      if (!mounted) return;
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All data cleared'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverToBoxAdapter(
                  child: _userProfile == null
                      ? _buildEmptyState()
                      : Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProfileHeader(),
                              const SizedBox(height: 24),
                              _buildStatsGrid(),
                              const SizedBox(height: 24),
                              _buildWeightChart(),
                              const SizedBox(height: 24),
                              _buildGoalsCard(),
                              const SizedBox(height: 24),
                              _buildHealthSection(),
                              const SizedBox(height: 24),
                              _buildSettingsSection(),
                              const SizedBox(height: 100),
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
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
                Theme.of(context).colorScheme.secondary.withOpacity(0.05),
              ],
            ),
          ),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 100,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'No Profile Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Create your profile to track your nutrition goals and progress',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: _navigateToEditProfile,
            icon: const Icon(Icons.add),
            label: const Text('Create Profile'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _userProfile!.name.isNotEmpty
                      ? _userProfile!.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userProfile!.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_userProfile!.age} years • ${_userProfile!.gender}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: _navigateToEditProfile,
              icon: const Icon(Icons.edit),
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    final bmi = _userProfile!.bmi;
    final weightDiff = _userProfile!.currentWeight - _userProfile!.targetWeight;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Current Weight',
                '${_userProfile!.currentWeight.toStringAsFixed(1)} kg',
                Icons.monitor_weight,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Target Weight',
                '${_userProfile!.targetWeight.toStringAsFixed(1)} kg',
                Icons.flag,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'BMI',
                bmi.toStringAsFixed(1),
                Icons.health_and_safety,
                _getBMIColor(bmi),
                subtitle: _userProfile!.bmiCategory,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'To Goal',
                '${weightDiff.abs().toStringAsFixed(1)} kg',
                Icons.trending_down,
                Colors.orange,
                subtitle: weightDiff > 0 ? 'to lose' : 'to gain',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightChart() {
    if (_weightData.isEmpty) {
      return Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Weight Progress',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: _showWeightDialog,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Log'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Icon(
                Icons.show_chart,
                size: 60,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 12),
              Text(
                'Start logging your weight',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      );
    }

    final sortedDates = _weightData.keys.toList()..sort();
    final weights = sortedDates.map((date) => _weightData[date]!).toList();
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);

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
                  'Weight Progress',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                FilledButton.icon(
                  onPressed: _showWeightDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Log'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
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
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.1),
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
                            '${value.toInt()}kg',
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.5),
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
                                ).colorScheme.onSurface.withOpacity(0.5),
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
                        (index) => FlSpot(index.toDouble(), weights[index]),
                      ),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: Colors.blue,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.1),
                      ),
                    ),
                  ],
                  minY: minWeight - 2,
                  maxY: maxWeight + 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsCard() {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Goals',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildGoalRow(
              'Calories',
              _userProfile!.dailyCalorieGoal,
              'kcal',
              Icons.local_fire_department,
              Colors.orange,
            ),
            const Divider(height: 24),
            _buildGoalRow(
              'Protein',
              _userProfile!.dailyProteinGoal,
              'g',
              Icons.fitness_center,
              Colors.blue,
            ),
            const Divider(height: 24),
            _buildGoalRow(
              'Carbs',
              _userProfile!.dailyCarbsGoal,
              'g',
              Icons.grain,
              Colors.orange,
            ),
            const Divider(height: 24),
            _buildGoalRow(
              'Fat',
              _userProfile!.dailyFatGoal,
              'g',
              Icons.opacity,
              Colors.purple,
            ),
            const Divider(height: 24),
            _buildGoalRow(
              'Water',
              _userProfile!.dailyWaterGoal,
              'ml',
              Icons.water_drop,
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalRow(
    String label,
    double value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        Text(
          '${value.toInt()} $unit',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildHealthSection() {
    final hasConditions = _userProfile!.healthConditions.isNotEmpty;
    final hasAllergies = _userProfile!.allergies.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Health',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.medical_services, color: Colors.red),
                ),
                title: const Text('Health Conditions & Allergies'),
                subtitle: Text(
                  hasConditions || hasAllergies
                      ? '${_userProfile!.healthConditions.length} conditions, ${_userProfile!.allergies.length} allergies'
                      : 'Set up personalized health alerts',
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _navigateToHealthConditions,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          child: Column(
            children: [
              Consumer<ThemeManager>(
                builder: (context, themeManager, _) {
                  return SwitchListTile(
                    secondary: Icon(
                      themeManager.isDarkMode
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Dark Mode'),
                    value: themeManager.isDarkMode,
                    onChanged: (value) => themeManager.toggleTheme(),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.psychology, color: Colors.purple.shade300),
                title: const Text('Gemini Assistant'),
                subtitle: const Text('AI-powered nutrition insights'),
                trailing: Switch(
                  value: _isAiEnabled,
                  onChanged: (value) {
                    if (value && _geminiApiKeyController.text.isEmpty) {
                      _showApiKeyDialog();
                    } else {
                      setState(() => _isAiEnabled = value);
                    }
                  },
                ),
                onTap: _showApiKeyDialog,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Clear All Data'),
                subtitle: const Text('Delete all entries and reset app'),
                onTap: _confirmClearData,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showApiKeyDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.api, color: Colors.blue),
            const SizedBox(width: 12),
            const Text('Gemini API Key'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your Google Gemini API Key to enable AI insights.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _geminiApiKeyController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'API Key',
                border: OutlineInputBorder(),
                hintText: 'Enter key here...',
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _launchApiStudioUrl,
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text('Get a free key from Google AI Studio'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final key = _geminiApiKeyController.text.trim();
              if (key.isNotEmpty) {
                await StorageHelper.saveGeminiApiKey(key);
                setState(() => _isAiEnabled = true);
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ API Key saved! AI Coach is now active.'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else {
                await StorageHelper.deleteGeminiApiKey();
                setState(() => _isAiEnabled = false);
                if (!mounted) return;
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
