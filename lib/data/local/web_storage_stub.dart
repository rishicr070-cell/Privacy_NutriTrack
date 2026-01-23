// Stub for non-web platforms
// WebStorage is only available on web

class WebStorage {
  static void setString(String key, String value) {}
  static String? getString(String key) => null;
  static void setBool(String key, bool value) {}
  static bool? getBool(String key) => null;
  static void setInt(String key, int value) {}
  static int? getInt(String key) => null;
  static void remove(String key) {}
  static void clear() {}
  static Set<String> getKeys() => {};
}
