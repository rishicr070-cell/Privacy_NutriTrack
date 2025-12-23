import 'package:flutter/material.dart';

/// Smart empty state widget with illustrations and CTAs
class EmptyStateWidget extends StatefulWidget {
  final EmptyStateType type;
  final String? title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  const EmptyStateWidget({
    super.key,
    required this.type,
    this.title,
    this.message,
    this.actionLabel,
    this.onActionPressed,
  });

  @override
  State<EmptyStateWidget> createState() => _EmptyStateWidgetState();
}

class _EmptyStateWidgetState extends State<EmptyStateWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Illustration
                CustomPaint(
                  size: const Size(200, 200),
                  painter: _EmptyStateIllustration(
                    type: widget.type,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 32),
                // Title
                Text(
                  widget.title ?? config['title']!,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // Message
                Text(
                  widget.message ?? config['message']!,
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (widget.onActionPressed != null) ...[
                  const SizedBox(height: 32),
                  // Action button
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: widget.onActionPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        widget.actionLabel ?? config['actionLabel']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Map<String, String> _getConfig() {
    switch (widget.type) {
      case EmptyStateType.noMeals:
        return {
          'title': 'No Meals Yet',
          'message':
              'Start tracking your nutrition by adding your first meal of the day!',
          'actionLabel': 'Add Meal',
        };
      case EmptyStateType.noData:
        return {
          'title': 'No Data Available',
          'message':
              'Track your meals for a few days to see insights and analytics.',
          'actionLabel': 'Get Started',
        };
      case EmptyStateType.noSearchResults:
        return {
          'title': 'No Results Found',
          'message':
              'Try adjusting your search terms or browse our food database.',
          'actionLabel': 'Clear Search',
        };
      case EmptyStateType.searchPrompt:
        return {
          'title': 'Search for Food',
          'message':
              'Enter a food name or scan a barcode to find nutrition information.',
          'actionLabel': 'Scan Barcode',
        };
    }
  }
}

enum EmptyStateType { noMeals, noData, noSearchResults, searchPrompt }

class _EmptyStateIllustration extends CustomPainter {
  final EmptyStateType type;
  final Color color;

  _EmptyStateIllustration({required this.type, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);

    switch (type) {
      case EmptyStateType.noMeals:
        _drawPlateIllustration(canvas, size, center, paint, strokePaint);
        break;
      case EmptyStateType.noData:
        _drawChartIllustration(canvas, size, center, paint, strokePaint);
        break;
      case EmptyStateType.noSearchResults:
        _drawSearchIllustration(canvas, size, center, paint, strokePaint);
        break;
      case EmptyStateType.searchPrompt:
        _drawScanIllustration(canvas, size, center, paint, strokePaint);
        break;
    }
  }

  void _drawPlateIllustration(
    Canvas canvas,
    Size size,
    Offset center,
    Paint paint,
    Paint strokePaint,
  ) {
    // Plate
    canvas.drawCircle(center, size.width * 0.35, paint);
    canvas.drawCircle(center, size.width * 0.35, strokePaint);

    // Fork and knife
    final forkPath = Path()
      ..moveTo(center.dx - 40, center.dy - 60)
      ..lineTo(center.dx - 40, center.dy + 20);
    canvas.drawPath(forkPath, strokePaint);

    for (int i = -1; i <= 1; i++) {
      canvas.drawLine(
        Offset(center.dx - 40 + (i * 8), center.dy - 60),
        Offset(center.dx - 40 + (i * 8), center.dy - 45),
        strokePaint,
      );
    }

    final knifePath = Path()
      ..moveTo(center.dx + 40, center.dy - 60)
      ..lineTo(center.dx + 40, center.dy + 20);
    canvas.drawPath(knifePath, strokePaint);
    canvas.drawLine(
      Offset(center.dx + 35, center.dy - 60),
      Offset(center.dx + 45, center.dy - 60),
      strokePaint,
    );
  }

  void _drawChartIllustration(
    Canvas canvas,
    Size size,
    Offset center,
    Paint paint,
    Paint strokePaint,
  ) {
    final barWidth = size.width * 0.12;
    final heights = [0.4, 0.6, 0.3, 0.7, 0.5];

    for (int i = 0; i < heights.length; i++) {
      final x = center.dx - (barWidth * 2.5) + (i * barWidth * 1.2);
      final height = size.height * heights[i] * 0.5;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, center.dy + 40 - height, barWidth, height),
        const Radius.circular(8),
      );
      canvas.drawRRect(rect, paint);
      canvas.drawRRect(rect, strokePaint);
    }

    // Axis lines
    canvas.drawLine(
      Offset(center.dx - size.width * 0.4, center.dy + 40),
      Offset(center.dx + size.width * 0.4, center.dy + 40),
      strokePaint,
    );
  }

  void _drawSearchIllustration(
    Canvas canvas,
    Size size,
    Offset center,
    Paint paint,
    Paint strokePaint,
  ) {
    // Magnifying glass
    canvas.drawCircle(
      Offset(center.dx - 15, center.dy - 15),
      size.width * 0.25,
      paint,
    );
    canvas.drawCircle(
      Offset(center.dx - 15, center.dy - 15),
      size.width * 0.25,
      strokePaint,
    );

    final handlePath = Path()
      ..moveTo(center.dx + 30, center.dy + 30)
      ..lineTo(center.dx + 60, center.dy + 60);
    strokePaint.strokeWidth = 6;
    canvas.drawPath(handlePath, strokePaint);
    strokePaint.strokeWidth = 3;
  }

  void _drawScanIllustration(
    Canvas canvas,
    Size size,
    Offset center,
    Paint paint,
    Paint strokePaint,
  ) {
    final cornerLength = size.width * 0.15;
    final scanSize = size.width * 0.5;

    // Top-left corner
    canvas.drawLine(
      Offset(center.dx - scanSize / 2, center.dy - scanSize / 2),
      Offset(center.dx - scanSize / 2 + cornerLength, center.dy - scanSize / 2),
      strokePaint,
    );
    canvas.drawLine(
      Offset(center.dx - scanSize / 2, center.dy - scanSize / 2),
      Offset(center.dx - scanSize / 2, center.dy - scanSize / 2 + cornerLength),
      strokePaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(center.dx + scanSize / 2, center.dy - scanSize / 2),
      Offset(center.dx + scanSize / 2 - cornerLength, center.dy - scanSize / 2),
      strokePaint,
    );
    canvas.drawLine(
      Offset(center.dx + scanSize / 2, center.dy - scanSize / 2),
      Offset(center.dx + scanSize / 2, center.dy - scanSize / 2 + cornerLength),
      strokePaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(center.dx - scanSize / 2, center.dy + scanSize / 2),
      Offset(center.dx - scanSize / 2 + cornerLength, center.dy + scanSize / 2),
      strokePaint,
    );
    canvas.drawLine(
      Offset(center.dx - scanSize / 2, center.dy + scanSize / 2),
      Offset(center.dx - scanSize / 2, center.dy + scanSize / 2 - cornerLength),
      strokePaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(center.dx + scanSize / 2, center.dy + scanSize / 2),
      Offset(center.dx + scanSize / 2 - cornerLength, center.dy + scanSize / 2),
      strokePaint,
    );
    canvas.drawLine(
      Offset(center.dx + scanSize / 2, center.dy + scanSize / 2),
      Offset(center.dx + scanSize / 2, center.dy + scanSize / 2 - cornerLength),
      strokePaint,
    );

    // Scan line
    strokePaint.color = color.withOpacity(0.5);
    canvas.drawLine(
      Offset(center.dx - scanSize / 2 + 10, center.dy),
      Offset(center.dx + scanSize / 2 - 10, center.dy),
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(_EmptyStateIllustration oldDelegate) => false;
}
