import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
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
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _commentController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _commentController.removeListener(_onTextChanged);
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _commentController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _onSubmitted(String comment, ForumState state) {
    if (comment.isEmpty) return;
    HapticFeedback.lightImpact();
    final cubit = context.read<ForumCubit>();

    if (state.replyToCommentId != null && state.replyToAuthorName != null) {
      // Submit as reply
      cubit.submitReply(
        widget.forumId,
        state.replyToCommentId!,
        comment,
        state.replyToAuthorName!,
      );
      cubit.clearReplyTarget();
    } else {
      // Submit as regular comment
      final newComment = CommentEntity(
        id: 0,
        post: widget.forumId,
        content: comment,
        author: null,
        createdAt: DateTime.now().toIso8601String(),
      );
      cubit.submitForumComment(newComment);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ForumCubit, ForumState>(
      listenWhen: (previous, current) =>
          previous.lastPostedComment != current.lastPostedComment ||
          previous.commentsError != current.commentsError,
      listener: (context, state) {
        if (state.lastPostedComment != null) {
          context.read<ForumCubit>().fetchForumComments(widget.forumId);
          _commentController.clear();
        }
      },
      builder: (context, state) {
        final isReplying = state.replyToCommentId != null;

        // Focus the text field when replying
        if (isReplying && !_focusNode.hasFocus) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _focusNode.requestFocus();
          });
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reply indicator
            if (isReplying)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  border: Border(
                    top: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.reply_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${state.replyToAuthorName} га жооп берүү',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.read<ForumCubit>().clearReplyTarget();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Input field
            Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom > 0
                    ? 12
                    : MediaQuery.of(context).padding.bottom + 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Text input container
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 120),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(24),
                        border: isReplying
                            ? Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                width: 1.5,
                              )
                            : null,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Emoji button
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 4),
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  Icons.emoji_emotions_outlined,
                                  size: 22,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ),
                          // Text field
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              focusNode: _focusNode,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey.shade800,
                              ),
                              decoration: InputDecoration(
                                hintText: isReplying
                                    ? 'Жооп жазуу...'
                                    : 'Комментарий жазуу...',
                                hintStyle: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade500,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 12,
                                ),
                              ),
                              maxLines: 4,
                              minLines: 1,
                              textInputAction: TextInputAction.newline,
                              textCapitalization: TextCapitalization.sentences,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Send button
                  GestureDetector(
                    onTap: () {
                      final comment = _commentController.text.trim();
                      if (comment.isNotEmpty) {
                        _onSubmitted(comment, state);
                        _commentController.clear();
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _hasText ? AppColors.primary : Colors.grey.shade300,
                        shape: BoxShape.circle,
                        boxShadow: _hasText
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        isReplying ? Icons.reply_rounded : Icons.send_rounded,
                        size: 20,
                        color: _hasText ? Colors.white : Colors.grey.shade500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
