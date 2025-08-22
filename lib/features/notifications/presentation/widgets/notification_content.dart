import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/notifications/data/models/notification_model.dart';
import 'package:jaidem/features/notifications/presentation/widgets/card/notification_card.dart';

class NotificationContent extends StatelessWidget {
  final List<NotificationModel> notifications;

  const NotificationContent({
    super.key,
    required this.notifications,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: notifications.length,
              padding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 10,
              ),
              separatorBuilder: (_, __) => const Divider(
                color: AppColors.lightGrey,
                height: 20,
              ),
              itemBuilder: (_, index) {
                final item = notifications[index];
                return NotificationCard(item: item);
              },
            ),
          ),
        ],
      ),
    );
  }
}
