import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';

class AppFilterButton extends StatelessWidget {
  const AppFilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Handle filter button tap
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
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
