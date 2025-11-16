import 'package:flutter/material.dart';
import 'dart:math' as math;

class NutritionRingChart extends StatelessWidget {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double calorieGoal;
  final double proteinGoal;
  final double carbsGoal;
  final double fatGoal;

  const NutritionRingChart({
    super.key,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.calorieGoal,
    required this.proteinGoal,
    required this.carbsGoal,
    required this.fatGoal,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(200, 200),
            painter: RingChartPainter(
              proteinPercentage: (protein / proteinGoal).clamp(0.0, 1.0),
              carbsPercentage: (carbs / carbsGoal).clamp(0.0, 1.0),
              fatPercentage: (fat / fatGoal).clamp(0.0, 1.0),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${calories.toInt()}',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                'calories',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RingChartPainter extends CustomPainter {
  final double proteinPercentage;
  final double carbsPercentage;
  final double fatPercentage;

  RingChartPainter({
    required this.proteinPercentage,
    required this.carbsPercentage,
    required this.fatPercentage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw background circles
    final backgroundPaint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - 6, backgroundPaint);
    canvas.drawCircle(center, radius - 22, backgroundPaint);
    canvas.drawCircle(center, radius - 38, backgroundPaint);

    // Draw protein ring (outer)
    _drawRing(
      canvas,
      center,
      radius - 6,
      proteinPercentage,
      Colors.blue,
    );

    // Draw carbs ring (middle)
    _drawRing(
      canvas,
      center,
      radius - 22,
      carbsPercentage,
      Colors.orange,
    );

    // Draw fat ring (inner)
    _drawRing(
      canvas,
      center,
      radius - 38,
      fatPercentage,
      Colors.purple,
    );
  }

  void _drawRing(Canvas canvas, Offset center, double radius,
      double percentage, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * percentage;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(RingChartPainter oldDelegate) {
    return oldDelegate.proteinPercentage != proteinPercentage ||
        oldDelegate.carbsPercentage != carbsPercentage ||
        oldDelegate.fatPercentage != fatPercentage;
  }
}
