import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/forum/presentation/widgets/cards/comment_card.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/features/forum/presentation/cubit/forum_cubit.dart';
import 'package:jaidem/features/forum/presentation/widgets/fields/comment_chat_field.dart';

mixin CommentDialog<T extends StatefulWidget> on State<T> {
  final ScrollController _scrollController = ScrollController();

  void showCommentBottomSheet({
    required int forumId,
    double initialChildSize = 0.7,
    double minChildSize = 0.3,
    double maxChildSize = 0.95,
  }) {
    // Trigger fetch comments before showing
    context.read<ForumCubit>().fetchForumComments(forumId);
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
                child: BlocBuilder<ForumCubit, ForumState>(
                  builder: (context, state) {
                    if (state.isCommentsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state.commentsError != null) {
                      return Center(child: Text('Error: \\${state.commentsError}'));
                    } else if (state.comments.isEmpty) {
                      return const Center(child: Text('No comments yet.'));
                    }
                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.comments.length,
                      itemBuilder: (context, index) {
                        final comment = state.comments[index];
                        return CommentCard(comment: comment);
                      },
                    );
                  },
                ),
              ),

              // Comment input
              CommentChatField(
                forumId: forumId,
              )
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
