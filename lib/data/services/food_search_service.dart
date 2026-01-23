import 'package:privacy_first_nutrition_tracking_app/data/models/food_item.dart';

/// Service for searching and matching food items in the database
class FoodSearchService {
  /// Search for food items by name with fuzzy matching
  /// Returns list of matches sorted by similarity score
  static List<FoodSearchResult> searchFoods(
    String query,
    List<FoodItem> foodDatabase, {
    int maxResults = 5,
    double minSimilarity = 0.3,
  }) {
    if (query.isEmpty || foodDatabase.isEmpty) {
      return [];
    }

    final normalizedQuery = _normalizeString(query);
    final results = <FoodSearchResult>[];

    for (final food in foodDatabase) {
      final normalizedFoodName = _normalizeString(food.foodName);
      final similarity = _calculateSimilarity(
        normalizedQuery,
        normalizedFoodName,
      );

      if (similarity >= minSimilarity) {
        results.add(
          FoodSearchResult(
            food: food,
            similarity: similarity,
            matchType: _getMatchType(
              normalizedQuery,
              normalizedFoodName,
              similarity,
            ),
          ),
        );
      }
    }

    // Sort by similarity (highest first)
    results.sort((a, b) => b.similarity.compareTo(a.similarity));

    return results.take(maxResults).toList();
  }

  /// Find best match for a detected food name
  static FoodSearchResult? findBestMatch(
    String detectedName,
    List<FoodItem> foodDatabase,
  ) {
    final results = searchFoods(
      detectedName,
      foodDatabase,
      maxResults: 1,
      minSimilarity: 0.4,
    );

    return results.isNotEmpty ? results.first : null;
  }

  /// Normalize string for comparison (lowercase, remove special chars, trim)
  static String _normalizeString(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[_\-\(\)\[\]]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Calculate similarity score between two strings (0.0 to 1.0)
  static double _calculateSimilarity(String str1, String str2) {
    // Exact match
    if (str1 == str2) return 1.0;

    // Contains match (full word)
    if (str2.contains(str1) || str1.contains(str2)) {
      return 0.85;
    }

    // Word-level matching
    final words1 = str1.split(' ');
    final words2 = str2.split(' ');

    int matchingWords = 0;
    for (final word1 in words1) {
      if (word1.length < 3) continue; // Skip very short words
      for (final word2 in words2) {
        if (word1 == word2 || word2.contains(word1) || word1.contains(word2)) {
          matchingWords++;
          break;
        }
      }
    }

    if (matchingWords > 0) {
      final maxWords = words1.length > words2.length
          ? words1.length
          : words2.length;
      return 0.5 + (matchingWords / maxWords) * 0.4;
    }

    // Levenshtein distance for fuzzy matching
    final distance = _levenshteinDistance(str1, str2);
    final maxLength = str1.length > str2.length ? str1.length : str2.length;

    if (maxLength == 0) return 0.0;

    final similarity = 1.0 - (distance / maxLength);
    return similarity > 0 ? similarity : 0.0;
  }

  /// Calculate Levenshtein distance between two strings
  static int _levenshteinDistance(String s1, String s2) {
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    final len1 = s1.length;
    final len2 = s2.length;
    final matrix = List.generate(len1 + 1, (_) => List.filled(len2 + 1, 0));

    for (int i = 0; i <= len1; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= len2; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= len1; i++) {
      for (int j = 1; j <= len2; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1, // deletion
          matrix[i][j - 1] + 1, // insertion
          matrix[i - 1][j - 1] + cost, // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[len1][len2];
  }

  /// Determine match type based on similarity
  static MatchType _getMatchType(
    String query,
    String foodName,
    double similarity,
  ) {
    if (similarity >= 0.95) return MatchType.exact;
    if (similarity >= 0.75) return MatchType.high;
    if (similarity >= 0.5) return MatchType.medium;
    return MatchType.low;
  }
}

/// Result of a food search with similarity score
class FoodSearchResult {
  final FoodItem food;
  final double similarity;
  final MatchType matchType;

  FoodSearchResult({
    required this.food,
    required this.similarity,
    required this.matchType,
  });

  /// Get confidence percentage (0-100)
  int get confidencePercent => (similarity * 100).round();

  /// Check if this is a good match
  bool get isGoodMatch => similarity >= 0.6;
}

/// Type of match quality
enum MatchType {
  exact, // 95%+ similarity
  high, // 75-95% similarity
  medium, // 50-75% similarity
  low, // <50% similarity
}
