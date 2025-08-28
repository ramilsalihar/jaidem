import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';

class ChatOverViewCard extends StatelessWidget {
  final String profileImageUrl;
  final String name;
  final String date;
  final String messagePreview;
  final VoidCallback? onTap;

  const ChatOverViewCard({
    super.key,
    required this.profileImageUrl,
    required this.name,
    required this.date,
    required this.messagePreview,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.orange,
                          width: 3,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          profileImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.person,
                                color: Colors.grey[600],
                                size: 32,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
        
                const SizedBox(width: 16),
        
                // Chat content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: context.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
        
                          const SizedBox(width: 8),
        
                          Text(
                            date,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
        
                      const SizedBox(height: 4),
        
                      // Message preview
                      Text(
                        messagePreview,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: AppColors.grey
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(color: AppColors.grey)
          ],
        ),
      ),
    );
  }
}
