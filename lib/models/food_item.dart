class FoodItem {
  final String foodCode;
  final String foodName;
  final String? category;
  final double energyKcal;
  final double carbG;
  final double proteinG;
  final double fatG;
  final double? sodium; // Added for health alerts

  String get name => foodName;
  double get calories => energyKcal;
  double get protein => proteinG;
  double get carbs => carbG;
  double get fat => fatG;

  FoodItem({
    required this.foodCode,
    required this.foodName,
    this.category,
    required this.energyKcal,
    required this.carbG,
    required this.proteinG,
    required this.fatG,
    this.sodium,
  });

  factory FoodItem.fromCsv(List<dynamic> csvRow) {
    return FoodItem(
      foodCode: csvRow[0].toString(),
      foodName: csvRow[1].toString(),
      category: null,
      energyKcal: double.tryParse(csvRow[4].toString()) ?? 0.0,
      carbG: double.tryParse(csvRow[5].toString()) ?? 0.0,
      proteinG: double.tryParse(csvRow[6].toString()) ?? 0.0,
      fatG: double.tryParse(csvRow[7].toString()) ?? 0.0,
      sodium: csvRow.length > 8 ? double.tryParse(csvRow[8].toString()) : null,
    );
  }

  /// Parse Kaggle dataset CSV format
  /// Columns: 0=index, 1=Unnamed:0, 2=food, 3=Caloric Value, 4=Fat,
  ///          5=Saturated Fats, 6=Monounsaturated Fats, 7=Polyunsaturated Fats,
  ///          8=Carbohydrates, 9=Sugars, 10=Protein, 11=Dietary Fiber, 12=Cholesterol, 13=Sodium...
  factory FoodItem.fromKaggleCsv(List<dynamic> csvRow) {
    if (csvRow.length < 14) {
      // Fallback for malformed rows
      return FoodItem(
        foodCode: 'KG${csvRow[0]}',
        foodName: csvRow.length > 2 ? csvRow[2].toString() : 'Unknown',
        category: 'International',
        energyKcal: 0.0,
        carbG: 0.0,
        proteinG: 0.0,
        fatG: 0.0,
        sodium: null,
      );
    }

    return FoodItem(
      foodCode: 'KG${csvRow[0]}', // Prefix with KG for Kaggle
      foodName: csvRow[2].toString(), // Column 2 is food name
      category: 'International', // Mark as international food
      energyKcal: double.tryParse(csvRow[3].toString()) ?? 0.0, // Caloric Value
      carbG: double.tryParse(csvRow[8].toString()) ?? 0.0, // Carbohydrates
      proteinG: double.tryParse(csvRow[10].toString()) ?? 0.0, // Protein
      fatG: double.tryParse(csvRow[4].toString()) ?? 0.0, // Fat
      sodium: double.tryParse(csvRow[13].toString()), // Sodium
    );
  }

  /// Parse Indian_Food_DF.csv format (branded Indian foods)
  /// Columns: 0=food_link, 1=name, 2=brand, 3=nutri_score, 4=processing_score,
  ///          5=nutri_energy, 6=nutri_fat, 7=nutri_satuFat, 8=nutri_carbohydrate,
  ///          9=nutri_sugar, 10=nutri_fiber, 11=nutri_protein, 12=nutri_salt
  factory FoodItem.fromIndianFoodDFCsv(List<dynamic> csvRow) {
    if (csvRow.length < 12) {
      return FoodItem(
        foodCode: 'IDF${csvRow.hashCode}',
        foodName: csvRow.length > 1 ? csvRow[1].toString() : 'Unknown',
        category: 'Indian Branded',
        energyKcal: 0.0,
        carbG: 0.0,
        proteinG: 0.0,
        fatG: 0.0,
        sodium: null,
      );
    }

    // Extract calories from energy string (e.g., "1,117 kj\n(267 kcal)")
    String energyStr = csvRow[5].toString();
    double calories = 0.0;
    RegExp calorieRegex = RegExp(r'\((\d+)\s*kcal\)');
    Match? match = calorieRegex.firstMatch(energyStr);
    if (match != null) {
      calories = double.tryParse(match.group(1)!) ?? 0.0;
    }

    return FoodItem(
      foodCode: 'IDF${csvRow.hashCode}',
      foodName: csvRow[1].toString(),
      category: csvRow.length > 2 ? 'Indian - ${csvRow[2]}' : 'Indian Branded',
      energyKcal: calories,
      carbG:
          double.tryParse(
            csvRow[8].toString().replaceAll(RegExp(r'[^0-9.]'), ''),
          ) ??
          0.0,
      proteinG:
          double.tryParse(
            csvRow[11].toString().replaceAll(RegExp(r'[^0-9.]'), ''),
          ) ??
          0.0,
      fatG:
          double.tryParse(
            csvRow[6].toString().replaceAll(RegExp(r'[^0-9.]'), ''),
          ) ??
          0.0,
      sodium: double.tryParse(
        csvRow.length > 12
            ? csvRow[12].toString().replaceAll(RegExp(r'[^0-9.]'), '')
            : '0',
      ),
    );
  }

  /// Parse cleaned_nutrition_dataset_per100g.csv format
  /// Columns: 0=Vitamin C, 1=Vitamin B11, 2=Sodium, 3=Calcium, 4=Carbohydrates,
  ///          5=food, 6=Iron, 7=Calories, 8=Sugars, 9=Dietary Fiber, 10=Fat, 11=Protein, 12=food_normalized
  factory FoodItem.fromPer100gCsv(List<dynamic> csvRow) {
    if (csvRow.length < 12) {
      return FoodItem(
        foodCode: 'P100${csvRow.hashCode}',
        foodName: csvRow.length > 5 ? csvRow[5].toString() : 'Unknown',
        category: 'Per 100g',
        energyKcal: 0.0,
        carbG: 0.0,
        proteinG: 0.0,
        fatG: 0.0,
        sodium: null,
      );
    }

    return FoodItem(
      foodCode: 'P100${csvRow.hashCode}',
      foodName: csvRow[5].toString(),
      category: 'Per 100g',
      energyKcal: double.tryParse(csvRow[7].toString()) ?? 0.0,
      carbG: double.tryParse(csvRow[4].toString()) ?? 0.0,
      proteinG: double.tryParse(csvRow[11].toString()) ?? 0.0,
      fatG: double.tryParse(csvRow[10].toString()) ?? 0.0,
      sodium: double.tryParse(csvRow[2].toString()),
    );
  }

  /// Parse indian_food_nutrition_dataset.csv format (traditional dishes)
  /// Columns: 0=Food Name, 1=Category, 2=Serving Size, 3=Calories (kcal),
  ///          4=Protein (g), 5=Carbohydrates (g), 6=Fats (g), 7=Dietary Preference
  factory FoodItem.fromTraditionalIndianCsv(List<dynamic> csvRow) {
    if (csvRow.length < 7) {
      return FoodItem(
        foodCode: 'TI${csvRow.hashCode}',
        foodName: csvRow.length > 0 ? csvRow[0].toString() : 'Unknown',
        category: 'Traditional Indian',
        energyKcal: 0.0,
        carbG: 0.0,
        proteinG: 0.0,
        fatG: 0.0,
        sodium: null,
      );
    }

    return FoodItem(
      foodCode: 'TI${csvRow.hashCode}',
      foodName: csvRow[0].toString(),
      category: csvRow[1].toString(),
      energyKcal: double.tryParse(csvRow[3].toString()) ?? 0.0,
      carbG: double.tryParse(csvRow[5].toString()) ?? 0.0,
      proteinG: double.tryParse(csvRow[4].toString()) ?? 0.0,
      fatG: double.tryParse(csvRow[6].toString()) ?? 0.0,
      sodium: null,
    );
  }
}
