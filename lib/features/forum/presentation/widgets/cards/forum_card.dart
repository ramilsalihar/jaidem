import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/core/utils/constants/app_constants.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/forum/domain/entities/forum_entity.dart';
import 'package:jaidem/features/forum/presentation/cubit/forum_cubit.dart';
import 'package:jaidem/features/forum/presentation/dialogs/comment_dialog.dart';
import 'package:jaidem/features/jaidems/presentation/cubit/jaidems_cubit.dart';
import 'package:jaidem/features/jaidems/presentation/pages/jaidem_detail_page.dart';
import 'package:share_plus/share_plus.dart';

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
  int _commentsCount = 0;
  late AnimationController _likeAnimationController;
  late Animation<double> _likeScaleAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize with default values, then load from Firebase
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

    // Load like info from Firebase
    _loadLikeInfo();
  }

  Future<void> _loadLikeInfo() async {
    final cubit = context.read<ForumCubit>();
    final likeInfo = await cubit.getLikeInfo(widget.forum.id);
    final commentsCount = await cubit.getCommentsCount(widget.forum.id);
    if (mounted) {
      setState(() {
        _isLiked = likeInfo['isLiked'] as bool;
        _likesCount = likeInfo['count'] as int;
        _commentsCount = commentsCount;
      });
    }
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    super.dispose();
  }

  Future<void> _handleLike() async {
    HapticFeedback.lightImpact();

    // Optimistic update
    final wasLiked = _isLiked;
    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
    });

    _likeAnimationController.forward().then((_) {
      _likeAnimationController.reverse();
    });

    // Toggle like in Firebase
    final isNowLiked =
        await context.read<ForumCubit>().toggleLike(widget.forum.id);

    // If the result doesn't match our optimistic update, correct it
    if (mounted && isNowLiked != _isLiked) {
      setState(() {
        _isLiked = isNowLiked;
        _likesCount = wasLiked ? _likesCount : _likesCount;
      });
      // Reload to get accurate count
      _loadLikeInfo();
    }
  }

  Future<void> _handleShare() async {
    HapticFeedback.lightImpact();
    final author = widget.forum.author?.fullname ?? 'Белгисиз';
    final content = widget.forum.content ?? '';
    final truncatedContent =
        content.length > 100 ? '${content.substring(0, 100)}...' : content;

    final shareText =
        '$author жазды:\n\n$truncatedContent\n\nJaidem колдонмосунда көбүрөөк маалымат алыңыз!';

    try {
      await Share.share(shareText);
    } catch (e) {
      // Silently handle share errors
      debugPrint('Share error: $e');
    }
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

      // Fix: Pad both day and month with leading zero
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      return '$day.$month.${date.year}';
    } catch (e) {
      return '';
    }
  }

  Future<void> _navigateToAuthorProfile() async {
    final author = widget.forum.author;
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
      final person =
          await context.read<JaidemsCubit>().getJaidemById(author.id);

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
    final content = widget.forum.content ?? '';
    final isLongContent = content.length > 150;
    final displayContent = _expanded
        ? content
        : (isLongContent ? content.substring(0, 150) : content);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author header
            _buildAuthorHeader(),

            // Content text (before image like Facebook)
            if (content.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayContent,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade800,
                        height: 1.4,
                      ),
                    ),
                    if (isLongContent)
                      GestureDetector(
                        onTap: () => setState(() => _expanded = !_expanded),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _expanded ? 'Азыраак көрүү' : 'Толук көрүү...',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            // Image
            _buildImage(),

            // Reaction summary
            _buildReactionSummary(),

            // Divider
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.grey.shade200,
            ),

            // Actions row
            _buildActionsRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorHeader() {
    final author = widget.forum.author;
    return GestureDetector(
      onTap: _navigateToAuthorProfile,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: author?.avatar != null
                    ? Image.network(
                        author!.avatar!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _buildDefaultAvatar(author.fullname),
                      )
                    : _buildDefaultAvatar(author?.fullname ?? 'U'),
              ),
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
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        _formatDate(widget.forum.createdAt),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.public,
                        size: 14,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // More options
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.more_horiz_rounded,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    return Container(
      color: AppColors.primary.shade200,
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
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
        child: Image.network(
          widget.forum.photo ?? AppConstants.defaultForumPost,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 300,
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
              height: 300,
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

  Widget _buildReactionSummary() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Likes indicator
          if (_likesCount > 0) ...[
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade400, Colors.pink.shade400],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_rounded,
                size: 12,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$_likesCount',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],

          const Spacer(),

          // Comments count
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              showCommentBottomSheet(forumId: widget.forum.id);
            },
            child: Text(
              _commentsCount > 0
                  ? '$_commentsCount комментарий'
                  : 'Комментарийлер',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          // Like button
          Expanded(
            child: _buildActionButton(
              icon: _isLiked
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              label: 'Жактырдым',
              color: _isLiked ? Colors.red : Colors.grey.shade700,
              onTap: _handleLike,
              animation: _likeScaleAnimation,
            ),
          ),

          // Comment button
          Expanded(
            child: _buildActionButton(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Комментарий',
              color: Colors.grey.shade700,
              onTap: () {
                HapticFeedback.lightImpact();
                showCommentBottomSheet(forumId: widget.forum.id);
              },
            ),
          ),

          // Share button
          Expanded(
            child: _buildActionButton(
              icon: Icons.share_outlined,
              label: 'Бөлүшүү',
              color: Colors.grey.shade700,
              onTap: _handleShare,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    Animation<double>? animation,
  }) {
    final iconWidget = Icon(icon, color: color, size: 20);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              animation != null
                  ? ScaleTransition(scale: animation, child: iconWidget)
                  : iconWidget,
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
