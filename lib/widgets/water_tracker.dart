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
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  void _addWater(int amount) {
    final newIntake = widget.currentIntake + amount;
    widget.onIntakeChanged(newIntake);
  }

  void _subtractWater(int amount) {
    final newIntake = math.max(0, widget.currentIntake - amount);
    widget.onIntakeChanged(newIntake);
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (widget.currentIntake / widget.goal * 100).clamp(0, 100);
    final fillLevel = (widget.currentIntake / widget.goal).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF00D4FF).withOpacity(0.15),
            const Color(0xFF007AFF).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF00D4FF).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4FF).withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00D4FF), Color(0xFF007AFF)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.water_drop_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Water Intake',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.currentIntake}ml / ${widget.goal.toInt()}ml',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF00D4FF).withOpacity(0.2),
                      const Color(0xFF007AFF).withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${percentage.toInt()}%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF007AFF),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildWaterGlass(context, fillLevel),
              const SizedBox(width: 32),
              _buildControls(context),
            ],
          ),
          const SizedBox(height: 20),
          _buildQuickAddButtons(context),
        ],
      ),
    );
  }

  Widget _buildWaterGlass(BuildContext context, double fillLevel) {
    return SizedBox(
      width: 100,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glass container
          Container(
            width: 80,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              border: Border.all(
                color: const Color(0xFF00D4FF).withOpacity(0.4),
                width: 3,
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
              child: Stack(
                children: [
                  // Water fill
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                      height: 140 * fillLevel,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF00D4FF).withOpacity(0.7),
                            const Color(0xFF007AFF).withOpacity(0.9),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Animated wave effect
                  if (fillLevel > 0)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: AnimatedBuilder(
                        animation: _waveController,
                        builder: (context, child) {
                          return CustomPaint(
                            size: Size(80, 140 * fillLevel),
                            painter: WavePainter(
                              animation: _waveController.value,
                              color: const Color(0xFF00D4FF),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Percentage text
          Text(
            '${(fillLevel * 100).toInt()}%',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: fillLevel > 0.5
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface,
              shadows: fillLevel > 0.5
                  ? [
                      const Shadow(
                        color: Colors.black26,
                        offset: Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ]
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context) {
    return Column(
      children: [
        _buildControlButton(
          context,
          icon: Icons.add_rounded,
          onTap: () => _addWater(250),
          gradient: const LinearGradient(
            colors: [Color(0xFF00D4FF), Color(0xFF007AFF)],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '250ml',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 12),
        _buildControlButton(
          context,
          icon: Icons.remove_rounded,
          onTap: () => _subtractWater(250),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
              Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
            ],
          ),
          iconColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ],
    );
  }

  Widget _buildControlButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
    required Gradient gradient,
    Color iconColor = Colors.white,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00D4FF).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(icon, color: iconColor, size: 28),
        ),
      ),
    );
  }

  Widget _buildQuickAddButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickButton(
            context,
            label: '100ml',
            onTap: () => _addWater(100),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildQuickButton(
            context,
            label: '500ml',
            onTap: () => _addWater(500),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildQuickButton(
            context,
            label: 'Reset',
            onTap: () => widget.onIntakeChanged(0),
            isReset: true,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickButton(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
    bool isReset = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isReset
                ? Theme.of(context).colorScheme.error.withOpacity(0.1)
                : const Color(0xFF00D4FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isReset
                  ? Theme.of(context).colorScheme.error.withOpacity(0.3)
                  : const Color(0xFF00D4FF).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isReset
                  ? Theme.of(context).colorScheme.error
                  : const Color(0xFF007AFF),
            ),
          ),
        ),
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double animation;
  final Color color;

  WavePainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = 8.0;
    final waveLength = size.width;

    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x++) {
      final y = size.height -
          5 +
          waveHeight *
              math.sin((x / waveLength * 2 * math.pi) + (animation * 2 * math.pi));
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return animation != oldDelegate.animation;
  }
}
