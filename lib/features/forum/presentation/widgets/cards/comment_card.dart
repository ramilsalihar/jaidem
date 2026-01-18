import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/forum/domain/entities/comment_entity.dart';
import 'package:jaidem/features/forum/presentation/cubit/forum_cubit.dart';
import 'package:jaidem/features/jaidems/presentation/cubit/jaidems_cubit.dart';
import 'package:jaidem/features/jaidems/presentation/pages/jaidem_detail_page.dart';

class CommentCard extends StatefulWidget {
  const CommentCard({
    super.key,
    required this.comment,
    required this.forumId,
    this.isReply = false,
  });

  final CommentEntity comment;
  final int forumId;
  final bool isReply;

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> with SingleTickerProviderStateMixin {
  bool _isLiked = false;
  int _likesCount = 0;
  late AnimationController _likeAnimationController;
  late Animation<double> _likeScaleAnimation;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.comment.isLikedByCurrentUser;
    _likesCount = widget.comment.likesCount;

    _likeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _likeScaleAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(
        parent: _likeAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    super.dispose();
  }

  // Helper to safely get author properties (handles both Map and object types)
  String? _getAuthorProperty(String key, [dynamic author]) {
    final authorData = author ?? widget.comment.author;
    if (authorData == null) return null;

    if (authorData is Map<String, dynamic>) {
      return authorData[key]?.toString();
    } else {
      // Handle legacy object-style author
      try {
        switch (key) {
          case 'fullname':
            return (authorData as dynamic).fullname;
          case 'avatar':
            return (authorData as dynamic).avatar;
          case 'id':
            return (authorData as dynamic).id?.toString();
          default:
            return null;
        }
      } catch (_) {
        return null;
      }
    }
  }

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
    final authorId = _getAuthorProperty('id');
    if (authorId != null) {
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
      final person = await context.read<JaidemsCubit>().getJaidemById(int.tryParse(authorId) ?? 0);

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

  Future<void> _handleLike() async {
    final documentId = widget.comment.documentId;
    if (documentId == null) return;

    HapticFeedback.lightImpact();

    // Optimistic update
    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
    });

    _likeAnimationController.forward().then((_) {
      _likeAnimationController.reverse();
    });

    // Toggle like in Firebase
    final isNowLiked = await context.read<ForumCubit>().toggleCommentLike(
      widget.forumId,
      documentId,
    );

    // If the result doesn't match our optimistic update, correct it
    if (mounted && isNowLiked != _isLiked) {
      final likeInfo = await context.read<ForumCubit>().getCommentLikeInfo(
        widget.forumId,
        documentId,
      );
      setState(() {
        _isLiked = likeInfo['isLiked'] as bool;
        _likesCount = likeInfo['count'] as int;
      });
    }
  }

  void _handleReply() {
    HapticFeedback.lightImpact();
    final authorName = _getAuthorProperty('fullname') ?? 'Аноним';
    final documentId = widget.comment.documentId;

    if (documentId != null) {
      context.read<ForumCubit>().setReplyTarget(documentId, authorName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authorName = _getAuthorProperty('fullname') ?? 'Аноним';
    final authorAvatar = _getAuthorProperty('avatar');
    final hasAvatar = authorAvatar != null && authorAvatar.isNotEmpty;
    final hasReplies = widget.comment.replies.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(
        bottom: 12,
        left: widget.isReply ? 46 : 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              GestureDetector(
                onTap: _navigateToAuthorProfile,
                child: Container(
                  width: widget.isReply ? 28 : 36,
                  height: widget.isReply ? 28 : 36,
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
                            authorAvatar,
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
                              style: TextStyle(
                                fontSize: widget.isReply ? 12 : 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          // Reply indicator
                          if (widget.comment.parentAuthorName != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.reply_rounded,
                                    size: 12,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.comment.parentAuthorName!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 3),
                          // Comment text
                          Text(
                            widget.comment.content,
                            style: TextStyle(
                              fontSize: widget.isReply ? 13 : 14,
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
                            onTap: _handleLike,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ScaleTransition(
                                  scale: _likeScaleAnimation,
                                  child: Icon(
                                    _isLiked
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    size: 14,
                                    color: _isLiked
                                        ? Colors.red
                                        : Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _likesCount > 0
                                      ? '$_likesCount'
                                      : 'Жактырдым',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _isLiked
                                        ? Colors.red
                                        : Colors.grey.shade600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Reply action (only for parent comments)
                          if (!widget.isReply)
                            GestureDetector(
                              onTap: _handleReply,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.reply_rounded,
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Жооп',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w600,
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
              ),
            ],
          ),

          // Replies
          if (hasReplies)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                children: widget.comment.replies.map((reply) {
                  return CommentCard(
                    comment: reply,
                    forumId: widget.forumId,
                    isReply: true,
                  );
                }).toList(),
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
          style: TextStyle(
            color: Colors.white,
            fontSize: widget.isReply ? 11 : 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
