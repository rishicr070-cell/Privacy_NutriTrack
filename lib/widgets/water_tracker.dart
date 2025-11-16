import 'package:flutter/material.dart';
import 'dart:math' as math;

class WaterTracker extends StatefulWidget {
  final int currentIntake;
  final double goal;
  final Function(int) onIntakeChanged;

  const WaterTracker({
    super.key,
    required this.currentIntake,
    required this.goal,
    required this.onIntakeChanged,
  });

  @override
  State<WaterTracker> createState() => _WaterTrackerState();
}

class _WaterTrackerState extends State<WaterTracker> with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  
  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (widget.currentIntake / widget.goal).clamp(0.0, 1.0);
    final glassCount = (widget.currentIntake / 250).floor();
    final liters = (widget.currentIntake / 1000).toStringAsFixed(1);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.withOpacity(0.05),
              Colors.lightBlue.withOpacity(0.02),
            ],
          ),
          border: Border.all(
            color: Colors.blue.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.blue, Colors.lightBlue],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.water_drop,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Water Intake',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$liters L of ${(widget.goal / 1000).toStringAsFixed(1)} L',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${(percentage * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _buildWaterGlass(percentage),
                        const SizedBox(height: 16),
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 800),
                          tween: Tween(begin: 0.0, end: percentage),
                          builder: (context, value, child) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: value,
                                minHeight: 12,
                                backgroundColor: Colors.blue.withOpacity(0.15),
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Column(
                    children: [
                      _buildActionButton(
                        icon: Icons.add,
                        onPressed: () {
                          widget.onIntakeChanged(widget.currentIntake + 250);
                        },
                        label: '+250ml',
                      ),
                      const SizedBox(height: 12),
                      _buildActionButton(
                        icon: Icons.remove,
                        onPressed: widget.currentIntake >= 250
                            ? () {
                                widget.onIntakeChanged(widget.currentIntake - 250);
                              }
                            : null,
                        label: '-250ml',
                        isRemove: true,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Glasses Today',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    '$glassCount / 8',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(8, (index) {
                  return TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 300 + (index * 50)),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 36,
                          height: 46,
                          decoration: BoxDecoration(
                            gradient: index < glassCount
                                ? const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.blue, Colors.lightBlue],
                                  )
                                : null,
                            color: index >= glassCount ? Colors.blue.withOpacity(0.1) : null,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: index < glassCount
                                  ? Colors.blue.withOpacity(0.3)
                                  : Colors.blue.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.water_drop,
                              color: index < glassCount
                                  ? Colors.white
                                  : Colors.blue.withOpacity(0.3),
                              size: 20,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaterGlass(double fillPercentage) {
    return SizedBox(
      width: 120,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(120, 140),
            painter: WaterGlassPainter(
              fillPercentage: fillPercentage,
              waveAnimation: _waveController,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${widget.currentIntake}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: fillPercentage > 0.5 ? Colors.white : Colors.blue,
                ),
              ),
              Text(
                'ml',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: fillPercentage > 0.5 
                      ? Colors.white.withOpacity(0.8) 
                      : Colors.blue.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required String label,
    bool isRemove = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: onPressed != null
                ? LinearGradient(
                    colors: isRemove
                        ? [Colors.red.shade400, Colors.red.shade600]
                        : [Colors.blue, Colors.lightBlue],
                  )
                : null,
            color: onPressed == null ? Colors.grey.withOpacity(0.2) : null,
            borderRadius: BorderRadius.circular(16),
            boxShadow: onPressed != null
                ? [
                    BoxShadow(
                      color: (isRemove ? Colors.red : Colors.blue).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: onPressed != null ? Colors.white : Colors.grey,
                size: 28,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: onPressed != null ? Colors.white : Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WaterGlassPainter extends CustomPainter {
  final double fillPercentage;
  final Animation<double> waveAnimation;

  WaterGlassPainter({
    required this.fillPercentage,
    required this.waveAnimation,
  }) : super(repaint: waveAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw glass outline
    final glassPaint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final glassPath = Path()
      ..moveTo(size.width * 0.2, 0)
      ..lineTo(size.width * 0.1, size.height)
      ..lineTo(size.width * 0.9, size.height)
      ..lineTo(size.width * 0.8, 0)
      ..close();

    canvas.drawPath(glassPath, glassPaint);

    // Draw water with wave effect
    if (fillPercentage > 0) {
      final waterPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.withOpacity(0.7),
            Colors.blue.withOpacity(0.9),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      final waterLevel = size.height * (1 - fillPercentage);
      final waveHeight = 8.0;
      final waveLength = size.width;

      final waterPath = Path();
      waterPath.moveTo(size.width * 0.1 + (size.height - waterLevel) * 0.1, waterLevel);

      // Create wave effect
      for (double i = 0; i <= size.width; i++) {
        final waveOffset = math.sin((i / waveLength * 2 * math.pi) + 
                          (waveAnimation.value * 2 * math.pi)) * 
                          waveHeight;
        final x = size.width * 0.1 + i * 0.8 + 
                  (size.height - waterLevel - waveOffset) * 0.1;
        final y = waterLevel + waveOffset;
        waterPath.lineTo(x, y);
      }

      waterPath.lineTo(size.width * 0.9, size.height);
      waterPath.lineTo(size.width * 0.1, size.height);
      waterPath.close();

      canvas.drawPath(waterPath, waterPaint);
    }
  }

  @override
  bool shouldRepaint(WaterGlassPainter oldDelegate) {
    return oldDelegate.fillPercentage != fillPercentage;
  }
}
