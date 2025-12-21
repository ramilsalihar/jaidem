import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/core/utils/constants/app_constants.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/forum/domain/entities/forum_entity.dart';
import 'package:jaidem/features/forum/presentation/cubit/forum_cubit.dart';
import 'package:jaidem/features/forum/presentation/dialogs/comment_dialog.dart';

class ForumCard extends StatefulWidget {
  const ForumCard({super.key, required this.forum});

  final ForumEntity forum;

  @override
  State<ForumCard> createState() => _ForumCardState();
}

class _ForumCardState extends State<ForumCard>
    with SingleTickerProviderStateMixin, CommentDialog {
  bool _expanded = false;
  bool _isLiked = false;
  int _likesCount = 0;
  late AnimationController _likeAnimationController;
  late Animation<double> _likeScaleAnimation;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.forum.isLikedByCurrentUser;
    _likesCount = widget.forum.likesCount ?? 0;

    _likeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _likeScaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
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

  void _handleLike() {
    HapticFeedback.lightImpact();
    context.read<ForumCubit>().likeForumPost(widget.forum.id);
    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
    });
    _likeAnimationController.forward().then((_) {
      _likeAnimationController.reverse();
    });
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 1) return 'азыр';
      if (diff.inMinutes < 60) return '${diff.inMinutes} мүн. мурун';
      if (diff.inHours < 24) return '${diff.inHours} саат мурун';
      if (diff.inDays < 7) return '${diff.inDays} күн мурун';

      return '${date.day}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.forum.content ?? '';
    final isLongContent = content.length > 120;
    final displayContent =
        _expanded ? content : (isLongContent ? content.substring(0, 120) : content);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author header
          _buildAuthorHeader(),

          // Image
          _buildImage(),

          // Content & Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Actions row
                _buildActionsRow(),

                const SizedBox(height: 12),

                // Likes count
                if (_likesCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '$_likesCount жакты',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                // Content
                if (content.isNotEmpty) ...[
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                        height: 1.4,
                      ),
                      children: [
                        if (widget.forum.author != null)
                          TextSpan(
                            text: '${widget.forum.author!.fullname} ',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        TextSpan(text: displayContent),
                        if (isLongContent)
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () => setState(() => _expanded = !_expanded),
                              child: Text(
                                _expanded ? ' азыраак' : '...дагы',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],

                // Date
                if (widget.forum.createdAt != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _formatDate(widget.forum.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorHeader() {
    final author = widget.forum.author;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.shade300,
                  AppColors.primary,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: author?.avatar != null
                ? ClipOval(
                    child: Image.network(
                      author!.avatar!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildDefaultAvatar(author.fullname),
                    ),
                  )
                : _buildDefaultAvatar(author?.fullname ?? 'U'),
          ),

          const SizedBox(width: 12),

          // Name and time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  author?.fullname ?? 'Белгисиз',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(widget.forum.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),

          // More options
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.more_horiz_rounded,
              color: Colors.grey.shade400,
            ),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildImage() {
    return GestureDetector(
      onDoubleTap: () {
        if (!_isLiked) {
          _handleLike();
        }
      },
      child: SizedBox(
        width: double.infinity,
        height: 280,
        child: Image.network(
          widget.forum.photo ?? AppConstants.defaultForumPost,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey.shade100,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            );
          },
          errorBuilder: (_, __, ___) {
            return Container(
              color: Colors.grey.shade100,
              child: Image.network(
                AppConstants.defaultForumPost,
                fit: BoxFit.cover,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionsRow() {
    return Row(
      children: [
        // Like button
        GestureDetector(
          onTap: _handleLike,
          child: ScaleTransition(
            scale: _likeScaleAnimation,
            child: Icon(
              _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _isLiked ? Colors.red : Colors.grey.shade700,
              size: 26,
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Comment button
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            showCommentBottomSheet(forumId: widget.forum.id);
          },
          child: Icon(
            Icons.chat_bubble_outline_rounded,
            color: Colors.grey.shade700,
            size: 24,
          ),
        ),

        const SizedBox(width: 16),

        // Share button
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
          },
          child: Icon(
            Icons.send_outlined,
            color: Colors.grey.shade700,
            size: 24,
          ),
        ),

        const Spacer(),

        // Bookmark button
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
          },
          child: Icon(
            Icons.bookmark_border_rounded,
            color: Colors.grey.shade700,
            size: 26,
          ),
        ),
      ],
    );
  }
}
