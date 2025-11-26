// Web-specific storage implementation using browser's localStorage
// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:convert';

class WebStorage {
  static const String _prefix = 'nutritrack_';
  
  static void setString(String key, String value) {
    try {
      html.window.localStorage['$_prefix$key'] = value;
      print('WebStorage: Saved $key to localStorage');
    } catch (e) {
      print('WebStorage: Error saving $key: $e');
    }
  }
  
  static String? getString(String key) {
    try {
      final value = html.window.localStorage['$_prefix$key'];
      print('WebStorage: Retrieved $key: ${value != null ? "found" : "null"}');
      return value;
    } catch (e) {
      print('WebStorage: Error retrieving $key: $e');
      return null;
    }
  }
  
  static void setBool(String key, bool value) {
    setString(key, value.toString());
  }
  
  static bool? getBool(String key) {
    final value = getString(key);
    if (value == null) return null;
    return value.toLowerCase() == 'true';
  }
  
  static void setInt(String key, int value) {
    setString(key, value.toString());
  }
  
  static int? getInt(String key) {
    final value = getString(key);
    if (value == null) return null;
    return int.tryParse(value);
  }
  
  static void remove(String key) {
    try {
      html.window.localStorage.remove('$_prefix$key');
      print('WebStorage: Removed $key from localStorage');
    } catch (e) {
      print('WebStorage: Error removing $key: $e');
    }
  }
  
  static void clear() {
    try {
      final keys = html.window.localStorage.keys.where((k) => k.startsWith(_prefix)).toList();
      for (final key in keys) {
        html.window.localStorage.remove(key);
      }
      print('WebStorage: Cleared all data');
    } catch (e) {
      print('WebStorage: Error clearing data: $e');
    }
  }
  
  static Set<String> getKeys() {
    try {
      return html.window.localStorage.keys
          .where((k) => k.startsWith(_prefix))
          .map((k) => k.substring(_prefix.length))
          .toSet();
    } catch (e) {
      print('WebStorage: Error getting keys: $e');
      return {};
    }
  }
}
