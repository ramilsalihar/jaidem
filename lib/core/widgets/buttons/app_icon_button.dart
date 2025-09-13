import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        // height: 35,
        // width: 35,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 20,
          color: AppColors.primary.shade300,
        ),
      ),
    );
  }
}
