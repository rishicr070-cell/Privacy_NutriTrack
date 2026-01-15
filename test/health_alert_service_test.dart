import 'package:flutter_test/flutter_test.dart';
import 'package:privacy_first_nutrition_tracking_app/models/food_item.dart';
import 'package:privacy_first_nutrition_tracking_app/models/user_profile.dart';
import 'package:privacy_first_nutrition_tracking_app/utils/health_alert_service.dart';

void main() {
  group('HealthAlertService Tests', () {
    final defaultProfile = UserProfile(
      name: 'Test User',
      age: 30,
      gender: 'Male',
      height: 175,
      currentWeight: 70,
      targetWeight: 70,
      activityLevel: 'Moderate',
      dailyCalorieGoal: 2000,
      dailyProteinGoal: 150,
      dailyCarbsGoal: 200,
      dailyFatGoal: 65,
      dailyWaterGoal: 2500,
      healthConditions: [],
      allergies: [],
      goalType: 'maintenance',
    );

    test('Diabetes alert for Milkshake should mention sugar', () {
      final food = FoodItem(
        foodCode: 'T1',
        foodName: 'Mango Milkshake',
        energyKcal: 300,
        proteinG: 5,
        carbG: 40,
        fatG: 10,
        sodium: 50,
      );

      final profile = defaultProfile.copyWith(healthConditions: ['diabetes']);

      final alerts = HealthAlertService.checkFoodAlerts(food, profile, 100);

      final milkshakeAlert = alerts.firstWhere(
        (a) => a.message.toLowerCase().contains('milkshake'),
        orElse: () => throw Exception('Alert not found'),
      );

      expect(milkshakeAlert.message, contains('"milkshake" (sugar)'));
      expect(milkshakeAlert.condition, equals('diabetes'));
    });

    test('Hypertension alert for Soy Sauce should mention high sodium', () {
      final food = FoodItem(
        foodCode: 'T2',
        foodName: 'Sushi with Soy Sauce',
        energyKcal: 200,
        proteinG: 5,
        carbG: 30,
        fatG: 2,
        sodium: 1000,
      );

      final profile = defaultProfile.copyWith(
        healthConditions: ['hypertension'],
      );

      final alerts = HealthAlertService.checkFoodAlerts(food, profile, 100);

      final alert = alerts.firstWhere(
        (a) => a.message.toLowerCase().contains('soy sauce'),
        orElse: () => throw Exception('Alert not found'),
      );

      expect(alert.message, contains('"soy sauce" (high sodium content)'));
    });

    test('Celiac alert for Whole Wheat Bread should mention gluten', () {
      final food = FoodItem(
        foodCode: 'T3',
        foodName: 'Whole Wheat Bread',
        energyKcal: 150,
        proteinG: 4,
        carbG: 25,
        fatG: 2,
        sodium: 200,
      );

      final profile = defaultProfile.copyWith(
        healthConditions: ['celiac_disease'],
      );

      final alerts = HealthAlertService.checkFoodAlerts(food, profile, 100);

      final alert = alerts.firstWhere(
        (a) => a.message.toLowerCase().contains('wheat'),
        orElse: () => throw Exception('Alert not found'),
      );

      expect(alert.message, contains('"wheat" (gluten)'));
    });
  });
}
