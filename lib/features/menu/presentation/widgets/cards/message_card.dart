import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/menu/data/models/message_model.dart';

class MessageCard extends StatelessWidget {
  const MessageCard({super.key, required this.message, required this.currentUserId});

  final MessageModel message;
  final String currentUserId;

  bool get isMe => message.senderId == currentUserId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            // Avatar for received messages
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8, top: 4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
              child: const Icon(
                Icons.person_outline,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],

          // Message bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color:
                    isMe ? AppColors.lightGrey : AppColors.barColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message.text,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: isMe ? AppColors.primary : Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
          ),

          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
