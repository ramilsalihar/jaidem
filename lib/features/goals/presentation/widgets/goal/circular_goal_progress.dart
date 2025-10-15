import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'dart:math' as math;

import 'package:jaidem/core/utils/style/app_colors.dart';

class CircularGoalProgress extends StatelessWidget {
  final double progress;

  const CircularGoalProgress({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    print('Rendering CircularGoalProgress with progress: $progress');

    // Normalize progress: if it's > 1.0, treat it as percentage (e.g., 75.0 = 75%)
    // if it's <= 1.0, treat it as fraction (e.g., 0.75 = 75%)
    final normalizedProgress = progress > 1.0 ? progress / 100.0 : progress;
    final displayPercentage = (normalizedProgress * 100).toInt();

    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        children: [
          CustomPaint(
            size: const Size(80, 80),
            painter: _CircularProgressPainter(
              progress: normalizedProgress,
              backgroundColor: AppColors.warning,
              progressColor: normalizedProgress < 1
                  ? AppColors.secondary
                  : AppColors.green,
              accentColor: normalizedProgress < 1
                  ? AppColors.secondary
                  : AppColors.green,
            ),
          ),
          Center(
            child: Text(
              '$displayPercentage%',
              style: context.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final Color accentColor;

  _CircularProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const backgroundStrokeWidth = 6.0;
    const progressStrokeWidth = 10.0;

    // Background circle (inactive part)
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = backgroundStrokeWidth;

    canvas.drawCircle(
        center, radius - progressStrokeWidth / 2, backgroundPaint);

    // Progress arc (active part)
    if (progress > 0) {
      final progressPaint = Paint()
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: -math.pi / 2 + (2 * math.pi * progress),
          colors: [accentColor, progressColor],
          stops: const [0.0, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = progressStrokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(
            center: center, radius: radius - progressStrokeWidth / 2),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
