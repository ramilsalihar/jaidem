import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/forum/domain/entities/comment_entity.dart';
import 'package:jaidem/features/jaidems/presentation/cubit/jaidems_cubit.dart';
import 'package:jaidem/features/jaidems/presentation/pages/jaidem_detail_page.dart';

class CommentCard extends StatefulWidget {
  const CommentCard({super.key, required this.comment});

  final CommentEntity comment;

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 1) return 'азыр';
      if (diff.inMinutes < 60) return '${diff.inMinutes} мүн';
      if (diff.inHours < 24) return '${diff.inHours} с';
      if (diff.inDays < 7) return '${diff.inDays} күн';
      if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} апт';

      return '${diff.inDays ~/ 30} ай';
    } catch (e) {
      return '';
    }
  }

  Future<void> _navigateToAuthorProfile() async {
    final author = widget.comment.author;
    if (author != null) {
      HapticFeedback.lightImpact();

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const CircularProgressIndicator(),
          ),
        ),
      );

      // Fetch person data
      final person = await context.read<JaidemsCubit>().getJaidemById(author.id);

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Navigate to detail page if person data was fetched
      if (person != null && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => JaidemDetailPage(person: person),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authorName = widget.comment.author?.fullname ?? 'Аноним';
    final hasAvatar = widget.comment.author?.avatar != null &&
        (widget.comment.author!.avatar as String).isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          GestureDetector(
            onTap: _navigateToAuthorProfile,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  width: 1.5,
                ),
              ),
              child: ClipOval(
                child: hasAvatar
                    ? Image.network(
                        widget.comment.author!.avatar,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _buildDefaultAvatar(authorName),
                      )
                    : _buildDefaultAvatar(authorName),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Comment bubble
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Comment content bubble
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Author name
                      GestureDetector(
                        onTap: _navigateToAuthorProfile,
                        child: Text(
                          authorName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      // Comment text
                      Text(
                        widget.comment.content,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                // Actions row
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Row(
                    children: [
                      // Time
                      Text(
                        _formatDate(widget.comment.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Like action
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                        },
                        child: Text(
                          'Жактырдым',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Reply action
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                        },
                        child: Text(
                          'Жооп',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'A';
    return Container(
      color: AppColors.primary.shade200,
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
