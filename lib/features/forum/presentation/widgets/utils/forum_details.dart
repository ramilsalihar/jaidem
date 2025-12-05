import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/forum/presentation/dialogs/comment_dialog.dart';
import 'package:jaidem/features/forum/presentation/widgets/buttons/forum_button.dart';

const double spaceBetweenButtons = 25.0;

class ForumDetails extends StatefulWidget {
  const ForumDetails({
    super.key,
    this.likesCount,
    required this.forumId,
    required this.isLiked,
    required this.onLikeTap,
  });

  final int? likesCount;
  final int forumId;
  final bool isLiked;
  final VoidCallback onLikeTap;

  @override
  State<ForumDetails> createState() => _ForumDetailsState();
}

class _ForumDetailsState extends State<ForumDetails> with CommentDialog {
  bool isLiked = false;
  int likesCount = 0;

  @override
  void initState() {
    isLiked = widget.isLiked;
    likesCount = widget.likesCount ?? 0;
    super.initState();
  }

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
            icon: isLiked
                ? 'assets/icons/heart_filled.png'
                : 'assets/icons/heart.png',
            count: likesCount,
            onTap: () {
              widget.onLikeTap();
              setState(() {
                isLiked = !isLiked;
                likesCount += isLiked ? 1 : -1;
              });
            },
          ),
          const SizedBox(width: spaceBetweenButtons),
          ForumButton(
              icon: 'assets/icons/chat.png',
              onTap: () {
                showCommentBottomSheet(forumId: widget.forumId);
              }),
          const SizedBox(width: spaceBetweenButtons),
          // ForumButton(icon: 'assets/icons/share.png'),
        ],
      ),
    );
  }
}
