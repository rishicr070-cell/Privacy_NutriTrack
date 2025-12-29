import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:privacy_first_nutrition_tracking_app/models/food_item.dart';

class FoodDataLoader {
  static Future<List<FoodItem>> loadFoodItems() async {
    final List<FoodItem> allFoods = [];

    // Load Indian food database (existing)
    try {
      final rawData = await rootBundle.loadString(
        'assets/Anuvaad_INDB_2024.11.csv',
      );
      List<List<dynamic>> listData = const CsvToListConverter().convert(
        rawData,
        eol: '\n',
      );

      // Remove header row
      if (listData.isNotEmpty) {
        listData.removeAt(0);
      }

      final indianFoods = listData.map((row) => FoodItem.fromCsv(row)).toList();
      allFoods.addAll(indianFoods);
      print('✅ Loaded ${indianFoods.length} Indian foods');
    } catch (e) {
      print('⚠️ Error loading Indian food database: $e');
    }

    // Load Kaggle food dataset (5 groups)
    final kaggleFiles = [
      'assets/final food dataset/FOOD-DATA-GROUP1.csv',
      'assets/final food dataset/FOOD-DATA-GROUP2.csv',
      'assets/final food dataset/FOOD-DATA-GROUP3.csv',
      'assets/final food dataset/FOOD-DATA-GROUP4.csv',
      'assets/final food dataset/FOOD-DATA-GROUP5.csv',
    ];

    for (final filePath in kaggleFiles) {
      try {
        final rawData = await rootBundle.loadString(filePath);
        List<List<dynamic>> listData = const CsvToListConverter().convert(
          rawData,
          eol: '\n',
        );

        // Remove header row
        if (listData.isNotEmpty) {
          listData.removeAt(0);
        }

        final kaggleFoods = listData
            .map((row) => FoodItem.fromKaggleCsv(row))
            .toList();
        allFoods.addAll(kaggleFoods);
        print(
          '✅ Loaded ${kaggleFoods.length} foods from ${filePath.split('/').last}',
        );
      } catch (e) {
        print('⚠️ Error loading $filePath: $e');
      }
    }

    // Load Indian branded foods (Indian_Food_DF.csv)
    try {
      final rawData = await rootBundle.loadString('assets/Indian_Food_DF.csv');
      List<List<dynamic>> listData = const CsvToListConverter().convert(
        rawData,
        eol: '\n',
      );

      if (listData.isNotEmpty) {
        listData.removeAt(0);
      }

      final indianBrandedFoods = listData
          .map((row) => FoodItem.fromIndianFoodDFCsv(row))
          .toList();
      allFoods.addAll(indianBrandedFoods);
      print('✅ Loaded ${indianBrandedFoods.length} Indian branded foods');
    } catch (e) {
      print('⚠️ Error loading Indian_Food_DF.csv: $e');
    }

    // Load per 100g nutrition data
    try {
      final rawData = await rootBundle.loadString(
        'assets/cleaned_nutrition_dataset_per100g.csv',
      );
      List<List<dynamic>> listData = const CsvToListConverter().convert(
        rawData,
        eol: '\n',
      );

      if (listData.isNotEmpty) {
        listData.removeAt(0);
      }

      final per100gFoods = listData
          .map((row) => FoodItem.fromPer100gCsv(row))
          .toList();
      allFoods.addAll(per100gFoods);
      print('✅ Loaded ${per100gFoods.length} foods (per 100g data)');
    } catch (e) {
      print('⚠️ Error loading cleaned_nutrition_dataset_per100g.csv: $e');
    }

    // Load traditional Indian dishes
    try {
      final rawData = await rootBundle.loadString(
        'assets/indian_food_nutrition_dataset.csv',
      );
      List<List<dynamic>> listData = const CsvToListConverter().convert(
        rawData,
        eol: '\n',
      );

      if (listData.isNotEmpty) {
        listData.removeAt(0);
      }

      final traditionalFoods = listData
          .map((row) => FoodItem.fromTraditionalIndianCsv(row))
          .toList();
      allFoods.addAll(traditionalFoods);
      print('✅ Loaded ${traditionalFoods.length} traditional Indian dishes');
    } catch (e) {
      print('⚠️ Error loading indian_food_nutrition_dataset.csv: $e');
    }

    print('📊 Total foods loaded: ${allFoods.length}');
    return allFoods;
  }
}
