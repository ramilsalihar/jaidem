import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';

class ForumButton extends StatelessWidget {
  const ForumButton({
    super.key,
    required this.icon,
    this.count,
    this.onTap,
  });

  final String icon;
  final int? count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Image.asset(
            icon,
            height: 20,
            color: Colors.grey,
          ),
          if (count != null) ...[
            const SizedBox(width: 5),
            Text(
              '$count',
              style: context.textTheme.headlineSmall,
            ),
          ]
        ],
      ),
    );
  }
}
