import '../models/food_item.dart';
import '../models/user_profile.dart';

class HealthAlert {
  final String title;
  final String message;
  final HealthAlertSeverity severity;
  final String condition;

  HealthAlert({
    required this.title,
    required this.message,
    required this.severity,
    required this.condition,
  });
}

enum HealthAlertSeverity {
  info,
  warning,
  danger,
}

class HealthAlertService {
  // Comprehensive list of health conditions with dietary restrictions
  static const Map<String, Map<String, dynamic>> healthConditionRules = {
    'diabetes': {
      'name': 'Diabetes',
      'icon': '🩺',
      'highSugarLimit': 15.0, // grams per serving
      'highCarbLimit': 45.0, // grams per serving
      'restrictedFoods': [
        'sugar', 'candy', 'cake', 'pastry', 'soda', 'juice', 'honey',
        'jaggery', 'gulab jamun', 'jalebi', 'rasgulla', 'burfi', 'ladoo',
        'ice cream', 'chocolate', 'cookie', 'biscuit', 'sweet', 'mithai',
        'kheer', 'halwa', 'barfi', 'peda', 'mysore pak', 'kaju katli',
        'ras malai', 'chocolate ice cream', 'vanilla ice cream', 'kulfi',
        'falooda', 'shrikhand', 'basundi'
      ],
    },
    'hypertension': {
      'name': 'Hypertension (High Blood Pressure)',
      'icon': '❤️',
      'highSodiumLimit': 300.0, // mg per serving (ideally <2000mg/day)
      'restrictedFoods': [
        'salt', 'pickle', 'papad', 'chips', 'namkeen', 'soy sauce',
        'processed meat', 'canned soup', 'instant noodles', 'salted nuts'
      ],
    },
    'heart_disease': {
      'name': 'Heart Disease',
      'icon': '💓',
      'highFatLimit': 10.0, // grams per serving
      'highSaturatedFatLimit': 5.0, // grams per serving
      'highCholesterolLimit': 100.0, // mg per serving
      'restrictedFoods': [
        'butter', 'ghee', 'cream', 'cheese', 'fried food', 'red meat',
        'organ meats', 'coconut oil', 'palm oil', 'pakora', 'samosa',
        'paratha', 'puri', 'vadai'
      ],
    },
    'kidney_disease': {
      'name': 'Kidney Disease',
      'icon': '🫘',
      'highProteinLimit': 20.0, // grams per serving
      'highPotassiumLimit': 400.0, // mg per serving
      'highPhosphorusLimit': 200.0, // mg per serving
      'restrictedFoods': [
        'banana', 'orange', 'potato', 'tomato', 'spinach', 'beans',
        'lentils', 'nuts', 'dairy products', 'chocolate', 'cola',
        'whole wheat', 'brown rice'
      ],
    },
    'gout': {
      'name': 'Gout',
      'icon': '🦴',
      'highPurine': true,
      'restrictedFoods': [
        'red meat', 'organ meats', 'seafood', 'shellfish', 'sardines',
        'anchovies', 'beer', 'alcohol', 'sugary drinks', 'asparagus',
        'mushrooms', 'cauliflower'
      ],
    },
    'celiac_disease': {
      'name': 'Celiac Disease',
      'icon': '🌾',
      'glutenFree': true,
      'restrictedFoods': [
        'wheat', 'barley', 'rye', 'bread', 'pasta', 'noodles',
        'chapati', 'roti', 'paratha', 'naan', 'cake', 'cookies',
        'biscuits', 'pizza', 'burger bun'
      ],
    },
    'lactose_intolerance': {
      'name': 'Lactose Intolerance',
      'icon': '🥛',
      'dairyFree': true,
      'restrictedFoods': [
        'milk', 'cheese', 'butter', 'yogurt', 'cream', 'ice cream',
        'paneer', 'kheer', 'rasgulla', 'gulab jamun', 'lassi', 'buttermilk'
      ],
    },
    'fatty_liver': {
      'name': 'Fatty Liver Disease',
      'icon': '🫀',
      'highFatLimit': 8.0,
      'avoidAlcohol': true,
      'restrictedFoods': [
        'alcohol', 'fried food', 'fatty meat', 'butter', 'margarine',
        'refined carbs', 'white bread', 'pastries', 'soda', 'candy'
      ],
    },
    'ibs': {
      'name': 'Irritable Bowel Syndrome (IBS)',
      'icon': '🔄',
      'restrictedFoods': [
        'beans', 'lentils', 'cabbage', 'broccoli', 'onion', 'garlic',
        'dairy', 'wheat', 'artificial sweeteners', 'caffeine', 'alcohol',
        'spicy food'
      ],
    },
    'pcod': {
      'name': 'PCOD/PCOS',
      'icon': '👩',
      'lowGI': true,
      'highCarbLimit': 30.0,
      'restrictedFoods': [
        'white bread', 'white rice', 'pasta', 'sugary drinks', 'candy',
        'pastries', 'fried food', 'processed food'
      ],
    },
    'thyroid': {
      'name': 'Thyroid Disorder',
      'icon': '🦋',
      'restrictedFoods': [
        'soy products', 'cruciferous vegetables (raw)', 'millet',
        'processed food', 'excessive iodine'
      ],
    },
    'obesity': {
      'name': 'Obesity',
      'icon': '⚖️',
      'highCalorieLimit': 400.0,
      'highFatLimit': 15.0,
      'restrictedFoods': [
        'fried food', 'fast food', 'soda', 'candy', 'pastries',
        'chips', 'ice cream', 'processed food', 'sugary drinks'
      ],
    },
  };

