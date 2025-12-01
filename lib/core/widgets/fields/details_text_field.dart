import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';

class DetailsTextField extends StatelessWidget {
  const DetailsTextField({
    super.key,
    required this.label,
    required this.value,
    this.labelStyle,
    this.valueStyle,
    this.hasSpace = false,
    this.labelWidth,
  });

  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final bool hasSpace;
  final double? labelWidth;

  @override
  Widget build(BuildContext context) {
    final defaultLabelStyle = labelStyle ??
        context.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.grey,
        );

    final defaultValueStyle = valueStyle ??
        context.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w400,
          color: Colors.grey,
        );

    if (hasSpace) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth ?? 120,
            child: Text(
              label,
              style: defaultLabelStyle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: defaultValueStyle,
            ),
          ),
        ],
      );
    }

    return Text(
      value,
      style: defaultValueStyle,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
