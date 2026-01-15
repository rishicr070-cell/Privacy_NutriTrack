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

enum HealthAlertSeverity { info, warning, danger }

class HealthAlertService {
  // High sodium foods with estimated sodium content (mg per 100g)
  static const Map<String, double> highSodiumFoods = {
    'salt': 38000.0,
    'pickle': 3500.0,
    'papad': 1800.0,
    'chips': 500.0,
    'namkeen': 800.0,
    'soy sauce': 5500.0,
    'processed meat': 1000.0,
    'canned soup': 400.0,
    'instant noodles': 1500.0,
    'salted nuts': 400.0,
    'vadapav': 600.0,
    'vada pav': 600.0,
    'pav bhaji': 700.0,
    'chaat': 500.0,
    'bhujia': 900.0,
    'mixture': 700.0,
    'fryums': 800.0,
    'sauce': 1000.0,
    'ketchup': 1000.0,
    'cheese': 600.0,
    'pizza': 600.0,
    'burger': 500.0,
    'french fries': 300.0,
    'fried': 400.0,
  };

  // High fat/fried foods
  static const List<String> friedFoods = [
    'fried',
    'deep fried',
    'pakora',
    'samosa',
    'paratha',
    'puri',
    'vadai',
    'vada',
    'bonda',
    'bhaji',
    'bajji',
    'tempura',
    'french fries',
    'chips',
    'wafer',
    'crispy',
    'fritter',
    'cutlet',
  ];

