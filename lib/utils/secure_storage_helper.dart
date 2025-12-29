import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage helper for sensitive data
/// Uses platform-specific secure storage (Keychain on iOS, KeyStore on Android)
class SecureStorageHelper {
  static final SecureStorageHelper _instance = SecureStorageHelper._internal();

  factory SecureStorageHelper() => _instance;

  SecureStorageHelper._internal();

  // Create secure storage instance with encryption options
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // ==================== GEMINI API KEY ====================

  /// Save Gemini API Key securely
  Future<void> saveGeminiApiKey(String apiKey) async {
    try {
      await _storage.write(key: 'gemini_api_key', value: apiKey);
    } catch (e) {
      print('Error saving Gemini API Key: $e');
    }
  }

  /// Get Gemini API Key
  Future<String?> getGeminiApiKey() async {
    try {
      return await _storage.read(key: 'gemini_api_key');
    } catch (e) {
      print('Error reading Gemini API Key: $e');
      return null;
    }
  }

  /// Delete Gemini API Key
  Future<void> deleteGeminiApiKey() async {
    try {
      await _storage.delete(key: 'gemini_api_key');
    } catch (e) {
      print('Error deleting Gemini API Key: $e');
    }
  }

  // ==================== THEME PREFERENCE ====================

  /// Save dark mode preference securely
  Future<void> setDarkMode(bool isDark) async {
    try {
      await _storage.write(key: 'dark_mode', value: isDark.toString());
    } catch (e) {
      print('Error saving dark mode: $e');
    }
  }

  /// Get dark mode preference
  Future<bool> isDarkMode() async {
    try {
      final value = await _storage.read(key: 'dark_mode');
      return value == 'true';
    } catch (e) {
      print('Error reading dark mode: $e');
      return false;
    }
  }

  // ==================== USER PREFERENCES ====================

  /// Save user's preferred language
  Future<void> setLanguage(String language) async {
    try {
      await _storage.write(key: 'language', value: language);
    } catch (e) {
      print('Error saving language: $e');
    }
  }

  /// Get user's preferred language
  Future<String?> getLanguage() async {
    try {
      return await _storage.read(key: 'language');
    } catch (e) {
      print('Error reading language: $e');
      return null;
    }
  }

