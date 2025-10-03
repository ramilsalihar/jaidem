import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';

class GoalDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const GoalDetailRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: context.textTheme.titleSmall?.copyWith(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: context.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
