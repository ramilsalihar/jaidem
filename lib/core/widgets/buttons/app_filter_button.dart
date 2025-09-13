import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';

class AppFilterButton extends StatelessWidget {
  const AppFilterButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 45,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(60),
        ),
        child: Image.asset(
          'assets/icons/filter.png',
          height: 24,
        ),
      ),
    );
  }
}
