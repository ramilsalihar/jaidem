import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/forum/presentation/dialogs/comment_dialog.dart';
import 'package:jaidem/features/forum/presentation/widgets/buttons/forum_button.dart';

const double spaceBetweenButtons = 25.0;

class ForumDetails extends StatefulWidget {
  const ForumDetails({super.key});

  @override
  State<ForumDetails> createState() => _ForumDetailsState();
}

class _ForumDetailsState extends State<ForumDetails> with CommentDialog{
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
          ForumButton(icon: 'assets/icons/heart.png', count: 24),
          const SizedBox(width: spaceBetweenButtons),
          ForumButton(icon: 'assets/icons/chat.png', count: 120, onTap: () {
            showCommentBottomSheet();
          }),
          const SizedBox(width: spaceBetweenButtons),
          ForumButton(icon: 'assets/icons/share.png', count: 120),
        ],
      ),
    );
  }
  
  @override
  List<Comment> getComments() {
    return [
      Comment(
        id: '1',
        authorName: 'User 1',
        authorAvatar: 'https://example.com/avatar1.png',
        message: 'This is a comment from User 1',
        timestamp: DateTime.now().subtract(Duration(minutes: 5)),
        isOnline: true,
      ),
      Comment(
        id: '2',
        authorName: 'User 2',
        authorAvatar: 'https://example.com/avatar2.png',
        message: 'This is a comment from User 2',
        timestamp: DateTime.now().subtract(Duration(minutes: 10)),
      ),
      Comment(
        id: '3',
        authorName: 'User 3',
        authorAvatar: 'https://example.com/avatar3.png',
        message: 'This is a comment from User 3',
        timestamp: DateTime.now().subtract(Duration(minutes: 15)),
        isOnline: true,
      ),
    ];
  }
}
