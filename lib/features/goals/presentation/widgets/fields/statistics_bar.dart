import 'package:flutter/material.dart';

class StatisticsBar extends StatelessWidget {
  final int completed;
  final int inProgress;
  final int notStarted;

  static const double barWidth = 8;
  static const double spacing = 2;
  static const double unitHeight = 15;

  const StatisticsBar({
    super.key,
    required this.completed,
    required this.inProgress,
    required this.notStarted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildBarSegment(
          height: completed * unitHeight,
          color: Colors.green,
        ),
        const SizedBox(height: spacing),
        _buildBarSegment(
          height: inProgress * unitHeight,
          color: Colors.amber,
        ),
        const SizedBox(height: spacing),
        _buildBarSegment(
          height: notStarted * unitHeight,
          color: Colors.red.shade400,
        ),
      ],
    );
  }

  Widget _buildBarSegment({
    required double height,
    required Color color,
  }) {
    return Container(
      width: barWidth,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
    );
  }
}
