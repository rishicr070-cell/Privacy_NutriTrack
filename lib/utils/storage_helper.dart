import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food_entry.dart';
import '../models/user_profile.dart';
import 'secure_storage_helper.dart';

// Only import database_helper on non-web platforms
import 'database_helper.dart' if (dart.library.js) 'database_helper_stub.dart';

/// Unified storage helper that adapts based on platform
/// - Web: Uses SharedPreferences for everything
/// - Mobile/Desktop: Uses SQLite + Secure Storage
class StorageHelper {
  static SharedPreferences? _prefs;
  static DatabaseHelper? _db;
  static final SecureStorageHelper _secure = SecureStorageHelper();
  static bool _useSharedPrefsOnly = kIsWeb; // Use SharedPreferences on web

  /// Initialize storage systems
  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      
      if (!_useSharedPrefsOnly) {
        try {
          _db = DatabaseHelper();
        } catch (e) {
          print('Database initialization failed, using SharedPreferences: $e');
          _useSharedPrefsOnly = true;
        }
      }
      
      print('Storage systems initialized (Web mode: $_useSharedPrefsOnly)');
    } catch (e) {
      print('Storage initialization error: $e');
      // Fallback to SharedPreferences only
      _useSharedPrefsOnly = true;
      print('Falling back to SharedPreferences-only mode');
    }
  }

  // ==================== THEME ====================

  static Future<bool> isDarkMode() async {
    try {
      if (_useSharedPrefsOnly) {
        return _prefs?.getBool('dark_mode') ?? false;
      }
      return await _secure.isDarkMode();
    } catch (e) {
      print('Error reading dark mode: $e');
      return false;
    }
  }

  static Future<void> setDarkMode(bool value) async {
    try {
      if (_useSharedPrefsOnly) {
        await _prefs?.setBool('dark_mode', value);
      } else {
        await _secure.setDarkMode(value);
      }
    } catch (e) {
      print('Error saving dark mode: $e');
    }
  }

  // ==================== USER PROFILE ====================

  static Future<UserProfile?> getUserProfile() async {
    try {
      if (_useSharedPrefsOnly) {
        if (_prefs == null) {
          print('SharedPreferences not initialized');
          return null;
        }
        final jsonString = _prefs!.getString('user_profile');
        print('Retrieved profile JSON from SharedPreferences: ${jsonString != null ? "Found (${jsonString.length} chars)" : "null"}');
        
        if (jsonString == null) return null;
        
        final profileData = jsonDecode(jsonString);
        final profile = UserProfile.fromJson(profileData);
        print('Successfully decoded profile for: ${profile.name}');
        return profile;
      }
      return await _db?.getUserProfile();
    } catch (e) {
      print('Error loading profile: $e');
      return null;
    }
  }

  static Future<void> saveUserProfile(UserProfile profile) async {
    try {
      print('Saving profile (Web mode: $_useSharedPrefsOnly)');
      
      if (_useSharedPrefsOnly) {
        if (_prefs == null) {
          throw Exception('SharedPreferences not initialized');
        }
        final jsonString = jsonEncode(profile.toJson());
        print('Encoded profile JSON: ${jsonString.substring(0, jsonString.length > 100 ? 100 : jsonString.length)}...');
        
        final success = await _prefs!.setString('user_profile', jsonString);
        print('Profile saved to SharedPreferences: success=$success');
        
        if (!success) {
          throw Exception('SharedPreferences.setString returned false');
        }
      } else {
        await _db?.saveUserProfile(profile);
        print('Profile saved to SQLite');
      }
    } catch (e) {
      print('Error saving profile: $e');
      rethrow;
    }
  }

  // ==================== FOOD ENTRIES ====================

  static Future<List<FoodEntry>> getFoodEntries() async {
    try {
      if (_useSharedPrefsOnly) {
        final jsonString = _prefs?.getString('food_entries');
        if (jsonString == null) return [];
        
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList.map((json) => FoodEntry.fromJson(json)).toList();
      }
      return await _db?.getAllFoodEntries() ?? [];
    } catch (e) {
      print('Error loading food entries: $e');
      return [];
    }
  }

  static Future<List<FoodEntry>> getFoodEntriesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      if (_useSharedPrefsOnly) {
        final entries = await getFoodEntries();
        return entries.where((entry) {
          return entry.timestamp.isAfter(start) && entry.timestamp.isBefore(end);
        }).toList();
      }
      return await _db?.getFoodEntriesByDateRange(start, end) ?? [];
    } catch (e) {
      print('Error loading food entries by date: $e');
      return [];
    }
  }

  static Future<void> saveFoodEntry(FoodEntry entry) async {
    try {
      if (_useSharedPrefsOnly) {
        final entries = await getFoodEntries();
        entries.add(entry);
        await _prefs?.setString(
          'food_entries',
          jsonEncode(entries.map((e) => e.toJson()).toList()),
        );
      } else {
        await _db?.insertFoodEntry(entry);
      }
    } catch (e) {
      print('Error saving food entry: $e');
    }
  }

  static Future<void> deleteFoodEntry(String id) async {
    try {
      if (_useSharedPrefsOnly) {
        final entries = await getFoodEntries();
        entries.removeWhere((entry) => entry.id == id);
        await _prefs?.setString(
          'food_entries',
          jsonEncode(entries.map((e) => e.toJson()).toList()),
        );
      } else {
        await _db?.deleteFoodEntry(id);
      }
    } catch (e) {
      print('Error deleting food entry: $e');
    }
  }

  static Future<void> updateFoodEntry(FoodEntry entry) async {
    try {
      if (_useSharedPrefsOnly) {
        final entries = await getFoodEntries();
        final index = entries.indexWhere((e) => e.id == entry.id);
        if (index != -1) {
          entries[index] = entry;
          await _prefs?.setString(
            'food_entries',
            jsonEncode(entries.map((e) => e.toJson()).toList()),
          );
        }
      } else {
        await _db?.updateFoodEntry(entry);
      }
    } catch (e) {
      print('Error updating food entry: $e');
    }
  }

  // ==================== WATER INTAKE ====================

  static Future<Map<String, int>> getWaterIntake() async {
    try {
      if (_useSharedPrefsOnly) {
        final jsonString = _prefs?.getString('water_intake');
        if (jsonString == null) return {};
        return Map<String, int>.from(jsonDecode(jsonString));
      }
      return await _db?.getAllWaterIntake() ?? {};
    } catch (e) {
      print('Error loading water intake: $e');
      return {};
    }
  }

  static Future<void> saveWaterIntake(String date, int amount) async {
    try {
      if (_useSharedPrefsOnly) {
        final waterData = await getWaterIntake();
        waterData[date] = amount;
        await _prefs?.setString('water_intake', jsonEncode(waterData));
      } else {
        await _db?.saveWaterIntake(date, amount);
      }
    } catch (e) {
      print('Error saving water intake: $e');
    }
  }

  // ==================== WEIGHT TRACKING ====================

  static Future<Map<String, double>> getWeightData() async {
    try {
      if (_useSharedPrefsOnly) {
        final jsonString = _prefs?.getString('weight_data');
        if (jsonString == null) return {};
        return Map<String, double>.from(jsonDecode(jsonString));
      }
      return await _db?.getAllWeights() ?? {};
    } catch (e) {
      print('Error loading weight data: $e');
      return {};
    }
  }

  static Future<void> saveWeight(String date, double weight) async {
    try {
      if (_useSharedPrefsOnly) {
        final weightData = await getWeightData();
        weightData[date] = weight;
        await _prefs?.setString('weight_data', jsonEncode(weightData));
      } else {
        await _db?.saveWeight(date, weight);
      }
    } catch (e) {
      print('Error saving weight: $e');
    }
  }

  // ==================== USER PREFERENCES ====================

  static Future<bool> areNotificationsEnabled() async {
    try {
      if (_useSharedPrefsOnly) {
        return _prefs?.getBool('notifications_enabled') ?? false;
      }
      return await _secure.areNotificationsEnabled();
    } catch (e) {
      print('Error reading notifications preference: $e');
      return false;
    }
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      if (_useSharedPrefsOnly) {
        await _prefs?.setBool('notifications_enabled', enabled);
      } else {
        await _secure.setNotificationsEnabled(enabled);
      }
    } catch (e) {
      print('Error saving notifications preference: $e');
    }
  }

  static Future<bool> isFirstRun() async {
    try {
      if (_useSharedPrefsOnly) {
        return _prefs?.getBool('first_run') ?? true;
      }
      return await _secure.isFirstRun();
    } catch (e) {
      print('Error checking first run: $e');
      return true;
    }
  }

  static Future<void> setFirstRun(bool value) async {
    try {
      if (_useSharedPrefsOnly) {
        await _prefs?.setBool('first_run', value);
      } else {
        await _secure.setFirstRun(value);
      }
    } catch (e) {
      print('Error setting first run: $e');
    }
  }

  // ==================== DATA MANAGEMENT ====================

  static Future<void> clearAllData() async {
    try {
      if (_useSharedPrefsOnly) {
        await _prefs?.clear();
      } else {
        await _db?.clearAllData();
        await _secure.clearAll();
        await _prefs?.clear();
      }
      print('All data cleared');
    } catch (e) {
      print('Error clearing all data: $e');
    }
  }

  static Future<Map<String, int>> getDatabaseStats() async {
    try {
      if (_useSharedPrefsOnly) {
        final entries = await getFoodEntries();
        final waterData = await getWaterIntake();
        final weightData = await getWeightData();
        
        return {
          'food_entries': entries.length,
          'water_records': waterData.length,
          'weight_records': weightData.length,
        };
      }
      return await _db?.getDatabaseStats() ?? {};
    } catch (e) {
      print('Error getting database stats: $e');
      return {};
    }
  }

  static Future<void> close() async {
    try {
      if (!_useSharedPrefsOnly) {
        await _db?.close();
      }
    } catch (e) {
      print('Error closing database: $e');
    }
  }

  // ==================== BACKUP HELPERS ====================

  static Future<DateTime?> getLastBackupTime() async {
    try {
      if (_useSharedPrefsOnly) {
        final timestamp = _prefs?.getInt('last_backup_time');
        if (timestamp == null) return null;
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
      return await _secure.getLastBackupTime();
    } catch (e) {
      print('Error getting last backup time: $e');
      return null;
    }
  }

  static Future<void> saveLastBackupTime(DateTime timestamp) async {
    try {
      if (_useSharedPrefsOnly) {
        await _prefs?.setInt('last_backup_time', timestamp.millisecondsSinceEpoch);
      } else {
        await _secure.saveLastBackupTime(timestamp);
      }
    } catch (e) {
      print('Error saving last backup time: $e');
    }
  }

  // ==================== DEBUGGING ====================

  static Future<void> printStorageStats() async {
    try {
      print('=== Storage Statistics ===');
      print('Platform: ${_useSharedPrefsOnly ? "Web (SharedPreferences)" : "Native (SQLite)"}');
      
      final stats = await getDatabaseStats();
      print('Food entries: ${stats['food_entries']}');
      print('Water records: ${stats['water_records']}');
      print('Weight records: ${stats['weight_records']}');
      
      final profile = await getUserProfile();
      print('User profile: ${profile != null ? 'exists' : 'not set'}');
      
      final isDark = await isDarkMode();
      print('Dark mode: $isDark');
      print('========================');
    } catch (e) {
      print('Error printing stats: $e');
    }
  }
}
