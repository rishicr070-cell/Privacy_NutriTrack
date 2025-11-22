import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager with ChangeNotifier {
  static const String _themeKey = 'isDarkMode';
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  ThemeManager() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(_themeKey) ?? false;
      _updateSystemUI();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme preference: $e');
    }
  }

  void setDarkMode(bool isDark) {
    _isDarkMode = isDark;
    _updateSystemUI();
    notifyListeners();
    
    // Save preference in the background
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool(_themeKey, _isDarkMode);
    }).catchError((e) {
      debugPrint('Error saving theme preference: $e');
    });
  }

  Future<void> toggleTheme() async {
    setDarkMode(!_isDarkMode);
  }

  void _updateSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: _isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: _isDarkMode ? const Color(0xFF1A1A2E) : Colors.white,
        systemNavigationBarIconBrightness: _isDarkMode ? Brightness.light : Brightness.dark,
      ),
    );
  }
}

class AppThemes {
  static ThemeData get lightTheme {
    final baseTheme = ThemeData.light();
    return baseTheme.copyWith(
      colorScheme: ColorScheme.light(
        primary: const Color(0xFF00C9FF),
        secondary: const Color(0xFF92FE9D),
        surface: Colors.white,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(baseTheme.textTheme),
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      cardTheme: baseTheme.cardTheme.copyWith(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.all(0),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFF2D3142)),
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseTheme = ThemeData.dark();
    return baseTheme.copyWith(
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFF00C9FF),
        secondary: const Color(0xFF92FE9D),
        surface: const Color(0xFF16213E),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(baseTheme.textTheme),
      scaffoldBackgroundColor: const Color(0xFF1A1A2E),
      cardTheme: baseTheme.cardTheme.copyWith(
        elevation: 0,
        color: const Color(0xFF16213E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.all(0),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
    );
  }
}
