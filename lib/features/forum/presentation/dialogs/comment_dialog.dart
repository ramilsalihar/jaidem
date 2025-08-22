import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/forum/presentation/widgets/cards/comment_card.dart';
import 'package:jaidem/features/forum/presentation/widgets/fields/comment_chat_field.dart';

class Comment {
  final String id;
  final String authorName;
  final String authorAvatar;
  final String message;
  final DateTime timestamp;
  final bool isOnline;

  Comment({
    required this.id,
    required this.authorName,
    required this.authorAvatar,
    required this.message,
    required this.timestamp,
    this.isOnline = false,
  });
}

mixin CommentDialog<T extends StatefulWidget> on State<T> {
  final ScrollController _scrollController = ScrollController();

  List<Comment> getComments();

  void showCommentBottomSheet({
    double initialChildSize = 0.7,
    double minChildSize = 0.3,
    double maxChildSize = 0.95,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: initialChildSize,
        minChildSize: minChildSize,
        maxChildSize: maxChildSize,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                height: 6,
                width: 50,
                decoration: BoxDecoration(
                  color: AppColors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 30),

              // Comments list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: getComments().length,
                  itemBuilder: (context, index) {
                    final comment = getComments()[index];
                    return CommentCard(comment: comment);
                  },
                ),
              ),

              // Comment input
              CommentChatField()
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
