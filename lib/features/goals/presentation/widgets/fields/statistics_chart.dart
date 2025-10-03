import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/features/goals/presentation/helpers/statistics_data_provider.dart';
import 'package:jaidem/features/goals/presentation/widgets/fields/statistics_bar.dart';

class StatisticsChart extends StatelessWidget {
  final String mode;

  const StatisticsChart({
    super.key,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    final labels = StatisticsDataProvider.getLabelsForMode(mode);
    final data = StatisticsDataProvider.getMockDataForMode(mode);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(
            labels.length,
            (index) => Expanded(
              child: StatisticsBar(
                completed: data[index]['completed']!,
                inProgress: data[index]['inProgress']!,
                notStarted: data[index]['notStarted']!,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildLabels(labels, context),
      ],
    );
  }

  Widget _buildLabels(List<String> labels, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: labels.map((label) => Expanded(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: context.textTheme.labelMedium?.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w300,
          ),
        ),
      )).toList(),
    );
  }
}