  // Comprehensive list of health conditions with dietary restrictions
  static const Map<String, Map<String, dynamic>> healthConditionRules = {
    'diabetes': {
      'name': 'Diabetes',
      'icon': '🩺',
      'highSugarLimit': 15.0,
      'highCarbLimit': 45.0,
      'restrictedFoods': {
        'sugar': 'high sugar content',
        'candy': 'high sugar content',
        'cake': 'high sugar content',
        'pastry': 'high sugar content',
        'soda': 'high sugar content',
        'juice': 'high sugar content',
        'honey': 'high sugar content',
        'jaggery': 'high sugar content',
        'gulab jamun': 'high sugar content',
        'jalebi': 'high sugar content',
        'rasgulla': 'high sugar content',
        'burfi': 'high sugar content',
        'ladoo': 'high sugar content',
        'ice cream': 'high sugar content',
        'chocolate': 'high sugar content',
        'cookie': 'high sugar content',
        'biscuit': 'high sugar content',
        'sweet': 'high sugar content',
        'mithai': 'high sugar content',
        'kheer': 'high sugar content',
        'halwa': 'high sugar content',
        'barfi': 'high sugar content',
        'peda': 'high sugar content',
        'mysore pak': 'high sugar content',
        'kaju katli': 'high sugar content',
        'ras malai': 'high sugar content',
        'kulfi': 'high sugar content',
        'falooda': 'high sugar content',
        'shrikhand': 'high sugar content',
        'basundi': 'high sugar content',
        'donut': 'high sugar content',
        'muffin': 'high sugar content',
        'brownie': 'high sugar content',
        'pudding': 'high sugar content',
        'custard': 'high sugar content',
        'milkshake': 'sugar',
        'cola': 'high sugar content',
        'pepsi': 'high sugar content',
        'sprite': 'high sugar content',
        'fanta': 'high sugar content',
        'dessert': 'high sugar content',
        'sweetened': 'added sugar',
        'syrup': 'high sugar content',
      },
    },
    'hypertension': {
      'name': 'Hypertension (High Blood Pressure)',
      'icon': '❤️',
      'highSodiumLimit': 300.0,
      'restrictedFoods': {
        'salt': 'extremely high sodium',
        'pickle': 'high sodium content',
        'papad': 'high sodium content',
        'chips': 'high sodium content',
        'namkeen': 'high sodium content',
        'soy sauce': 'high sodium content',
        'processed meat': 'high sodium content',
        'canned soup': 'high sodium content',
        'instant noodles': 'high sodium content',
        'salted nuts': 'high sodium content',
        'salted': 'high sodium',
        'salty': 'high sodium',
        'vadapav': 'high sodium content',
        'vada pav': 'high sodium content',
        'pav bhaji': 'high sodium content',
        'chaat': 'high sodium content',
        'bhujia': 'high sodium content',
        'mixture': 'high sodium content',
        'sauce': 'high sodium content',
        'ketchup': 'high sodium content',
        'preserved': 'high sodium content',
        'cured': 'high sodium content',
        'smoked': 'high sodium content',
        'bacon': 'high sodium content',
        'ham': 'high sodium content',
        'sausage': 'high sodium content',
        'salami': 'high sodium content',
        'pepperoni': 'high sodium content',
      },
    },
    'heart_disease': {
      'name': 'Heart Disease',
      'icon': '💓',
      'highFatLimit': 10.0,
      'highSaturatedFatLimit': 5.0,
      'highCholesterolLimit': 100.0,
      'restrictedFoods': {
        'butter': 'saturated fat',
        'ghee': 'saturated fat',
        'cream': 'saturated fat',
        'cheese': 'saturated fat',
        'fried food': 'trans fat',
        'red meat': 'cholesterol',
        'organ meats': 'high cholesterol',
        'coconut oil': 'saturated fat',
        'palm oil': 'saturated fat',
        'pakora': 'trans fat',
        'samosa': 'trans fat',
        'paratha': 'high fat content',
        'puri': 'trans fat',
        'vadai': 'trans fat',
        'fried': 'unhealthy fats',
        'deep fried': 'unhealthy fats',
        'fatty': 'saturated fat',
        'oily': 'high fat content',
        'chips': 'trans fat',
        'french fries': 'trans fat',
        'burger': 'unhealthy fats',
        'pizza': 'saturated fat',
        'fast food': 'trans fat',
      },
    },
    'kidney_disease': {
      'name': 'Kidney Disease',
      'icon': '🫘',
      'highProteinLimit': 20.0,
      'highPotassiumLimit': 400.0,
      'highPhosphorusLimit': 200.0,
      'restrictedFoods': {
        'banana': 'potassium',
        'orange': 'potassium',
        'potato': 'potassium',
        'tomato': 'potassium',
        'spinach': 'potassium',
        'beans': 'phosphorus',
        'lentils': 'phosphorus',
        'nuts': 'phosphorus and potassium',
        'dairy products': 'phosphorus',
        'chocolate': 'phosphorus',
        'cola': 'phosphorus',
        'whole wheat': 'phosphorus',
        'brown rice': 'phosphorus',
        'avocado': 'potassium',
        'dried fruit': 'potassium',
        'seeds': 'phosphorus',
        'bran': 'phosphorus',
        'dates': 'potassium',
        'raisins': 'potassium',
        'prunes': 'potassium',
      },
    },
    'gout': {
      'name': 'Gout',
      'icon': '🦴',
      'highPurine': true,
      'restrictedFoods': {
        'red meat': 'purines',
        'organ meats': 'purines',
        'seafood': 'purines',
        'shellfish': 'purines',
        'sardines': 'purines',
        'anchovies': 'purines',
        'beer': 'purines',
        'alcohol': 'uric acid risk',
        'sugary drinks': 'fructose (increases uric acid)',
        'asparagus': 'purines',
        'mushrooms': 'purines',
        'cauliflower': 'purines',
        'liver': 'purines',
        'kidney': 'purines',
        'brain': 'purines',
        'heart': 'purines',
        'mutton': 'purines',
        'lamb': 'purines',
        'pork': 'purines',
        'bacon': 'purines',
        'fish': 'purines',
        'crab': 'purines',
        'lobster': 'purines',
      },
    },
    'celiac_disease': {
      'name': 'Celiac Disease',
      'icon': '🌾',
      'glutenFree': true,
      'restrictedFoods': {
        'wheat': 'gluten',
        'barley': 'gluten',
        'rye': 'gluten',
        'bread': 'gluten',
        'pasta': 'gluten',
        'noodles': 'gluten',
        'chapati': 'gluten',
        'roti': 'gluten',
        'paratha': 'gluten',
        'naan': 'gluten',
        'cake': 'gluten',
        'cookies': 'gluten',
        'biscuits': 'gluten',
        'pizza': 'gluten',
        'burger bun': 'gluten',
        'atta': 'gluten',
        'maida': 'gluten',
        'semolina': 'gluten',
        'couscous': 'gluten',
        'bulgur': 'gluten',
        'farro': 'gluten',
        'seitan': 'gluten',
        'soy sauce': 'gluten (wheat-based)',
      },
    },
    'lactose_intolerance': {
      'name': 'Lactose Intolerance',
      'icon': '🥛',
      'dairyFree': true,
      'restrictedFoods': {
        'milk': 'lactose',
        'cheese': 'lactose',
        'butter': 'lactose (trace amounts)',
        'yogurt': 'lactose',
        'cream': 'lactose',
        'ice cream': 'lactose',
        'paneer': 'lactose',
        'kheer': 'lactose',
        'rasgulla': 'lactose',
        'gulab jamun': 'lactose',
        'lassi': 'lactose',
        'buttermilk': 'lactose',
        'curd': 'lactose',
        'dahi': 'lactose',
        'dairy': 'lactose',
        'whey': 'lactose',
        'casein': 'dairy protein',
        'ghee': 'dairy origin',
        'malai': 'lactose',
      },
    },
    'fatty_liver': {
      'name': 'Fatty Liver Disease',
      'icon': '🫀',
      'highFatLimit': 8.0,
      'avoidAlcohol': true,
      'restrictedFoods': {
        'alcohol': 'liver toxin',
        'fried food': 'trans fat',
        'fatty meat': 'saturated fat',
        'butter': 'saturated fat',
        'margarine': 'trans fat',
        'refined carbs': 'high glycemic index',
        'white bread': 'refined carbs',
        'pastries': 'saturated fat and sugar',
        'soda': 'fructose',
        'candy': 'sugar',
        'beer': 'alcohol',
        'wine': 'alcohol',
        'liquor': 'alcohol',
        'oily': 'unhealthy fats',
        'greasy': 'unhealthy fats',
        'junk food': 'high fat and sugar',
      },
    },
    'ibs': {
      'name': 'Irritable Bowel Syndrome (IBS)',
      'icon': '🔄',
      'restrictedFoods': {
        'beans': 'FODMAPs (gas-producing)',
        'lentils': 'FODMAPs',
        'cabbage': 'gas-producing fibers',
        'broccoli': 'gas-producing fibers',
        'onion': 'fructans',
        'garlic': 'fructans',
        'dairy': 'lactose',
        'wheat': 'fructans',
        'artificial sweeteners': 'polyols (laxative effect)',
        'caffeine': 'gut stimulant',
        'alcohol': 'gut irritant',
        'spicy food': 'capsaicin (irritant)',
        'chili': 'irritant',
        'pepper': 'irritant',
        'hot sauce': 'irritant',
        'rajma': 'FODMAPs',
        'chana': 'FODMAPs',
      },
    },
    'pcod': {
      'name': 'PCOD/PCOS',
      'icon': '👩',
      'lowGI': true,
      'highCarbLimit': 30.0,
      'restrictedFoods': {
        'white bread': 'refined carbs',
        'white rice': 'high glycemic index',
        'pasta': 'refined carbs',
        'sugary drinks': 'added sugar',
        'candy': 'sugar',
        'pastries': 'refined carbs and fat',
        'fried food': 'trans fat',
        'processed food': 'refined ingredients',
        'maida': 'refined flour',
        'refined': 'high glycemic index',
        'junk food': 'high glycemic index',
        'fast food': 'trans fat',
        'sweetened': 'added sugar',
      },
    },
    'thyroid': {
      'name': 'Thyroid Disorder',
      'icon': '🦋',
      'restrictedFoods': {
        'soy products': 'goitrogens',
        'cruciferous vegetables (raw)': 'goitrogens',
        'millet': 'goitrogens',
        'processed food': 'refined ingredients',
        'excessive iodine': 'thyroid disruptor',
        'soy': 'goitrogens',
        'tofu': 'goitrogens',
        'soybean': 'goitrogens',
      },
    },
    'obesity': {
      'name': 'Obesity',
      'icon': '⚖️',
      'highCalorieLimit': 400.0,
      'highFatLimit': 15.0,
      'restrictedFoods': {
        'fried food': 'high calories and fat',
        'fast food': 'high calories',
        'soda': 'empty calories',
        'candy': 'high calorie density',
        'pastries': 'high calorie density',
        'chips': 'high calorie density',
        'ice cream': 'high fat and sugar',
        'processed food': 'empty calories',
        'sugary drinks': 'liquid calories',
        'junk food': 'high calorie density',
        'burger': 'high calories',
        'pizza': 'high calories',
        'donut': 'high calories',
        'cake': 'high calories',
      },
    },
  };

