import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';
import '../models/food_entry.dart';
import 'package:flutter/foundation.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  String? _apiKey;
  String? _workingModel;
  bool _isInitialized = false;

  Future<bool> _initialize() async {
    if (_isInitialized && _apiKey != null && _workingModel != null) {
      return true;
    }

    try {
      // Get API key from .env file
      _apiKey = dotenv.env['GEMINI_API_KEY'];

      if (_apiKey == null ||
          _apiKey!.isEmpty ||
          _apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
        debugPrint(
          '⚠️ Gemini API key not configured. Please add it to .env file.',
        );
        return false;
      }

      // Get available models from API
      final availableModels = await _fetchAvailableModels();

      if (availableModels.isEmpty) {
        debugPrint('❌ No models available');
        return false;
      }

      // Try to find a working model
      for (final modelName in availableModels) {
        if (await _testModel(modelName)) {
          _workingModel = modelName;
          _isInitialized = true;
          debugPrint('✅ Gemini AI initialized with model: $modelName');
          return true;
        }
      }

      debugPrint('❌ No working model found');
      return false;
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to initialize Gemini: $e');
      return false;
    }
  }

  Future<List<String>> _fetchAvailableModels() async {
    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1/models?key=$_apiKey',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final models = data['models'] as List?;

        if (models != null && models.isNotEmpty) {
          final List<String> availableModelNames = [];

          for (var model in models) {
            final name = model['name'] as String?;
            final supportedMethods =
                model['supportedGenerationMethods'] as List?;

            if (name != null) {
              final modelName = name.replaceFirst('models/', '');
              final supportsGenerate =
                  supportedMethods?.contains('generateContent') ?? false;

              if (supportsGenerate) {
                availableModelNames.add(modelName);
              }
            }
          }

          return availableModelNames;
        }
      }
      return [];
    } catch (e) {
      debugPrint('❌ Error listing models: $e');
      return [];
    }
  }

  Future<bool> _testModel(String modelName) async {
    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1/models/$modelName:generateContent?key=$_apiKey',
      );

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': 'Hi'},
                  ],
                },
              ],
            }),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<String?> _generateContent(String prompt) async {
    if (!await _initialize()) {
      debugPrint('❌ Service not initialized, cannot generate content');
      return null;
    }

    try {
      debugPrint('📤 Generating content with model: $_workingModel');

      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1/models/$_workingModel:generateContent?key=$_apiKey',
      );

      final requestBody = jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
        'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 2048},
      });

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: requestBody,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        debugPrint(
          '✅ Content generated successfully (${text?.length ?? 0} chars)',
        );
        return text;
      } else {
        debugPrint('❌ API error: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Generate content error: $e');
      return null;
    }
  }

  Future<String?> getNutritionInsights(
    UserProfile profile,
    List<FoodEntry> recentEntries,
  ) async {
    debugPrint('🍎 Getting nutrition insights for ${profile.name}...');

    if (!await _initialize()) {
      debugPrint('❌ Cannot get insights: Service not initialized');
      return "AI insights are currently unavailable.";
    }

    if (recentEntries.isEmpty) {
      debugPrint('⚠️ No recent entries to analyze');
      return "Start logging your meals to get personalized insights!";
    }

    try {
      // Calculate totals
      final totalCalories = recentEntries.fold(
        0.0,
        (sum, e) => sum + e.calories,
      );
      final totalProtein = recentEntries.fold(0.0, (sum, e) => sum + e.protein);
      final totalCarbs = recentEntries.fold(0.0, (sum, e) => sum + e.carbs);
      final totalFat = recentEntries.fold(0.0, (sum, e) => sum + e.fat);

      debugPrint(
        '📊 Analyzing: $totalCalories kcal, P:${totalProtein}g, C:${totalCarbs}g, F:${totalFat}g',
      );

      final prompt =
          """
You are a nutrition coach. Analyze this user's intake and provide a CONCISE 100-word insight.

USER PROFILE:
Goal: ${profile.goalDescription}
Targets: ${profile.dailyCalorieGoal} kcal | P: ${profile.dailyProteinGoal}g | C: ${profile.dailyCarbsGoal}g | F: ${profile.dailyFatGoal}g
${profile.healthConditions.isNotEmpty ? 'Health: ${profile.healthConditions.join(", ")}' : ''}

TODAY'S INTAKE:
${recentEntries.take(10).map((e) => "• ${e.name}: ${e.calories.toInt()} kcal (P:${e.protein.toInt()}g, C:${e.carbs.toInt()}g, F:${e.fat.toInt()}g)").join('\n')}

TOTALS:
Calories: ${totalCalories.toInt()}/${profile.dailyCalorieGoal.toInt()} (${((totalCalories / profile.dailyCalorieGoal) * 100).toInt()}%)
Protein: ${totalProtein.toInt()}/${profile.dailyProteinGoal.toInt()}g | Carbs: ${totalCarbs.toInt()}/${profile.dailyCarbsGoal.toInt()}g | Fat: ${totalFat.toInt()}/${profile.dailyFatGoal.toInt()}g

STRICT REQUIREMENTS:
- Maximum 100 words total
- Include SPECIFIC DATA: mention actual calorie numbers, gram values, and percentages
- Add relevant emojis (🎯📊💪🍎⚠️✅) to highlight key points
- IMPORTANT: Put each section on a NEW LINE with a blank line between sections
- Use this exact structure:

**🎯 Progress:** [Goal status with % or numbers]

**✅ Strengths:** [1-2 foods with their macro values]

**⚠️ Improve:** [Specific nutrient gap with numbers]

**🍽️ Next Meal:** [2 foods with estimated macro contribution]

Be data-driven, encouraging, and actionable. Always cite numbers and reference actual foods eaten.
""";

      final result = await _generateContent(prompt);

      if (result != null && result.isNotEmpty) {
        debugPrint(
          '✅ Insights generated successfully (${result.length} chars)',
        );
        debugPrint(
          '📝 Preview: ${result.substring(0, result.length > 100 ? 100 : result.length)}...',
        );
        return result;
      } else {
        debugPrint('❌ Failed to generate insights or empty response');
        return "Unable to generate insights at the moment. Please try again.";
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Get insights error: $e');
      return "Unable to generate insights. Please try again.";
    }
  }

  Future<Map<String, dynamic>> analyzeFoodEntry({
    required UserProfile profile,
    required String foodName,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
  }) async {
    debugPrint('🔍 Analyzing food: $foodName');

    if (!await _initialize()) {
      return {
        'isGood': true,
        'message': "AI analysis unavailable",
        'suggestion': null,
      };
    }

    try {
      final prompt =
          """
As a nutrition coach, evaluate this food choice:

User Goal: ${profile.goalDescription}
Daily Calorie Target: ${profile.dailyCalorieGoal} kcal
${profile.healthConditions.isNotEmpty ? 'Health Conditions: ${profile.healthConditions.join(", ")}' : ''}

Food Being Added:
• $foodName
• Nutrition: ${calories.toInt()} kcal, P:${protein.toInt()}g, C:${carbs.toInt()}g, F:${fat.toInt()}g

Respond ONLY in valid JSON format with these exact keys:
{
  "isGood": true,
  "message": "One brief sentence (max 15 words) of feedback",
  "suggestion": null
}

Do not include markdown formatting or extra text.
""";

      final text = await _generateContent(prompt);
      if (text == null) {
        return {
          'isGood': true,
          'message': "Food logged successfully",
          'suggestion': null,
        };
      }

      String cleanText = text.trim();

      if (cleanText.contains('```json')) {
        cleanText = cleanText.split('```json')[1].split('```')[0].trim();
      } else if (cleanText.contains('```')) {
        cleanText = cleanText.split('```')[1].split('```')[0].trim();
      }

      final result = jsonDecode(cleanText);
      return {
        'isGood': result['isGood'] ?? true,
        'message': result['message'] ?? "Food logged",
        'suggestion': result['suggestion'],
      };
    } catch (e) {
      debugPrint('❌ Analyze food error: $e');
      return {
        'isGood': true,
        'message': "Food logged successfully",
        'suggestion': null,
      };
    }
  }

  Future<String?> suggestPlateImprovements(
    UserProfile profile,
    List<FoodEntry> todayEntries,
  ) async {
    if (!await _initialize()) return null;

    try {
      final totalCalories = todayEntries.fold(
        0.0,
        (sum, e) => sum + e.calories,
      );
      final totalProtein = todayEntries.fold(0.0, (sum, e) => sum + e.protein);
      final totalCarbs = todayEntries.fold(0.0, (sum, e) => sum + e.carbs);
      final totalFat = todayEntries.fold(0.0, (sum, e) => sum + e.fat);

      final remainingCalories = profile.dailyCalorieGoal - totalCalories;

      final prompt =
          """
User's goal: ${profile.goalDescription}
Daily calorie target: ${profile.dailyCalorieGoal} kcal

Today's intake so far:
${todayEntries.map((e) => "• ${e.name}").join('\n')}

Current totals: ${totalCalories.toInt()} kcal | P: ${totalProtein.toInt()}g | C: ${totalCarbs.toInt()}g | F: ${totalFat.toInt()}g
Remaining: ${remainingCalories.toInt()} kcal

Provide 2 specific, actionable tips (each under 15 words):
1. What to add/prioritize for next meal
2. What to limit/avoid for rest of day

Format as brief bullet points.
""";

      return await _generateContent(prompt);
    } catch (e) {
      debugPrint('❌ Plate suggestions error: $e');
      return null;
    }
  }

  Future<String?> getHealthConditionGuidance(UserProfile profile) async {
    if (!await _initialize()) return null;
    if (profile.healthConditions.isEmpty) return null;

    try {
      final prompt =
          """
User has these health conditions: ${profile.healthConditions.join(", ")}
Goal: ${profile.goalDescription}

Provide 3 brief, practical dietary tips specific to these conditions.
Focus on Indian foods where relevant. Keep each tip under 20 words.
Format as bullet points.
""";

      return await _generateContent(prompt);
    } catch (e) {
      debugPrint('❌ Health guidance error: $e');
      return null;
    }
  }

  Future<bool> isAvailable() async {
    return await _initialize();
  }
}
