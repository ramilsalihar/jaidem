import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/features/forum/presentation/dialogs/comment_dialog.dart';

class CommentChatField extends StatefulWidget {
  const CommentChatField({super.key});

  @override
  State<CommentChatField> createState() => _CommentChatFieldState();
}

class _CommentChatFieldState extends State<CommentChatField> {
  final TextEditingController _commentController = TextEditingController();

  void onCommentSubmitted(String comment) {
    // Default implementation - override in your widget
    print('New comment: $comment');
  }

  void onCommentAction(Comment comment, String action) {
    // Default implementation - override in your widget
    print('Action $action on comment: ${comment.id}');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: kToolbarHeight,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.emoji_emotions_outlined),
            onPressed: () {
              // Handle emoji picker
            },
          ),

          // Text input
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Комментарии...',
                hintStyle: context.textTheme.bodyMedium,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 5,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  onCommentSubmitted(value.trim());
                  _commentController.clear();
                }
              },
            ),
          ),

          GestureDetector(
            onTap: () {},
            child: Image.asset(
              'assets/icons/tag.png',
              width: 24,
              height: 24,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              final comment = _commentController.text.trim();
              if (comment.isNotEmpty) {
                onCommentSubmitted(comment);
                _commentController.clear();
              }
            },
            child: Image.asset(
              'assets/icons/sent_straight.png',
              width: 24,
              height: 24,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
