import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user_profile.dart';
import '../models/food_entry.dart';
import '../utils/storage_helper.dart';
import '../services/gemini_service.dart';

class AiInsightsScreen extends StatefulWidget {
  const AiInsightsScreen({super.key});

  @override
  State<AiInsightsScreen> createState() => _AiInsightsScreenState();
}

class _AiInsightsScreenState extends State<AiInsightsScreen> {
  final GeminiService _geminiService = GeminiService();
  bool _isLoading = true;
  String? _insights;
  UserProfile? _userProfile;
  List<FoodEntry> _recentEntries = [];

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    setState(() => _isLoading = true);

    final profile = await StorageHelper.getUserProfile();
    final entries = await StorageHelper.getFoodEntries();

    // Get last 48 hours is ideally better, but let's get recent 10-20 entries
    final recentEntries = entries.reversed.take(20).toList();

    String? insights;
    if (profile != null) {
      insights = await _geminiService.getNutritionInsights(
        profile,
        recentEntries,
      );
    }

    if (mounted) {
      setState(() {
        _userProfile = profile;
        _recentEntries = recentEntries;
        _insights = insights;
        _isLoading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Nutrition Coach'),
        actions: [
          IconButton(onPressed: _loadInsights, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _insights == null
          ? _buildNoApiKeyDataState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: AnimationLimiter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 500),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(child: widget),
                    ),
                    children: [
                      _buildCoachHeader(),
                      const SizedBox(height: 24),
                      _buildInsightsCard(),
                      const SizedBox(height: 24),
                      _buildDataSummary(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(height: 24),
          const Text(
            'Consulting with Gemini...',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Analyzing your habits and goals',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildNoApiKeyDataState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.psychology_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            const Text(
              'Coach is Sleeping',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'To enable AI coaching, follow these simple steps:',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _buildStepRow('1', 'Get a free API Key from Google AI Studio'),
            const SizedBox(height: 12),
            _buildStepRow('2', 'Go to the Profile tab in this app'),
            const SizedBox(height: 12),
            _buildStepRow('3', 'Open Gemini Assistant in Settings'),
            const SizedBox(height: 12),
            _buildStepRow('4', 'Paste your key and click Save'),
            const SizedBox(height: 32),
            TextButton.icon(
              onPressed: _launchApiStudioUrl,
              icon: const Icon(Icons.open_in_new),
              label: const Text('Get your Gemini API Key here'),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go to Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepRow(String number, String text) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.purple,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildCoachHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.psychology, color: Colors.purple, size: 32),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personal AI Coach',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Text(
                'Analysis for ${_userProfile?.name ?? "User"}',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInsightsCard() {
    return Card(
      elevation: 0,
      color: Colors.purple.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.purple.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.purple, size: 20),
                SizedBox(width: 8),
                Text(
                  'Coach\'s Advice',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _insights ?? '',
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Analysis Basis',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSummaryRow(
                  'Goal',
                  _userProfile?.goalDescription ?? 'N/A',
                  Icons.flag,
                ),
                const Divider(height: 24),
                _buildSummaryRow(
                  'Recent Data',
                  '${_recentEntries.length} entries analyzed',
                  Icons.analytics_outlined,
                ),
                const Divider(height: 24),
                _buildSummaryRow(
                  'Privacy',
                  'Your data is processed locally.',
                  Icons.lock_outline,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
