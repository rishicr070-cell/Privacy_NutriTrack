import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/user_profile.dart';
import '../models/food_entry.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  GenerativeModel? _model;
  String? _currentApiKey;

  // TODO: Replace with your actual Gemini API key
  static const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE';

  Future<bool> _initialize() async {
    if (_apiKey.isEmpty || _apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      print(
        '⚠️ ERROR: Please set a valid Gemini API key in lib/services/gemini_service.dart',
      );
      _model = null;
      _currentApiKey = null;
      return false;
    }

    if (_model == null || _currentApiKey != _apiKey) {
      _currentApiKey = _apiKey;
      _model = GenerativeModel(model: 'gemini-pro', apiKey: _apiKey);
    }
    return true;
  }

  Future<String?> getNutritionInsights(
    UserProfile profile,
    List<FoodEntry> recentEntries,
  ) async {
    if (!await _initialize())
      return "Please set your Gemini API Key in Profile settings to get AI insights.";

    try {
      final prompt =
          """
      You are a supportive and expert nutrition coach. 
      Analyze the following user profile and recent food intake to provide 3 actionable insights.
      
      User Profile:
      - Name: ${profile.name}
      - Age: ${profile.age}
      - Goal: ${profile.goalDescription}
      - Daily Calorie Goal: ${profile.dailyCalorieGoal} kcal
      - Macro Goals: P: ${profile.dailyProteinGoal}g, C: ${profile.dailyCarbsGoal}g, F: ${profile.dailyFatGoal}g
      
      Recent Food Entries (last 24-48 hours):
      ${recentEntries.map((e) => "- ${e.name}: ${e.calories} kcal (P:${e.protein}g, C:${e.carbs}g, F:${e.fat}g)").join('\n')}
      
      Requirements:
      1. Be concise and encouraging.
      2. Focus on the user's specific goal (${profile.goalDescription}).
      3. Suggest improvements or celebrate good choices.
      4. Format as markdown bullet points.
      5. Keep it under 150 words.
      """;

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      return response.text;
    } catch (e) {
      print('Gemini Error: $e');
      return "Unable to get insights at the moment. Please check your API key and connection.";
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
    if (!await _initialize()) {
      return {
        'isGood': true,
        'message': "Set API Key for AI feedback",
        'suggestion': null,
      };
    }

    try {
      final prompt =
          """
      As a nutrition coach, briefly evaluate this food choice for this user:
      
      User Goal: ${profile.goalDescription}
      Food: $foodName
      Nutrition: $calories kcal, P:${protein}g, C:${carbs}g, F:${fat}g
      
      Respond only in JSON format with these exact keys:
      {
        "isGood": boolean (is it generally helpful for their specific goal?),
        "message": "short 1-sentence feedback",
        "suggestion": "even shorter suggestion if bad, otherwise null"
      }
      """;

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);

      // Basic JSON cleaning if Gemini adds markdown blocks
      String text = response.text ?? "{}";
      if (text.contains('```json')) {
        text = text.split('```json')[1].split('```')[0].trim();
      } else if (text.contains('```')) {
        text = text.split('```')[1].split('```')[0].trim();
      }

      return jsonDecode(text);
    } catch (e) {
      print('Gemini Analysis Error: $e');
      return {
        'isGood': true,
        'message': "Analysis unavailable",
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

      final prompt =
          """
      The user's goal is ${profile.goalDescription}.
      Today they have eaten:
      ${todayEntries.map((e) => "- ${e.name}").join('\n')}
      Total Calories today so far: $totalCalories / ${profile.dailyCalorieGoal}
      
      What should they add to their next "plate" to stay on track? 
      Or what should they avoid for the rest of the day?
      Give 2 very short, specific tips (less than 15 words each).
      """;

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      return response.text;
    } catch (e) {
      return null;
    }
  }
}
