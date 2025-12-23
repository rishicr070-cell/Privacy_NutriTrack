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
    'fried', 'deep fried', 'pakora', 'samosa', 'paratha', 'puri', 
    'vadai', 'vada', 'bonda', 'bhaji', 'bajji', 'tempura', 'french fries',
    'chips', 'wafer', 'crispy', 'fritter', 'cutlet'
  ];

  // Comprehensive list of health conditions with dietary restrictions
  static const Map<String, Map<String, dynamic>> healthConditionRules = {
    'diabetes': {
      'name': 'Diabetes',
      'icon': '🩺',
      'highSugarLimit': 15.0,
      'highCarbLimit': 45.0,
      'restrictedFoods': [
        'sugar', 'candy', 'cake', 'pastry', 'soda', 'juice', 'honey',
        'jaggery', 'gulab jamun', 'jalebi', 'rasgulla', 'burfi', 'ladoo',
        'ice cream', 'chocolate', 'cookie', 'biscuit', 'sweet', 'mithai',
        'kheer', 'halwa', 'barfi', 'peda', 'mysore pak', 'kaju katli',
        'ras malai', 'kulfi', 'falooda', 'shrikhand', 'basundi', 'donut',
        'muffin', 'brownie', 'pudding', 'custard', 'milkshake', 'cola',
        'pepsi', 'sprite', 'fanta', 'dessert', 'sweetened', 'syrup',
      ],
    },
    'hypertension': {
      'name': 'Hypertension (High Blood Pressure)',
      'icon': '❤️',
      'highSodiumLimit': 300.0,
      'restrictedFoods': [
        'salt', 'pickle', 'papad', 'chips', 'namkeen', 'soy sauce',
        'processed meat', 'canned soup', 'instant noodles', 'salted nuts',
        'salted', 'salty', 'vadapav', 'vada pav', 'pav bhaji', 'chaat',
        'bhujia', 'mixture', 'sauce', 'ketchup', 'preserved', 'cured',
        'smoked', 'bacon', 'ham', 'sausage', 'salami', 'pepperoni',
      ],
    },
    'heart_disease': {
      'name': 'Heart Disease',
      'icon': '💓',
      'highFatLimit': 10.0,
      'highSaturatedFatLimit': 5.0,
      'highCholesterolLimit': 100.0,
      'restrictedFoods': [
        'butter', 'ghee', 'cream', 'cheese', 'fried food', 'red meat',
        'organ meats', 'coconut oil', 'palm oil', 'pakora', 'samosa',
        'paratha', 'puri', 'vadai', 'fried', 'deep fried', 'fatty',
        'oily', 'chips', 'french fries', 'burger', 'pizza', 'fast food',
      ],
    },
    'kidney_disease': {
      'name': 'Kidney Disease',
      'icon': '🫘',
      'highProteinLimit': 20.0,
      'highPotassiumLimit': 400.0,
      'highPhosphorusLimit': 200.0,
      'restrictedFoods': [
        'banana', 'orange', 'potato', 'tomato', 'spinach', 'beans',
        'lentils', 'nuts', 'dairy products', 'chocolate', 'cola',
        'whole wheat', 'brown rice', 'avocado', 'dried fruit', 'nuts',
        'seeds', 'bran', 'dates', 'raisins', 'prunes',
      ],
    },
    'gout': {
      'name': 'Gout',
      'icon': '🦴',
      'highPurine': true,
      'restrictedFoods': [
        'red meat', 'organ meats', 'seafood', 'shellfish', 'sardines',
        'anchovies', 'beer', 'alcohol', 'sugary drinks', 'asparagus',
        'mushrooms', 'cauliflower', 'liver', 'kidney', 'brain', 'heart',
        'mutton', 'lamb', 'pork', 'bacon', 'fish', 'crab', 'lobster',
      ],
    },
    'celiac_disease': {
      'name': 'Celiac Disease',
      'icon': '🌾',
      'glutenFree': true,
      'restrictedFoods': [
        'wheat', 'barley', 'rye', 'bread', 'pasta', 'noodles',
        'chapati', 'roti', 'paratha', 'naan', 'cake', 'cookies',
        'biscuits', 'pizza', 'burger bun', 'atta', 'maida', 'semolina',
        'couscous', 'bulgur', 'farro', 'seitan', 'soy sauce',
      ],
    },
    'lactose_intolerance': {
      'name': 'Lactose Intolerance',
      'icon': '🥛',
      'dairyFree': true,
      'restrictedFoods': [
        'milk', 'cheese', 'butter', 'yogurt', 'cream', 'ice cream',
        'paneer', 'kheer', 'rasgulla', 'gulab jamun', 'lassi', 'buttermilk',
        'curd', 'dahi', 'dairy', 'whey', 'casein', 'ghee', 'malai',
      ],
    },
    'fatty_liver': {
      'name': 'Fatty Liver Disease',
      'icon': '🫀',
      'highFatLimit': 8.0,
      'avoidAlcohol': true,
      'restrictedFoods': [
        'alcohol', 'fried food', 'fatty meat', 'butter', 'margarine',
        'refined carbs', 'white bread', 'pastries', 'soda', 'candy',
        'beer', 'wine', 'liquor', 'oily', 'greasy', 'junk food',
      ],
    },
    'ibs': {
      'name': 'Irritable Bowel Syndrome (IBS)',
      'icon': '🔄',
      'restrictedFoods': [
        'beans', 'lentils', 'cabbage', 'broccoli', 'onion', 'garlic',
        'dairy', 'wheat', 'artificial sweeteners', 'caffeine', 'alcohol',
        'spicy food', 'chili', 'pepper', 'hot sauce', 'rajma', 'chana',
      ],
    },
    'pcod': {
      'name': 'PCOD/PCOS',
      'icon': '👩',
      'lowGI': true,
      'highCarbLimit': 30.0,
      'restrictedFoods': [
        'white bread', 'white rice', 'pasta', 'sugary drinks', 'candy',
        'pastries', 'fried food', 'processed food', 'maida', 'refined',
        'junk food', 'fast food', 'sweetened',
      ],
    },
    'thyroid': {
      'name': 'Thyroid Disorder',
      'icon': '🦋',
      'restrictedFoods': [
        'soy products', 'cruciferous vegetables (raw)', 'millet',
        'processed food', 'excessive iodine', 'soy', 'tofu', 'soybean',
      ],
    },
    'obesity': {
      'name': 'Obesity',
      'icon': '⚖️',
      'highCalorieLimit': 400.0,
      'highFatLimit': 15.0,
      'restrictedFoods': [
        'fried food', 'fast food', 'soda', 'candy', 'pastries',
        'chips', 'ice cream', 'processed food', 'sugary drinks',
        'junk food', 'burger', 'pizza', 'donut', 'cake',
      ],
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

    if (profile == null || profile.healthConditions.isEmpty && profile.allergies.isEmpty) {
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
        
        if (actualCarbs > highCarbLimit) {
          alerts.add(HealthAlert(
            title: '$icon High Carbohydrate Warning',
            message:
                'This serving contains ${actualCarbs.toInt()}g of carbs, which is high for diabetes management. Consider a smaller portion.',
            severity: HealthAlertSeverity.warning,
            condition: condition,
          ));
        }
        
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

      // Hypertension checks - IMPROVED
      if (condition == 'hypertension') {
        final highSodiumLimit = rules['highSodiumLimit'] as double;
        
        if (actualSodium > highSodiumLimit) {
          final severity = actualSodium > 600.0 
              ? HealthAlertSeverity.danger 
              : HealthAlertSeverity.warning;
          
          alerts.add(HealthAlert(
            title: actualSodium > 600.0 
                ? '$icon DANGER: Very High Sodium' 
                : '$icon High Sodium Warning',
            message:
                'This food contains ${actualSodium.toInt()}mg of sodium per serving. High sodium intake can raise blood pressure significantly.',
            severity: severity,
            condition: condition,
          ));
        }
      }

      // Heart disease checks - IMPROVED
      if (condition == 'heart_disease') {
        final highFatLimit = rules['highFatLimit'] as double;
        
        if (_isFriedFood(food.name)) {
          alerts.add(HealthAlert(
            title: '$icon Fried Food Warning',
            message:
                '${food.name} is fried/high in fat. Fried foods can increase cholesterol and heart disease risk.',
            severity: HealthAlertSeverity.warning,
            condition: condition,
          ));
        }
        
        if (actualFat > highFatLimit) {
          alerts.add(HealthAlert(
            title: '$icon High Fat Warning',
            message:
                'This serving contains ${actualFat.toInt()}g of fat. High fat intake can increase cholesterol and heart disease risk.',
            severity: actualFat > 20.0 
                ? HealthAlertSeverity.danger 
                : HealthAlertSeverity.warning,
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
        final highFatLimit = rules['highFatLimit'] as double;
        
        if (actualCalories > highCalorieLimit) {
          alerts.add(HealthAlert(
            title: '$icon High Calorie Warning',
            message:
                'This serving contains ${actualCalories.toInt()} calories. Consider portion control for weight management.',
            severity: HealthAlertSeverity.warning,
            condition: condition,
          ));
        }
        
        if (_isFriedFood(food.name)) {
          alerts.add(HealthAlert(
            title: '$icon Fried Food Alert',
            message:
                '${food.name} is fried/high-fat. Fried foods are calorie-dense and can hinder weight loss.',
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

      // Fatty liver checks
      if (condition == 'fatty_liver') {
        final highFatLimit = rules['highFatLimit'] as double;
        
        if (_isFriedFood(food.name) || actualFat > highFatLimit) {
          alerts.add(HealthAlert(
            title: '$icon High Fat Warning',
            message:
                'This food is high in fat (${actualFat.toInt()}g). High fat foods can worsen fatty liver disease.',
            severity: HealthAlertSeverity.warning,
            condition: condition,
          ));
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
