import 'package:pedometer/pedometer.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StepsService {
  static Stream<StepCount>? _stepCountStream;
  static int _todaySteps = 0;
  static int _baselineSteps = 0; // Steps at the start of today
  static DateTime? _lastResetDate;
  static SharedPreferences? _prefs;

  /// Initialize shared preferences
  static Future<void> _initPrefs() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
      await _loadLastResetDate();
    }
  }

  /// Load the last reset date from storage
  static Future<void> _loadLastResetDate() async {
    final savedDate = _prefs?.getString('steps_last_reset_date');
    if (savedDate != null) {
      _lastResetDate = DateTime.parse(savedDate);
      debugPrint('📅 Loaded last reset date: $_lastResetDate');
    }

    // Load baseline steps
    _baselineSteps = _prefs?.getInt('steps_baseline') ?? 0;
    debugPrint('👟 Loaded baseline steps: $_baselineSteps');
  }

  /// Save the last reset date to storage
  static Future<void> _saveResetDate(DateTime date) async {
    await _prefs?.setString('steps_last_reset_date', date.toIso8601String());
    _lastResetDate = date;
    debugPrint('💾 Saved reset date: $date');
  }

  /// Save baseline steps
  static Future<void> _saveBaselineSteps(int steps) async {
    await _prefs?.setInt('steps_baseline', steps);
    _baselineSteps = steps;
    debugPrint('💾 Saved baseline steps: $steps');
  }

  /// Initialize step counting stream
  static Future<void> initPedometer() async {
    await _initPrefs();
    await _checkAndResetIfNeeded();

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream?.listen(_onStepCount, onError: _onStepCountError);
    debugPrint('✅ Pedometer initialized');
  }

  /// Check if we need to reset for a new day
  static Future<void> _checkAndResetIfNeeded() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_lastResetDate == null || _lastResetDate!.isBefore(today)) {
      debugPrint('🔄 New day detected! Resetting step counter...');
      _todaySteps = 0;
      _baselineSteps = 0;
      await _saveResetDate(today);
      await _saveBaselineSteps(0);
    }
  }

  /// Handle step count updates
  static Future<void> _onStepCount(StepCount event) async {
    await _checkAndResetIfNeeded();

    // Calculate today's steps by subtracting baseline
    // The pedometer gives cumulative steps since device boot
    if (_baselineSteps == 0) {
      // First reading of the day - set as baseline
      _baselineSteps = event.steps;
      await _saveBaselineSteps(_baselineSteps);
    }

    _todaySteps = event.steps - _baselineSteps;
    if (_todaySteps < 0) _todaySteps = 0; // Safety check

    debugPrint(
      '👟 Steps today: $_todaySteps (Total: ${event.steps}, Baseline: $_baselineSteps)',
    );
  }

  /// Handle errors
  static void _onStepCountError(error) {
    debugPrint('❌ Step count error: $error');
  }

  /// Request permissions for step tracking (Android 10+)
  static Future<bool> requestPermissions() async {
    try {
      if (await Permission.activityRecognition.isDenied) {
        final status = await Permission.activityRecognition.request();
        return status.isGranted;
      }
      return true;
    } catch (e) {
      debugPrint('Error requesting step permissions: $e');
      return true; // Return true for older Android versions
    }
  }

  /// Get current step count for today
  static Future<int> getTodaySteps() async {
    await _checkAndResetIfNeeded();
    return _todaySteps;
  }

  /// Manually reset steps (for testing or manual reset)
  static Future<void> resetSteps() async {
    await _initPrefs();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    _todaySteps = 0;
    _baselineSteps = 0;
    await _saveResetDate(today);
    await _saveBaselineSteps(0);
    debugPrint('🔄 Steps manually reset');
  }

  /// Calculate calories burned from steps (rough estimate)
  /// Average: 0.04 calories per step
  static double getCaloriesFromSteps(int steps) {
    return steps * 0.04;
  }

  /// Get step goal progress (0.0 to 1.0)
  static double getStepProgress(int currentSteps, int goal) {
    if (goal == 0) return 0.0;
    return (currentSteps / goal).clamp(0.0, 1.0);
  }
}