  // Check for health alerts based on food and user profile
  static List<HealthAlert> checkFoodAlerts(
    FoodItem food,
    UserProfile? profile,
    double servingSize,
  ) {
    List<HealthAlert> alerts = [];

    if (profile == null || profile.healthConditions.isEmpty) {
      return alerts;
    }

    // Calculate actual nutrients based on serving size
    final multiplier = servingSize / 100;
    final actualCarbs = food.carbs * multiplier;
    final actualFat = food.fat * multiplier;
    final actualProtein = food.protein * multiplier;
    final actualCalories = food.calories * multiplier;

    for (String condition in profile.healthConditions) {
      final rules = healthConditionRules[condition];
      if (rules == null) continue;

      final conditionName = rules['name'] as String;
      final icon = rules['icon'] as String;

      // Check for restricted foods by name
      final restrictedFoods = rules['restrictedFoods'] as List<String>?;
      if (restrictedFoods != null) {
        for (String restricted in restrictedFoods) {
          if (food.name.toLowerCase().contains(restricted.toLowerCase())) {
            alerts.add(HealthAlert(
              title: '$icon $conditionName Alert',
              message:
                  '${food.name} contains "$restricted" which may not be suitable for $conditionName. Please consult your doctor.',
              severity: HealthAlertSeverity.danger,
              condition: condition,
            ));
            break;
          }
        }
      }

      // Diabetes checks
      if (condition == 'diabetes') {
        final highCarbLimit = rules['highCarbLimit'] as double;
        
        // High carbs warning
        if (actualCarbs > highCarbLimit) {
          alerts.add(HealthAlert(
            title: '$icon High Carbohydrate Warning',
            message:
                'This serving contains ${actualCarbs.toInt()}g of carbs, which is high for diabetes management. Consider a smaller portion.',
            severity: HealthAlertSeverity.warning,
            condition: condition,
          ));
        }
        
        // Very high carbs - danger alert
        if (actualCarbs > 60.0) {
          alerts.add(HealthAlert(
            title: '$icon DANGER: Very High Carbs',
            message:
                'This food contains ${actualCarbs.toInt()}g of carbs per serving! This can cause dangerous blood sugar spikes. Strongly not recommended for diabetes.',
            severity: HealthAlertSeverity.danger,
            condition: condition,
          ));
        }
      }

      // Hypertension checks
      if (condition == 'hypertension' && food.sodium != null) {
        final highSodiumLimit = rules['highSodiumLimit'] as double;
        final actualSodium = food.sodium! * multiplier;
        if (actualSodium > highSodiumLimit) {
          alerts.add(HealthAlert(
            title: '$icon High Sodium Warning',
            message:
                'This food contains ${actualSodium.toInt()}mg of sodium. High sodium intake can raise blood pressure.',
            severity: HealthAlertSeverity.warning,
            condition: condition,
          ));
        }
      }

      // Heart disease checks
      if (condition == 'heart_disease') {
        final highFatLimit = rules['highFatLimit'] as double;
        if (actualFat > highFatLimit) {
          alerts.add(HealthAlert(
            title: '$icon High Fat Warning',
            message:
                'This serving contains ${actualFat.toInt()}g of fat. Consider limiting fat intake for heart health.',
            severity: HealthAlertSeverity.warning,
            condition: condition,
          ));
        }
      }

      // Kidney disease checks
      if (condition == 'kidney_disease') {
        final highProteinLimit = rules['highProteinLimit'] as double;
        if (actualProtein > highProteinLimit) {
          alerts.add(HealthAlert(
            title: '$icon High Protein Warning',
            message:
                'This serving contains ${actualProtein.toInt()}g of protein. High protein can strain kidneys.',
            severity: HealthAlertSeverity.warning,
            condition: condition,
          ));
        }
      }

      // Obesity checks
      if (condition == 'obesity') {
        final highCalorieLimit = rules['highCalorieLimit'] as double;
        if (actualCalories > highCalorieLimit) {
          alerts.add(HealthAlert(
            title: '$icon High Calorie Warning',
            message:
                'This serving contains ${actualCalories.toInt()} calories. Consider portion control for weight management.',
            severity: HealthAlertSeverity.warning,
            condition: condition,
          ));
        }
      }

      // PCOD checks
      if (condition == 'pcod') {
        final highCarbLimit = rules['highCarbLimit'] as double;
        if (actualCarbs > highCarbLimit) {
          alerts.add(HealthAlert(
            title: '$icon High Carb Warning',
            message:
                'High carb foods can affect insulin levels in PCOD. This serving has ${actualCarbs.toInt()}g carbs.',
            severity: HealthAlertSeverity.warning,
            condition: condition,
          ));
        }
      }
    }

    // Check allergies
    for (String allergy in profile.allergies) {
      if (food.name.toLowerCase().contains(allergy.toLowerCase())) {
        alerts.add(HealthAlert(
          title: '⚠️ Allergy Alert',
          message:
              'WARNING: ${food.name} may contain ${allergy.toUpperCase()}, which you are allergic to!',
          severity: HealthAlertSeverity.danger,
          condition: 'allergy',
        ));
      }
    }

    return alerts;
  }

  // Get all available health conditions
  static List<Map<String, String>> getAllHealthConditions() {
    return healthConditionRules.entries.map((entry) {
      return {
        'id': entry.key,
        'name': entry.value['name'] as String,
        'icon': entry.value['icon'] as String,
      };
    }).toList();
  }

  // Get common allergies
  static List<String> getCommonAllergies() {
    return [
      'Peanuts',
      'Tree Nuts',
      'Milk',
      'Eggs',
      'Wheat',
      'Soy',
      'Fish',
      'Shellfish',
      'Sesame',
      'Mustard',
    ];
  }
}
