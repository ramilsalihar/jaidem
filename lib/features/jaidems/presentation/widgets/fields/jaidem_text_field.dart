import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';

class JaidemTextField extends StatelessWidget {
  const JaidemTextField({
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
    if (hasSpace) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth ?? 120, 
            child: Text(
              label,
              style: labelStyle ??
                  context.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey,
                  ),
            ),
          ),
          const SizedBox(width: 8), 
          Expanded(
            child: Text(
              value,
              style: valueStyle ??
                  context.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
            ),
          ),
        ],
      );
    }

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textHeightBehavior: TextHeightBehavior(
        applyHeightToFirstAscent: false,
        applyHeightToLastDescent: false,
      ),
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: [
          TextSpan(
            text: label,
            style: labelStyle ??
                context.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey,
                ),
          ),
          const TextSpan(text: ' '),
          TextSpan(
            text: value,
            style: valueStyle ??
                context.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
          ),
        ],
      ),
    );
  }
}
