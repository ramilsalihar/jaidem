import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/forum/presentation/dialogs/comment_dialog.dart';
import 'package:jaidem/features/forum/presentation/widgets/buttons/forum_button.dart';

const double spaceBetweenButtons = 25.0;

class ForumDetails extends StatefulWidget {
  const ForumDetails({
    super.key,
    this.likesCount,
  });

  final int? likesCount;

  @override
  State<ForumDetails> createState() => _ForumDetailsState();
}

class _ForumDetailsState extends State<ForumDetails> with CommentDialog {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ForumButton(
            icon: 'assets/icons/heart.png',
            count: widget.likesCount,
          ),
          const SizedBox(width: spaceBetweenButtons),
          ForumButton(
              icon: 'assets/icons/chat.png',
              onTap: () {
                showCommentBottomSheet(forumId: 1);
              }),
          const SizedBox(width: spaceBetweenButtons),
          ForumButton(icon: 'assets/icons/share.png'),
        ],
      ),
    );
  }
}
