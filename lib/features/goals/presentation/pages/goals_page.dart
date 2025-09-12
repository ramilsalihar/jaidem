import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/goals/presentation/widgets/buttons/goal_add_button.dart';
import 'package:jaidem/features/notifications/presentation/pages/notification_mixin.dart';

@RoutePage()
class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> with NotificationMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leadingWidth: 40,
        backgroundColor: AppColors.backgroundColor,
        leading: GestureDetector(
          onTap: () => _scaffoldKey.currentState?.openDrawer(),
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Image.asset(
              'assets/icons/menu.png',
              color: AppColors.primary,
              height: 24,
            ),
          ),
        ),
        title: Text(
          'Мои цели',
          style: context.textTheme.headlineMedium,
        ),
        actions: [
          GestureDetector(
            onTap: () => showNotificationPopup(),
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Image.asset(
                'assets/icons/notification.png',
                color: AppColors.primary,
                height: 24,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Image.asset(
              'assets/images/goals_empty.png',
              width: size.width * 0.8,
            ),
            const SizedBox(height: 16),
            const GoalAddButton()
          ],
        ),
      ),
    );
  }
}
