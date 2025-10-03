import 'package:flutter/material.dart';
import 'package:jaidem/features/goals/presentation/widgets/fields/statistics_chart.dart';
import 'package:jaidem/features/goals/presentation/widgets/fields/statistics_legend.dart';

class StatisticsView extends StatelessWidget {
  final String mode;

  const StatisticsView({
    super.key,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          StatisticsChart(mode: mode),
          const SizedBox(height: 24),
          const StatisticsLegend(),
        ],
      ),
    );
  }
}
