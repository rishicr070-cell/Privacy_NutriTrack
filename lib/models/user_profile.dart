class UserProfile {
  final String name;
  final int age;
  final double height; // in cm
  final double currentWeight; // in kg
  final double targetWeight; // in kg
  final String gender; // male, female, other
  final String activityLevel; // sedentary, light, moderate, active, very_active
  final double dailyCalorieGoal;
  final double dailyProteinGoal;
  final double dailyCarbsGoal;
  final double dailyFatGoal;
  final double dailyWaterGoal; // in ml
  final List<String> healthConditions; // New field for diseases/conditions
  final List<String> allergies; // New field for food allergies
  final String goalType; // 'weight_loss', 'weight_gain', 'maintenance'

  UserProfile({
    required this.name,
    required this.age,
    required this.height,
    required this.currentWeight,
    required this.targetWeight,
    required this.gender,
    required this.activityLevel,
    required this.dailyCalorieGoal,
    required this.dailyProteinGoal,
    required this.dailyCarbsGoal,
    required this.dailyFatGoal,
    required this.dailyWaterGoal,
    this.healthConditions = const [],
    this.allergies = const [],
    this.goalType = 'maintenance',
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'height': height,
      'currentWeight': currentWeight,
      'targetWeight': targetWeight,
      'gender': gender,
      'activityLevel': activityLevel,
      'dailyCalorieGoal': dailyCalorieGoal,
      'dailyProteinGoal': dailyProteinGoal,
      'dailyCarbsGoal': dailyCarbsGoal,
      'dailyFatGoal': dailyFatGoal,
      'dailyWaterGoal': dailyWaterGoal,
      'healthConditions': healthConditions,
      'allergies': allergies,
      'goalType': goalType,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'],
      age: json['age'],
      height: json['height'].toDouble(),
      currentWeight: json['currentWeight'].toDouble(),
      targetWeight: json['targetWeight'].toDouble(),
      gender: json['gender'],
      activityLevel: json['activityLevel'],
      dailyCalorieGoal: json['dailyCalorieGoal'].toDouble(),
      dailyProteinGoal: json['dailyProteinGoal'].toDouble(),
      dailyCarbsGoal: json['dailyCarbsGoal'].toDouble(),
      dailyFatGoal: json['dailyFatGoal'].toDouble(),
      dailyWaterGoal: json['dailyWaterGoal'].toDouble(),
      healthConditions: json['healthConditions'] != null
          ? List<String>.from(json['healthConditions'])
          : [],
      allergies: json['allergies'] != null
          ? List<String>.from(json['allergies'])
          : [],
      goalType: json['goalType'] ?? 'maintenance',
    );
  }

  UserProfile copyWith({
    String? name,
    int? age,
    double? height,
    double? currentWeight,
    double? targetWeight,
    String? gender,
    String? activityLevel,
    double? dailyCalorieGoal,
    double? dailyProteinGoal,
    double? dailyCarbsGoal,
    double? dailyFatGoal,
    double? dailyWaterGoal,
    List<String>? healthConditions,
    List<String>? allergies,
    String? goalType,
  }) {
    return UserProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      height: height ?? this.height,
      currentWeight: currentWeight ?? this.currentWeight,
      targetWeight: targetWeight ?? this.targetWeight,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
      dailyProteinGoal: dailyProteinGoal ?? this.dailyProteinGoal,
      dailyCarbsGoal: dailyCarbsGoal ?? this.dailyCarbsGoal,
      dailyFatGoal: dailyFatGoal ?? this.dailyFatGoal,
      dailyWaterGoal: dailyWaterGoal ?? this.dailyWaterGoal,
      healthConditions: healthConditions ?? this.healthConditions,
      allergies: allergies ?? this.allergies,
      goalType: goalType ?? this.goalType,
    );
  }

  double get bmi => currentWeight / ((height / 100) * (height / 100));

  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  // Auto-detect goal type based on current vs target weight
  String get autoGoalType {
    final weightDiff = currentWeight - targetWeight;
    if (weightDiff > 2) return 'weight_loss';
    if (weightDiff < -2) return 'weight_gain';
    return 'maintenance';
  }

  // Get weight difference in kg
  double get weightDifference => (currentWeight - targetWeight).abs();

  // Get goal description
  String get goalDescription {
    switch (autoGoalType) {
      case 'weight_loss':
        return 'Lose ${weightDifference.toStringAsFixed(1)}kg';
      case 'weight_gain':
        return 'Gain ${weightDifference.toStringAsFixed(1)}kg';
      default:
        return 'Maintain weight';
    }
  }
}
