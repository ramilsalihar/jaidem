import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';

class MenuButton extends StatelessWidget {
  const MenuButton({
    super.key,
    required this.title,
    required this.onTap,
    this.leadingIcon,
    this.iconData,
    this.trailing,
    this.onTrailingPressed,
    this.iconColor,
    this.iconBackgroundColor,
  });

  final String title;
  final VoidCallback onTap;
  final String? leadingIcon;
  final IconData? iconData;
  final Widget? trailing;
  final VoidCallback? onTrailingPressed;
  final Color? iconColor;
  final Color? iconBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (onTrailingPressed != null) {
          onTrailingPressed!();
        } else {
          onTap();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container with gradient background
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    iconBackgroundColor ?? AppColors.primary.shade100,
                    iconBackgroundColor?.withValues(alpha: 0.7) ??
                        AppColors.primary.shade50,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: iconData != null
                    ? Icon(
                        iconData,
                        size: 22,
                        color: iconColor ?? AppColors.primary,
                      )
                    : leadingIcon != null
                        ? Image.asset(
                            leadingIcon!,
                            height: 22,
                            color: iconColor ?? AppColors.primary,
                          )
                        : Icon(
                            Icons.circle,
                            size: 22,
                            color: iconColor ?? AppColors.primary,
                          ),
              ),
            ),
            const SizedBox(width: 14),
            // Title
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                  letterSpacing: -0.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            // Trailing widget or arrow
            trailing ??
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.grey.shade400,
                    size: 14,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
