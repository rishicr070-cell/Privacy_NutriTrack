import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:privacy_first_nutrition_tracking_app/data/local/storage_helper.dart';
import 'package:privacy_first_nutrition_tracking_app/data/models/food_entry.dart';
import 'package:privacy_first_nutrition_tracking_app/data/models/user_profile.dart';

class ExportService {
  /// Export all food entries to CSV format
  static Future<String> exportToCSV() async {
    try {
      final entries = await StorageHelper.getFoodEntries();

      // CSV Header
      final csvLines = <String>[
        'Date,Time,Meal Type,Food Name,Serving Size,Serving Unit,Calories,Protein (g),Carbs (g),Fat (g)',
      ];

      // Add each entry
      for (final entry in entries) {
        final date =
            '${entry.timestamp.year}-${entry.timestamp.month.toString().padLeft(2, '0')}-${entry.timestamp.day.toString().padLeft(2, '0')}';
        final time =
            '${entry.timestamp.hour.toString().padLeft(2, '0')}:${entry.timestamp.minute.toString().padLeft(2, '0')}';

        csvLines.add(
          '$date,$time,${_escapeCsv(entry.mealType)},${_escapeCsv(entry.name)},${entry.servingSize},${_escapeCsv(entry.servingUnit)},${entry.calories},${entry.protein},${entry.carbs},${entry.fat}',
        );
      }

      return csvLines.join('\n');
    } catch (e) {
      throw Exception('Error exporting to CSV: $e');
    }
  }

  /// Export user profile to CSV format
  static Future<String> exportProfileToCSV() async {
    try {
      final profile = await StorageHelper.getUserProfile();

      if (profile == null) {
        return 'No profile data available';
      }

      final csvLines = <String>[
        'Field,Value',
        'Name,${_escapeCsv(profile.name)}',
        'Age,${profile.age}',
        'Gender,${_escapeCsv(profile.gender)}',
        'Height (cm),${profile.height}',
        'Weight (kg),${profile.weight}',
        'Activity Level,${_escapeCsv(profile.activityLevel)}',
        'Goal,${_escapeCsv(profile.goal)}',
        'Calorie Goal,${profile.calorieGoal}',
        'Protein Goal (g),${profile.proteinGoal}',
        'Carbs Goal (g),${profile.carbsGoal}',
        'Fat Goal (g),${profile.fatGoal}',
        'Water Goal (ml),${profile.waterGoal}',
      ];

      return csvLines.join('\n');
    } catch (e) {
      throw Exception('Error exporting profile: $e');
    }
  }

  /// Save CSV to file and share it
  static Future<void> shareCSV(String csvContent, String filename) async {
    try {
      if (kIsWeb) {
        // For web, we can't save files directly, but we can trigger download
        throw UnsupportedError(
          'File export not supported on web. Please use mobile app.',
        );
      }

      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$filename');

      // Write CSV content
      await file.writeAsString(csvContent);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'NutriTrack Export - $filename',
        text: 'Your nutrition data export from NutriTrack',
      );
    } catch (e) {
      throw Exception('Error sharing CSV: $e');
    }
  }

  /// Export all data (entries + profile)
  static Future<void> exportAllData() async {
    try {
      // Export food entries
      final entriesCSV = await exportToCSV();
      final timestamp = DateTime.now()
          .toIso8601String()
          .split('.')[0]
          .replaceAll(':', '-');
      await shareCSV(entriesCSV, 'nutritrack_entries_$timestamp.csv');

      // Note: Profile export can be added separately if needed
    } catch (e) {
      throw Exception('Error exporting all data: $e');
    }
  }

  /// Get export summary
  static Future<Map<String, dynamic>> getExportSummary() async {
    try {
      final entries = await StorageHelper.getFoodEntries();
      final profile = await StorageHelper.getUserProfile();

      return {
        'totalEntries': entries.length,
        'hasProfile': profile != null,
        'oldestEntry': entries.isNotEmpty ? entries.first.timestamp : null,
        'newestEntry': entries.isNotEmpty ? entries.last.timestamp : null,
      };
    } catch (e) {
      return {
        'totalEntries': 0,
        'hasProfile': false,
        'oldestEntry': null,
        'newestEntry': null,
      };
    }
  }

  /// Helper method to properly escape CSV values
  static String _escapeCsv(String value) {
    // If value contains comma, quote, or newline, wrap in quotes and escape internal quotes
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