  // Estimate sodium content for common foods
  static double _estimateSodium(String foodName, double? actualSodium) {
    if (actualSodium != null && actualSodium > 0) {
      return actualSodium;
    }

    final lowerName = foodName.toLowerCase();

    // Check against high sodium foods database
    for (var entry in highSodiumFoods.entries) {
      if (lowerName.contains(entry.key)) {
        return entry.value;
      }
    }

    return 0.0;
  }

  // Check if food is fried/high fat
  static bool _isFriedFood(String foodName) {
    final lowerName = foodName.toLowerCase();
    return friedFoods.any((fried) => lowerName.contains(fried));
  }

  // Check for health alerts based on food and user profile
  static List<HealthAlert> checkFoodAlerts(
    FoodItem food,
    UserProfile? profile,
    double servingSize,
  ) {
    List<HealthAlert> alerts = [];

    if (profile == null ||
        profile.healthConditions.isEmpty && profile.allergies.isEmpty) {
      return alerts;
    }

    // Calculate actual nutrients based on serving size
    final multiplier = servingSize / 100;
    final actualCarbs = food.carbs * multiplier;
    final actualFat = food.fat * multiplier;
    final actualProtein = food.protein * multiplier;
    final actualCalories = food.calories * multiplier;

    // Estimate sodium with better detection
    final estimatedSodiumPer100g = _estimateSodium(food.name, food.sodium);
    final actualSodium = estimatedSodiumPer100g * multiplier;

    for (String condition in profile.healthConditions) {
      final rules = healthConditionRules[condition];
      if (rules == null) continue;

      final conditionName = rules['name'] as String;
      final icon = rules['icon'] as String;

      // Check for restricted foods by name
      final restrictedFoods = rules['restrictedFoods'] as Map<String, String>?;
      if (restrictedFoods != null) {
        for (var entry in restrictedFoods.entries) {
          if (food.name.toLowerCase().contains(entry.key.toLowerCase())) {
            final reason = entry.value;
            alerts.add(
              HealthAlert(
                title: '$icon $conditionName Alert',
                message:
                    '${food.name} contains "${entry.key}" ($reason) which may not be suitable for $conditionName. Please consult your doctor.',
                severity: HealthAlertSeverity.danger,
                condition: condition,
              ),
            );
            break;
          }
        }
      }

      // Diabetes checks
      if (condition == 'diabetes') {
        final highCarbLimit = rules['highCarbLimit'] as double;

        if (actualCarbs > highCarbLimit) {
          alerts.add(
            HealthAlert(
              title: '$icon High Carbohydrate Warning',
              message:
                  'This serving contains ${actualCarbs.toInt()}g of carbs, which is high for diabetes management. Consider a smaller portion.',
              severity: HealthAlertSeverity.warning,
              condition: condition,
            ),
          );
        }

        if (actualCarbs > 60.0) {
          alerts.add(
            HealthAlert(
              title: '$icon DANGER: Very High Carbs',
              message:
                  'This food contains ${actualCarbs.toInt()}g of carbs per serving! This can cause dangerous blood sugar spikes. Strongly not recommended for diabetes.',
              severity: HealthAlertSeverity.danger,
              condition: condition,
            ),
          );
        }
      }

      // Hypertension checks - IMPROVED
      if (condition == 'hypertension') {
        final highSodiumLimit = rules['highSodiumLimit'] as double;

        if (actualSodium > highSodiumLimit) {
          final severity = actualSodium > 600.0
              ? HealthAlertSeverity.danger
              : HealthAlertSeverity.warning;

          alerts.add(
            HealthAlert(
              title: actualSodium > 600.0
                  ? '$icon DANGER: Very High Sodium'
                  : '$icon High Sodium Warning',
              message:
                  'This food contains ${actualSodium.toInt()}mg of sodium per serving. High sodium intake can raise blood pressure significantly.',
              severity: severity,
              condition: condition,
            ),
          );
        }
      }

      // Heart disease checks - IMPROVED
      if (condition == 'heart_disease') {
        final highFatLimit = rules['highFatLimit'] as double;

        if (_isFriedFood(food.name)) {
          alerts.add(
            HealthAlert(
              title: '$icon Fried Food Warning',
              message:
                  '${food.name} is fried/high in fat. Fried foods can increase cholesterol and heart disease risk.',
              severity: HealthAlertSeverity.warning,
              condition: condition,
            ),
          );
        }

        if (actualFat > highFatLimit) {
          alerts.add(
            HealthAlert(
              title: '$icon High Fat Warning',
              message:
                  'This serving contains ${actualFat.toInt()}g of fat. High fat intake can increase cholesterol and heart disease risk.',
              severity: actualFat > 20.0
                  ? HealthAlertSeverity.danger
                  : HealthAlertSeverity.warning,
              condition: condition,
            ),
          );
        }
      }

      // Kidney disease checks
      if (condition == 'kidney_disease') {
        final highProteinLimit = rules['highProteinLimit'] as double;
        if (actualProtein > highProteinLimit) {
          alerts.add(
            HealthAlert(
              title: '$icon High Protein Warning',
              message:
                  'This serving contains ${actualProtein.toInt()}g of protein. High protein can strain kidneys.',
              severity: HealthAlertSeverity.warning,
              condition: condition,
            ),
          );
        }
      }

      // Obesity checks
      if (condition == 'obesity') {
        final highCalorieLimit = rules['highCalorieLimit'] as double;
        final highFatLimit = rules['highFatLimit'] as double;

        if (actualCalories > highCalorieLimit) {
          alerts.add(
            HealthAlert(
              title: '$icon High Calorie Warning',
              message:
                  'This serving contains ${actualCalories.toInt()} calories. Consider portion control for weight management.',
              severity: HealthAlertSeverity.warning,
              condition: condition,
            ),
          );
        }

        if (_isFriedFood(food.name)) {
          alerts.add(
            HealthAlert(
              title: '$icon Fried Food Alert',
              message:
                  '${food.name} is fried/high-fat. Fried foods are calorie-dense and can hinder weight loss.',
              severity: HealthAlertSeverity.warning,
              condition: condition,
            ),
          );
        }
      }

      // PCOD checks
      if (condition == 'pcod') {
        final highCarbLimit = rules['highCarbLimit'] as double;
        if (actualCarbs > highCarbLimit) {
          alerts.add(
            HealthAlert(
              title: '$icon High Carb Warning',
              message:
                  'High carb foods can affect insulin levels in PCOD. This serving has ${actualCarbs.toInt()}g carbs.',
              severity: HealthAlertSeverity.warning,
              condition: condition,
            ),
          );
        }
      }

      // Fatty liver checks
      if (condition == 'fatty_liver') {
        final highFatLimit = rules['highFatLimit'] as double;

        if (_isFriedFood(food.name) || actualFat > highFatLimit) {
          alerts.add(
            HealthAlert(
              title: '$icon High Fat Warning',
              message:
                  'This food is high in fat (${actualFat.toInt()}g). High fat foods can worsen fatty liver disease.',
              severity: HealthAlertSeverity.warning,
              condition: condition,
            ),
          );
        }
      }

      // Gout checks
      if (condition == 'gout') {
        // Already checked in restricted foods
      }

      // Celiac disease checks
      if (condition == 'celiac_disease') {
        // Already checked in restricted foods
      }

      // Lactose intolerance checks
      if (condition == 'lactose_intolerance') {
        // Already checked in restricted foods
      }

      // IBS checks
      if (condition == 'ibs') {
        // Already checked in restricted foods
      }

      // Thyroid checks
      if (condition == 'thyroid') {
        // Already checked in restricted foods
      }
    }

    // Check allergies - IMPROVED
    for (String allergy in profile.allergies) {
      final allergyLower = allergy.toLowerCase();
      final foodNameLower = food.name.toLowerCase();

      // More flexible matching
      if (foodNameLower.contains(allergyLower) ||
          allergyLower.contains(foodNameLower.split(' ').first)) {
        alerts.add(
          HealthAlert(
            title: '⚠️ Allergy Alert',
            message:
                'WARNING: ${food.name} may contain ${allergy.toUpperCase()}, which you are allergic to!',
            severity: HealthAlertSeverity.danger,
            condition: 'allergy',
          ),
        );
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
