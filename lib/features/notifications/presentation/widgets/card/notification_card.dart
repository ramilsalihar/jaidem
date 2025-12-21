import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/notifications/data/models/notification_model.dart';
import 'package:jaidem/features/notifications/data/services/notification_helper.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({super.key, required this.item});

  final NotificationModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: item.isRead ? Colors.grey.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isRead
              ? Colors.grey.shade200
              : AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: item.isRead
            ? null
            : [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: item.isRead
                  ? Colors.grey.shade100
                  : AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getNotificationIcon(),
              size: 22,
              color: item.isRead ? Colors.grey.shade400 : AppColors.primary,
            ),
          ),

          const SizedBox(width: 14),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Message
                Text(
                  item.message,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: item.isRead ? FontWeight.w400 : FontWeight.w500,
                    color:
                        item.isRead ? Colors.grey.shade600 : Colors.grey.shade800,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 8),

                // Time and status
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getFormattedDate(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (!item.isRead) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Жаңы',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Unread indicator
          if (!item.isRead)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(left: 8, top: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  IconData _getNotificationIcon() {
    final message = item.message.toLowerCase();

    if (message.contains('иш-чара') || message.contains('event')) {
      return Icons.event_rounded;
    } else if (message.contains('максат') || message.contains('goal')) {
      return Icons.flag_rounded;
    } else if (message.contains('жаңылык') || message.contains('news')) {
      return Icons.article_rounded;
    } else if (message.contains('билдирүү') || message.contains('message')) {
      return Icons.message_rounded;
    } else if (message.contains('эсеп') || message.contains('account')) {
      return Icons.person_rounded;
    }

    return Icons.notifications_rounded;
  }

  String _getFormattedDate() {
    try {
      final dateTime = DateTime.parse(item.createdAt);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Азыр эле';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} мүнөт мурун';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} саат мурун';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} күн мурун';
      } else {
        return NotificationLocalHelper.dateFormat(item.createdAt);
      }
    } catch (_) {
      return item.createdAt;
    }
  }
}
