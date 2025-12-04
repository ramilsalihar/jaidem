import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/features/forum/domain/entities/comment_entity.dart';

class CommentCard extends StatelessWidget {
  const CommentCard({super.key, required this.comment});

  final CommentEntity comment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar with online indicator
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[300],
                child: (comment.author != null &&
                        comment.author!.avatar != null &&
                        (comment.author!.avatar as String).isNotEmpty)
                    ? ClipOval(
                        child: Image.network(
                          comment.author!.avatar,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.person, color: Colors.grey[600]),
                        ),
                      )
                    : Icon(Icons.person, color: Colors.grey[600]),
              ),
            ],
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.author != null ? comment.author!.fullname : 'Аноним',
                  style: context.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
