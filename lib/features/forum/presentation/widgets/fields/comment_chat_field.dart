import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/features/forum/domain/entities/comment_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/features/forum/presentation/cubit/forum_cubit.dart';

class CommentChatField extends StatefulWidget {
  final int forumId;
  const CommentChatField({super.key, required this.forumId});

  @override
  State<CommentChatField> createState() => _CommentChatFieldState();
}

class _CommentChatFieldState extends State<CommentChatField> {
  final TextEditingController _commentController = TextEditingController();

  void onCommentSubmitted(String comment) {
    final cubit = context.read<ForumCubit>();
    final newComment = CommentEntity(
      id: 0, // or null/auto if your backend assigns it
      post: widget.forumId,
      content: comment,
      author: null, // Set author if needed
      createdAt: DateTime.now().toIso8601String(),
    );
    cubit.submitForumComment(newComment);
  }

  void onCommentAction(CommentEntity comment, String action) {
    
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ForumCubit, ForumState>(
      listenWhen: (previous, current) =>
          previous.lastPostedComment != current.lastPostedComment ||
          previous.commentsError != current.commentsError,
      listener: (context, state) {
        if (state.lastPostedComment != null) {
          context.read<ForumCubit>().fetchForumComments(widget.forumId);
          _commentController.clear();
        }
      },
      child: Container(
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
            // IconButton(
            //   icon: const Icon(Icons.emoji_emotions_outlined),
            //   onPressed: () {
            //     // Handle emoji picker
            //   },
            // ),

            // Text input
            Expanded(
              child: TextField(
                controller: _commentController,
                style: context.textTheme.bodyMedium,
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

            // GestureDetector(
            //   onTap: () {},
            //   child: Image.asset(
            //     'assets/icons/tag.png',
            //     width: 24,
            //     height: 24,
            //   ),
            // ),
            // const SizedBox(width: 8),
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
      ),
    );
  }
}
