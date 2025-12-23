import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Animated circular progress ring with gradient support
class AnimatedProgressRing extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Color startColor;
  final Color endColor;
  final Widget? child;
  final bool showMilestones;
  final Duration animationDuration;

  const AnimatedProgressRing({
    super.key,
    required this.progress,
    this.size = 120,
    this.strokeWidth = 12,
    required this.startColor,
    required this.endColor,
    this.child,
    this.showMilestones = true,
    this.animationDuration = const Duration(milliseconds: 1200),
  });

  @override
  State<AnimatedProgressRing> createState() => _AnimatedProgressRingState();
}

class _AnimatedProgressRingState extends State<AnimatedProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(begin: _animation.value, end: widget.progress)
          .animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
          );
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.5) {
      return widget.startColor;
    } else if (progress < 0.75) {
      return Color.lerp(
        widget.startColor,
        Colors.orange,
        (progress - 0.5) * 4,
      )!;
    } else if (progress < 1.0) {
      return Color.lerp(Colors.orange, widget.endColor, (progress - 0.75) * 4)!;
    } else {
      return widget.endColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background ring
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RingPainter(
                  progress: 1.0,
                  strokeWidth: widget.strokeWidth,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.1),
                  showMilestones: false,
                ),
              ),
              // Progress ring
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RingPainter(
                  progress: _animation.value,
                  strokeWidth: widget.strokeWidth,
                  color: _getProgressColor(_animation.value),
                  gradient: LinearGradient(
                    colors: [widget.startColor, widget.endColor],
                  ),
                  showMilestones: widget.showMilestones,
                ),
              ),
              // Center content
              if (widget.child != null) widget.child!,
            ],
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;
  final Gradient? gradient;
  final bool showMilestones;

  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    this.gradient,
    this.showMilestones = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Draw the arc
    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (gradient != null && progress > 0) {
      paint.shader = gradient!.createShader(rect);
    } else {
      paint.color = color;
    }

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);

    // Draw milestone markers
    if (showMilestones && progress > 0) {
      final milestones = [0.25, 0.5, 0.75, 1.0];
      final markerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      for (final milestone in milestones) {
        if (progress >= milestone) {
          final angle = startAngle + (2 * math.pi * milestone);
          final x = center.dx + radius * math.cos(angle);
          final y = center.dy + radius * math.sin(angle);
          canvas.drawCircle(Offset(x, y), strokeWidth / 3, markerPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
