// Stub for web platform - SQLite not supported on web
// This file is used when running on web, the actual database_helper.dart is used on native platforms

import 'package:privacy_first_nutrition_tracking_app/data/models/food_entry.dart';
import 'package:privacy_first_nutrition_tracking_app/data/models/user_profile.dart';

class DatabaseHelper {
  // Empty stub implementation for web
  // All storage operations will use SharedPreferences via the storage_helper.dart
  
  Future<UserProfile?> getUserProfile() async => null;
  Future<int> saveUserProfile(UserProfile profile) async => 0;
  Future<List<FoodEntry>> getAllFoodEntries() async => [];
  Future<List<FoodEntry>> getFoodEntries() async => []; // Added missing method
  Future<List<FoodEntry>> getFoodEntriesByDateRange(DateTime start, DateTime end) async => [];
  Future<int> insertFoodEntry(FoodEntry entry) async => 0;
  Future<int> updateFoodEntry(FoodEntry entry) async => 0;
  Future<int> deleteFoodEntry(String id) async => 0;
  Future<Map<String, int>> getAllWaterIntake() async => {};
  Future<int> saveWaterIntake(String date, int amount) async => 0;
  Future<Map<String, double>> getAllWeights() async => {};
  Future<int> saveWeight(String date, double weight) async => 0;
  Future<void> clearAllData() async {}
  Future<void> close() async {}
  Future<Map<String, int>> getDatabaseStats() async => {};
}
