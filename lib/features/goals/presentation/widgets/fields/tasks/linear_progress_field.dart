import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';

class LinearProgressField extends StatelessWidget {
  const LinearProgressField({
    super.key,
    required this.progress,
    required this.progressColor,
    required this.isExpanded,
    required this.onToggleExpansion,
  });

  final double progress;
  final Color progressColor;
  final bool isExpanded;
  final VoidCallback onToggleExpansion;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: progressColor.withAlpha(20),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 15),
        Text(
          '${(progress * 100).toStringAsFixed(0)}%',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onToggleExpansion,
          child: Icon(
            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: Colors.deepPurple,
          ),
        ),
      ],
    );
  }
}