  /// Save notification preferences
  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      await _storage.write(
        key: 'notifications_enabled',
        value: enabled.toString(),
      );
    } catch (e) {
      print('Error saving notification preference: $e');
    }
  }

  /// Get notification preferences
  Future<bool> areNotificationsEnabled() async {
    try {
      final value = await _storage.read(key: 'notifications_enabled');
      return value == 'true';
    } catch (e) {
      print('Error reading notification preference: $e');
      return false;
    }
  }

  /// Save water reminder enabled preference
  Future<void> setWaterReminderEnabled(bool enabled) async {
    try {
      await _storage.write(
        key: 'water_reminder_enabled',
        value: enabled.toString(),
      );
    } catch (e) {
      print('Error saving water reminder preference: $e');
    }
  }

  /// Get water reminder enabled preference
  Future<bool> getWaterReminderEnabled() async {
    try {
      final value = await _storage.read(key: 'water_reminder_enabled');
      return value == 'true';
    } catch (e) {
      print('Error reading water reminder preference: $e');
      return false;
    }
  }

  /// Save water reminder interval in minutes
  Future<void> setWaterReminderInterval(int minutes) async {
    try {
      await _storage.write(
        key: 'water_reminder_interval',
        value: minutes.toString(),
      );
    } catch (e) {
      print('Error saving water reminder interval: $e');
    }
  }

  /// Get water reminder interval in minutes
  Future<int> getWaterReminderInterval() async {
    try {
      final value = await _storage.read(key: 'water_reminder_interval');
      if (value != null) {
        return int.parse(value);
      }
      return 240; // Default: 4 hours
    } catch (e) {
      print('Error reading water reminder interval: $e');
      return 240;
    }
  }

  /// Get favorite foods set
  Future<Set<String>> getFavoriteFoods() async {
    try {
      final value = await _storage.read(key: 'favorite_foods');
      if (value != null) {
        final List<dynamic> list = jsonDecode(value);
        return Set<String>.from(list);
      }
      return {};
    } catch (e) {
      print('Error reading favorite foods: $e');
      return {};
    }
  }

  /// Set favorite foods
  Future<void> setFavoriteFoods(Set<String> favorites) async {
    try {
      await _storage.write(
        key: 'favorite_foods',
        value: jsonEncode(favorites.toList()),
      );
    } catch (e) {
      print('Error saving favorite foods: $e');
    }
  }

  // ==================== SENSITIVE USER DATA ====================

  /// Save user's email (if needed for future features)
  Future<void> saveEmail(String email) async {
    try {
      await _storage.write(key: 'user_email', value: email);
    } catch (e) {
      print('Error saving email: $e');
    }
  }

  /// Get user's email
  Future<String?> getEmail() async {
    try {
      return await _storage.read(key: 'user_email');
    } catch (e) {
      print('Error reading email: $e');
      return null;
    }
  }

  /// Delete user's email
  Future<void> deleteEmail() async {
    try {
      await _storage.delete(key: 'user_email');
    } catch (e) {
      print('Error deleting email: $e');
    }
  }

  // ==================== BIOMETRIC SETTINGS ====================

  /// Save biometric authentication preference
  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _storage.write(key: 'biometric_enabled', value: enabled.toString());
    } catch (e) {
      print('Error saving biometric setting: $e');
    }
  }

  /// Get biometric authentication preference
  Future<bool> isBiometricEnabled() async {
    try {
      final value = await _storage.read(key: 'biometric_enabled');
      return value == 'true';
    } catch (e) {
      print('Error reading biometric setting: $e');
      return false;
    }
  }

  // ==================== APP SECURITY ====================

  /// Save app PIN (hashed)
  Future<void> saveAppPin(String hashedPin) async {
    try {
      await _storage.write(key: 'app_pin', value: hashedPin);
    } catch (e) {
      print('Error saving app PIN: $e');
    }
  }

  /// Get app PIN
  Future<String?> getAppPin() async {
    try {
      return await _storage.read(key: 'app_pin');
    } catch (e) {
      print('Error reading app PIN: $e');
      return null;
    }
  }

  /// Delete app PIN
  Future<void> deleteAppPin() async {
    try {
      await _storage.delete(key: 'app_pin');
    } catch (e) {
      print('Error deleting app PIN: $e');
    }
  }

  // ==================== BACKUP & SYNC ====================

  /// Save last backup timestamp
  Future<void> saveLastBackupTime(DateTime timestamp) async {
    try {
      await _storage.write(
        key: 'last_backup_time',
        value: timestamp.millisecondsSinceEpoch.toString(),
      );
    } catch (e) {
      print('Error saving backup time: $e');
    }
  }

  /// Get last backup timestamp
  Future<DateTime?> getLastBackupTime() async {
    try {
      final value = await _storage.read(key: 'last_backup_time');
      if (value != null) {
        return DateTime.fromMillisecondsSinceEpoch(int.parse(value));
      }
      return null;
    } catch (e) {
      print('Error reading backup time: $e');
      return null;
    }
  }

  // ==================== DATA MANAGEMENT ====================

  /// Clear all secure storage data
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
      print('All secure data cleared');
    } catch (e) {
      print('Error clearing secure storage: $e');
    }
  }

  /// Get all stored keys (for debugging only)
  Future<Map<String, String>> readAll() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      print('Error reading all secure data: $e');
      return {};
    }
  }

  /// Check if secure storage contains a specific key
  Future<bool> containsKey(String key) async {
    try {
      final value = await _storage.read(key: key);
      return value != null;
    } catch (e) {
      print('Error checking key: $e');
      return false;
    }
  }

  // ==================== FIRST RUN ====================

  /// Set first run flag
  Future<void> setFirstRun(bool isFirstRun) async {
    try {
      await _storage.write(key: 'first_run', value: isFirstRun.toString());
    } catch (e) {
      print('Error saving first run flag: $e');
    }
  }

  /// Check if this is the first run
  Future<bool> isFirstRun() async {
    try {
      final value = await _storage.read(key: 'first_run');
      return value != 'false'; // Default to true if not set
    } catch (e) {
      print('Error reading first run flag: $e');
      return true;
    }
  }
}
