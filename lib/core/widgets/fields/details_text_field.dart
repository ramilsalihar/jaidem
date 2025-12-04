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
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final bool hasSpace;
  final double? labelWidth;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final defaultLabelStyle = labelStyle ??
        context.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.grey,
        );

    final defaultValueStyle = valueStyle ??
        context.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w400,
          color: Colors.grey,
        );

    if (hasSpace) {
      return Row(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          // Label with fixed width or flexible
          if (labelWidth != null)
            SizedBox(
              width: labelWidth,
              child: Text(
                label,
                style: defaultLabelStyle,
              ),
            )
          else
            Text(
              label,
              style: defaultLabelStyle,
            ),
          
          const SizedBox(width: 8),
          
          // Value takes remaining space and can expand
          Expanded(
            child: Text(
              value,
              style: defaultValueStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Text(
      value,
      maxLines: 2,
      style: defaultValueStyle,
    );
  }
}