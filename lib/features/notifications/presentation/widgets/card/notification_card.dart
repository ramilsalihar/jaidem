import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/notifications/data/models/notification_model.dart';
import 'package:jaidem/features/notifications/data/services/notification_helper.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({super.key, required this.item});

  final NotificationModel item;

  @override
  Widget build(BuildContext context) {
    if (item.isRead) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary.shade300,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(
              NotificationLocalHelper.dateFormat(item.createdAt),
              style: context.textTheme.headlineMedium!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.message,
                style: context.textTheme.bodyMedium!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            NotificationLocalHelper.dateFormat(item.createdAt),
            style: context.textTheme.bodyMedium!.copyWith(
              color: const Color(0xFF7E57C2),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.message,
              style: context.textTheme.bodyMedium!.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
