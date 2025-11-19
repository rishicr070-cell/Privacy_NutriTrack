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
}
