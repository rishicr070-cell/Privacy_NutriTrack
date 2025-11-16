import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food_entry.dart';
import '../models/user_profile.dart';

class StorageHelper {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Theme
  static Future<bool> isDarkMode() async {
    return _prefs?.getBool('dark_mode') ?? false;
  }

  static Future<void> setDarkMode(bool value) async {
    await _prefs?.setBool('dark_mode', value);
  }

  // User Profile
  static Future<UserProfile?> getUserProfile() async {
    final jsonString = _prefs?.getString('user_profile');
    if (jsonString == null) return null;
    return UserProfile.fromJson(jsonDecode(jsonString));
  }

  static Future<void> saveUserProfile(UserProfile profile) async {
    await _prefs?.setString('user_profile', jsonEncode(profile.toJson()));
  }

  // Food Entries
  static Future<List<FoodEntry>> getFoodEntries() async {
    final jsonString = _prefs?.getString('food_entries');
    if (jsonString == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => FoodEntry.fromJson(json)).toList();
  }

  static Future<void> saveFoodEntry(FoodEntry entry) async {
    final entries = await getFoodEntries();
    entries.add(entry);
    await _prefs?.setString('food_entries', jsonEncode(entries.map((e) => e.toJson()).toList()));
  }

  static Future<void> deleteFoodEntry(String id) async {
    final entries = await getFoodEntries();
    entries.removeWhere((entry) => entry.id == id);
    await _prefs?.setString('food_entries', jsonEncode(entries.map((e) => e.toJson()).toList()));
  }

  static Future<void> updateFoodEntry(FoodEntry entry) async {
    final entries = await getFoodEntries();
    final index = entries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      entries[index] = entry;
      await _prefs?.setString('food_entries', jsonEncode(entries.map((e) => e.toJson()).toList()));
    }
  }

  // Water Intake
  static Future<Map<String, int>> getWaterIntake() async {
    final jsonString = _prefs?.getString('water_intake');
    if (jsonString == null) return {};
    return Map<String, int>.from(jsonDecode(jsonString));
  }

  static Future<void> saveWaterIntake(String date, int amount) async {
    final waterData = await getWaterIntake();
    waterData[date] = amount;
    await _prefs?.setString('water_intake', jsonEncode(waterData));
  }

  // Weight Tracking
  static Future<Map<String, double>> getWeightData() async {
    final jsonString = _prefs?.getString('weight_data');
    if (jsonString == null) return {};
    return Map<String, double>.from(jsonDecode(jsonString));
  }

  static Future<void> saveWeight(String date, double weight) async {
    final weightData = await getWeightData();
    weightData[date] = weight;
    await _prefs?.setString('weight_data', jsonEncode(weightData));
  }

  // Clear all data
  static Future<void> clearAllData() async {
    await _prefs?.clear();
  }
}
