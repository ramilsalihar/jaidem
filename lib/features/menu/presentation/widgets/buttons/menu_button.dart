import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';

class MenuButton extends StatelessWidget {
  const MenuButton({
    super.key,
    required this.title,
    required this.onTap,
    required this.leadingIcon,
    this.trailing,
    this.onTrailingPressed,
  });

  final String title;
  final VoidCallback onTap;
  final String leadingIcon;
  final Widget? trailing;
  final VoidCallback? onTrailingPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTrailingPressed ?? onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        margin: const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 16,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            Image.asset(
              leadingIcon,
              height: 24,
              color: Colors.black87,
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: context.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w100,
                color: Colors.black87
              ),
            ),
            const Spacer(),
            trailing ??
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.primary.shade400,
                  size: 16,
                ),
          ],
        ),
      ),
    );
  }
}
