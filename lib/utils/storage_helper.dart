import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';
import 'secure_storage_helper.dart';
import '../models/food_entry.dart';
import '../models/user_profile.dart';

/// Unified storage helper that combines SQLite database and secure storage
/// - SQLite: For bulk data (food entries, profile)
/// - Secure Storage: For sensitive data (theme preferences, settings)
/// - SharedPreferences: For simple key-value data
class StorageHelper {
  static SharedPreferences? _prefs;
  static final DatabaseHelper _db = DatabaseHelper();
  static final SecureStorageHelper _secure = SecureStorageHelper();

  /// Initialize storage systems
  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      // Database initializes lazily when first accessed
      print('Storage systems initialized');
    } catch (e) {
      print('Storage initialization error: $e');
      rethrow;
    }
  }

  // ==================== THEME (Secure Storage) ====================

  /// Get dark mode preference from secure storage
  static Future<bool> isDarkMode() async {
    try {
      return await _secure.isDarkMode();
    } catch (e) {
      print('Error reading dark mode: $e');
      return false;
    }
  }

  /// Set dark mode preference in secure storage
  static Future<void> setDarkMode(bool value) async {
    try {
      await _secure.setDarkMode(value);
    } catch (e) {
      print('Error saving dark mode: $e');
    }
  }

  // ==================== USER PROFILE (SQLite) ====================

  /// Get user profile from database
  static Future<UserProfile?> getUserProfile() async {
    try {
      return await _db.getUserProfile();
    } catch (e) {
      print('Error loading profile: $e');
      return null;
    }
  }

  /// Save user profile to database
  static Future<void> saveUserProfile(UserProfile profile) async {
    try {
      await _db.saveUserProfile(profile);
    } catch (e) {
      print('Error saving profile: $e');
    }
  }

  // ==================== FOOD ENTRIES (SQLite) ====================

  /// Get all food entries from database
  static Future<List<FoodEntry>> getFoodEntries() async {
    try {
      return await _db.getAllFoodEntries();
    } catch (e) {
      print('Error loading food entries: $e');
      return [];
    }
  }

  /// Get food entries within a date range
  static Future<List<FoodEntry>> getFoodEntriesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      return await _db.getFoodEntriesByDateRange(start, end);
    } catch (e) {
      print('Error loading food entries by date: $e');
      return [];
    }
  }

  /// Save a single food entry to database
  static Future<void> saveFoodEntry(FoodEntry entry) async {
    try {
      await _db.insertFoodEntry(entry);
    } catch (e) {
      print('Error saving food entry: $e');
    }
  }

  /// Delete a food entry from database
  static Future<void> deleteFoodEntry(String id) async {
    try {
      await _db.deleteFoodEntry(id);
    } catch (e) {
      print('Error deleting food entry: $e');
    }
  }

  /// Update a food entry in database
  static Future<void> updateFoodEntry(FoodEntry entry) async {
    try {
      await _db.updateFoodEntry(entry);
    } catch (e) {
      print('Error updating food entry: $e');
    }
  }

  // ==================== WATER INTAKE (SQLite) ====================

  /// Get all water intake data
  static Future<Map<String, int>> getWaterIntake() async {
    try {
      return await _db.getAllWaterIntake();
    } catch (e) {
      print('Error loading water intake: $e');
      return {};
    }
  }

  /// Save water intake for a specific date
  static Future<void> saveWaterIntake(String date, int amount) async {
    try {
      await _db.saveWaterIntake(date, amount);
    } catch (e) {
      print('Error saving water intake: $e');
    }
  }

  // ==================== WEIGHT TRACKING (SQLite) ====================

  /// Get all weight data
  static Future<Map<String, double>> getWeightData() async {
    try {
      return await _db.getAllWeights();
    } catch (e) {
      print('Error loading weight data: $e');
      return {};
    }
  }

  /// Save weight for a specific date
  static Future<void> saveWeight(String date, double weight) async {
    try {
      await _db.saveWeight(date, weight);
    } catch (e) {
      print('Error saving weight: $e');
    }
  }

  // ==================== USER PREFERENCES (Secure Storage) ====================

  /// Get notification preference
  static Future<bool> areNotificationsEnabled() async {
    try {
      return await _secure.areNotificationsEnabled();
    } catch (e) {
      print('Error reading notifications preference: $e');
      return false;
    }
  }

  /// Set notification preference
  static Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      await _secure.setNotificationsEnabled(enabled);
    } catch (e) {
      print('Error saving notifications preference: $e');
    }
  }

  /// Check if this is first run
  static Future<bool> isFirstRun() async {
    try {
      return await _secure.isFirstRun();
    } catch (e) {
      print('Error checking first run: $e');
      return true;
    }
  }

  /// Set first run flag
  static Future<void> setFirstRun(bool value) async {
    try {
      await _secure.setFirstRun(value);
    } catch (e) {
      print('Error setting first run: $e');
    }
  }

  // ==================== DATA MANAGEMENT ====================

  /// Clear all data from all storage systems
  static Future<void> clearAllData() async {
    try {
      await _db.clearAllData();
      await _secure.clearAll();
      await _prefs?.clear();
      print('All data cleared from all storage systems');
    } catch (e) {
      print('Error clearing all data: $e');
    }
  }

  /// Get database statistics
  static Future<Map<String, int>> getDatabaseStats() async {
    try {
      return await _db.getDatabaseStats();
    } catch (e) {
      print('Error getting database stats: $e');
      return {};
    }
  }

  /// Close database connection
  static Future<void> close() async {
    try {
      await _db.close();
    } catch (e) {
      print('Error closing database: $e');
    }
  }

  // ==================== MIGRATION HELPER ====================

  /// Migrate data from SharedPreferences to SQLite (if needed)
  static Future<void> migrateFromSharedPreferences() async {
    try {
      // Check if migration is needed
      final migrated = _prefs?.getBool('migrated_to_sqlite') ?? false;
      if (migrated) {
        print('Data already migrated');
        return;
      }

      print('Starting migration from SharedPreferences to SQLite...');

      // Note: If you had old data in SharedPreferences, you could migrate it here
      // For now, we'll just mark as migrated

      await _prefs?.setBool('migrated_to_sqlite', true);
      print('Migration completed successfully');
    } catch (e) {
      print('Migration error: $e');
    }
  }

  // ==================== BACKUP HELPERS ====================

  /// Get last backup timestamp
  static Future<DateTime?> getLastBackupTime() async {
    try {
      return await _secure.getLastBackupTime();
    } catch (e) {
      print('Error getting last backup time: $e');
      return null;
    }
  }

  /// Save last backup timestamp
  static Future<void> saveLastBackupTime(DateTime timestamp) async {
    try {
      await _secure.saveLastBackupTime(timestamp);
    } catch (e) {
      print('Error saving last backup time: $e');
    }
  }

  // ==================== DEBUGGING ====================

  /// Print storage statistics (for debugging)
  static Future<void> printStorageStats() async {
    try {
      print('=== Storage Statistics ===');
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
