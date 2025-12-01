import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:jaidem/core/routes/app_router.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';

class GoalAddButton extends StatelessWidget {
  const GoalAddButton({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return InkWell(
      onTap: () {
        context.router.push(const AddGoalRoute());
      },
      child: Container(
        height: 150,
        width: size.width,
        decoration: BoxDecoration(
          color: AppColors.primary.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/goal_add.png',
              width: 50,
            ),
            const SizedBox(height: 15),
            Text(
              'Максат кошуу',
              style: context.textTheme.headlineMedium?.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        )),
      ),
    );
  }
}
