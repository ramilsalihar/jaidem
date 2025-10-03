import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/features/goals/data/models/goal_model.dart';
import 'package:jaidem/features/goals/presentation/widgets/goal/goal_detail_row.dart';

class GoalExpandedContent extends StatelessWidget {
  final GoalModel goal;

  const GoalExpandedContent({
    super.key,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GoalDetailRow(
            label: 'Категория:',
            value: goal.category?.toString() ?? 'Учеба',
          ),
          const SizedBox(height: 8),
          GoalDetailRow(
            label: 'Частота:',
            value: goal.frequency ?? 'Каждый день',
          ),
          const SizedBox(height: 8),
          GoalDetailRow(
            label: 'Напоминание:',
            value: goal.reminder ?? '09:00',
          ),
          if (goal.description != null) ...[
            const SizedBox(height: 12),
            Text(
              'Описание:',
              style: context.textTheme.titleSmall?.copyWith(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              goal.description!,
              style: context.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
