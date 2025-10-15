import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';

class DeadlineField extends StatelessWidget {
  const DeadlineField({super.key, required this.endTime});

  final String endTime;

  @override
  Widget build(BuildContext context) {
    final formattedTime = endTime.substring(0, 5);

    return Text(
      'Срок до $formattedTime',
      style: context.textTheme.labelLarge?.copyWith(
        color: Colors.grey[600],
      ),
    );
  }
}
