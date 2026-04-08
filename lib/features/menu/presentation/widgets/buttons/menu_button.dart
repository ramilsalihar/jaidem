import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBackgroundColor ?? Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: iconData != null
                    ? Icon(iconData, size: 20, color: iconColor ?? Colors.grey.shade700)
                    : leadingIcon != null
                        ? Image.asset(leadingIcon!, height: 20, color: iconColor ?? Colors.grey.shade700)
                        : Icon(Icons.circle, size: 20, color: iconColor ?? Colors.grey.shade700),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
                softWrap: true,
                maxLines: 2,
                overflow: TextOverflow.visible,
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ] else
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade300,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
