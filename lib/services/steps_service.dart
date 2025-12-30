import 'package:pedometer/pedometer.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class StepsService {
  static Stream<StepCount>? _stepCountStream;
  static int _todaySteps = 0;
  static DateTime? _lastResetDate;

  /// Initialize step counting stream
  static void initPedometer() {
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream?.listen(_onStepCount, onError: _onStepCountError);
  }

  /// Handle step count updates
  static void _onStepCount(StepCount event) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Reset steps at midnight
    if (_lastResetDate == null || _lastResetDate!.isBefore(today)) {
      _todaySteps = 0;
      _lastResetDate = today;
    }

    _todaySteps = event.steps;
    debugPrint('Steps: $_todaySteps');
  }

  /// Handle errors
  static void _onStepCountError(error) {
    debugPrint('Step count error: $error');
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

  /// Get current step count
  static int getTodaySteps() {
    return _todaySteps;
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
