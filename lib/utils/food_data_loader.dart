import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:privacy_first_nutrition_tracking_app/models/food_item.dart';

class FoodDataLoader {
  static Future<List<FoodItem>> loadFoodItems() async {
    final rawData = await rootBundle.loadString('assets/Anuvaad_INDB_2024.11.csv');
    List<List<dynamic>> listData = const CsvToListConverter().convert(rawData, eol: '\n');
    
    // Remove header row
    if (listData.isNotEmpty) {
      listData.removeAt(0);
    }

    List<FoodItem> foodItems = listData.map((row) => FoodItem.fromCsv(row)).toList();
    return foodItems;
  }
}
