import 'package:flutter/material.dart';
import '../services/steps_service.dart';

class StepsWidget extends StatefulWidget {
  final int stepGoal;

  const StepsWidget({super.key, this.stepGoal = 10000});

  @override
  State<StepsWidget> createState() => _StepsWidgetState();
}

class _StepsWidgetState extends State<StepsWidget> {
  int _steps = 0;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _initStepTracking();
  }

  Future<void> _initStepTracking() async {
    final granted = await StepsService.requestPermissions();

    if (granted) {
      StepsService.initPedometer();
      setState(() => _hasPermission = true);

      // Update UI every second
      Future.delayed(const Duration(seconds: 1), _updateSteps);
    }
  }

  void _updateSteps() {
    if (!mounted) return;
    setState(() {
      _steps = StepsService.getTodaySteps();
    });
    Future.delayed(const Duration(seconds: 2), _updateSteps);
  }

  @override
  Widget build(BuildContext context) {
    final progress = StepsService.getStepProgress(_steps, widget.stepGoal);
    final calories = StepsService.getCaloriesFromSteps(_steps);

    return Card(
      elevation: 0,
      child: InkWell(
        onTap: !_hasPermission
            ? () async {
                final granted = await StepsService.requestPermissions();
                if (granted) {
                  _initStepTracking();
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please grant permission to track steps'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              }
            : null,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.shade400,
                          Colors.deepOrange.shade600,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.directions_walk,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Steps Today',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (!_hasPermission)
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Tap to enable step tracking',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _steps.toString(),
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()
                              ..shader =
                                  LinearGradient(
                                    colors: [
                                      Colors.orange.shade400,
                                      Colors.deepOrange.shade600,
                                    ],
                                  ).createShader(
                                    const Rect.fromLTWH(0, 0, 200, 70),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            '/ ${widget.stepGoal}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(
                          progress >= 1.0 ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(progress * 100).toInt()}% of goal',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        Text(
                          '~${calories.toInt()} cal burned',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
