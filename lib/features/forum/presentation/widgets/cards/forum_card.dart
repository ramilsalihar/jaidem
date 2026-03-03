import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:jaidem/core/localization/app_localizations.dart';
import 'package:jaidem/core/utils/constants/app_constants.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/forum/domain/entities/forum_entity.dart';
import 'package:jaidem/features/forum/presentation/cubit/forum_cubit.dart';
import 'package:jaidem/features/forum/presentation/dialogs/comment_dialog.dart';
import 'package:jaidem/features/jaidems/presentation/cubit/jaidems_cubit.dart';
import 'package:jaidem/features/jaidems/presentation/pages/jaidem_detail_page.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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

    final wasLiked = _isLiked;
    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
    });

    _likeAnimationController.forward().then((_) {
      _likeAnimationController.reverse();
    });

    final isNowLiked = await context.read<ForumCubit>().toggleLike(widget.forum.id);

    if (mounted && isNowLiked != _isLiked) {
      setState(() {
        _isLiked = isNowLiked;
        _likesCount = wasLiked ? _likesCount : _likesCount;
      });
      _loadLikeInfo();
    }
  }

  Future<void> _handleShare() async {
    HapticFeedback.lightImpact();
    final author = widget.forum.author?.fullname ?? 'Жайдем';
    final content = widget.forum.content ?? '';
    final truncatedContent =
        content.length > 100 ? '${content.substring(0, 100)}...' : content;

    // Deep link URL
    final deepLink = 'https://jaidem.kg/forum/${widget.forum.id}';

    final shareText = '$author жазды:\n\n$truncatedContent\n\n$deepLink';

    try {
      await Share.share(shareText);
    } catch (e) {
      debugPrint('Share error: $e');
    }
  }

  String _formatDate(String? dateStr, BuildContext context) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 1) return context.tr('just_now');
      if (diff.inMinutes < 60) return '${diff.inMinutes}${context.tr('minutes_short')}';
      if (diff.inHours < 24) return '${diff.inHours}${context.tr('hours_short')}';
      if (diff.inDays < 7) return '${diff.inDays}${context.tr('days_short')}';

      final day = date.day.toString().padLeft(2, '0');
      final month = _getMonthName(date.month);
      return '$day $month';
    } catch (e) {
      return '';
    }
  }

  String _getMonthName(int month) {
    const months = ['янв', 'фев', 'мар', 'апр', 'май', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'];
    return months[month - 1];
  }

  void _showOptionsBottomSheet() {
    final author = widget.forum.author;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(Icons.flag_outlined, color: Colors.orange.shade600),
                title: Text(context.tr('report_content')),
                onTap: () {
                  Navigator.pop(ctx);
                  _showReportDialog();
                },
              ),
              if (author != null)
                ListTile(
                  leading: Icon(Icons.block_rounded, color: Colors.red.shade600),
                  title: Text(context.tr('block_user')),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showBlockUserDialog(author.fullname);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showReportDialog() {
    String? selectedReason;
    final reasons = [
      {'key': 'report_spam', 'value': context.tr('report_spam')},
      {'key': 'report_inappropriate', 'value': context.tr('report_inappropriate')},
      {'key': 'report_harassment', 'value': context.tr('report_harassment')},
      {'key': 'report_other', 'value': context.tr('report_other')},
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            context.tr('report_content'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('report_reason'),
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 12),
              ...reasons.map((reason) => RadioListTile<String>(
                title: Text(reason['value']!, style: const TextStyle(fontSize: 14)),
                value: reason['key']!,
                groupValue: selectedReason,
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
                onChanged: (value) => setState(() => selectedReason = value),
              )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.tr('cancel'), style: TextStyle(color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              onPressed: selectedReason != null
                  ? () {
                      Navigator.pop(ctx);
                      context.read<ForumCubit>().reportPost(
                        widget.forum.id,
                        selectedReason!,
                        authorId: widget.forum.author?.id,
                        authorName: widget.forum.author?.fullname,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context.tr('report_sent')),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(context.tr('send')),
            ),
          ],
        ),
      ),
    );
  }

  void _showBlockUserDialog(String userName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.block_rounded, color: Colors.red.shade400, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.tr('block_user'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Text(
          '${context.tr('block_user_confirm')}\n\n$userName',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr('cancel'), style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              final authorId = widget.forum.author?.id;
              if (authorId != null) {
                context.read<ForumCubit>().blockUser(authorId, userName: widget.forum.author?.fullname);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.tr('user_blocked')),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade500,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(context.tr('block_user')),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToAuthorProfile() async {
    final author = widget.forum.author;
    if (author != null) {
      HapticFeedback.lightImpact();

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

      final person = await context.read<JaidemsCubit>().getJaidemById(author.id);

      if (mounted) Navigator.of(context).pop();

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
    final isLongContent = content.length > 280;
    final displayContent =
        _expanded ? content : (isLongContent ? content.substring(0, 280) : content);

    return Column(
      children: [
        // Main tweet content
        InkWell(
          onTap: () {
            // Could navigate to detail view
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                GestureDetector(
                  onTap: _navigateToAuthorProfile,
                  child: _buildAvatar(),
                ),
                const SizedBox(width: 12),
                // Content area
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row
                      _buildHeader(),
                      const SizedBox(height: 4),
                      // Content text
                      if (content.isNotEmpty) _buildContent(displayContent, isLongContent),
                      // Image
                      if (widget.forum.photo != null) _buildImage(),
                      const SizedBox(height: 12),
                      // Actions row
                      _buildActionsRow(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Divider
        Divider(
          height: 1,
          thickness: 0.5,
          color: Colors.grey.shade200,
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    final author = widget.forum.author;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.shade100,
      ),
      child: ClipOval(
        child: author?.avatar != null
            ? Image.network(
                author!.avatar!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildDefaultAvatar(author.fullname),
              )
            : _buildDefaultAvatar(author?.fullname ?? 'Жайдем'),
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

  Widget _buildHeader() {
    final author = widget.forum.author;
    final formattedDate = _formatDate(widget.forum.createdAt, context);

    return Row(
      children: [
        // Name
        GestureDetector(
          onTap: _navigateToAuthorProfile,
          child: Text(
            author?.fullname ?? 'Жайдем',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(width: 4),
        // Dot separator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            '·',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Time
        Text(
          formattedDate,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const Spacer(),
        // More options
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _showOptionsBottomSheet();
          },
          child: Icon(
            Icons.more_horiz,
            color: Colors.grey.shade500,
            size: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(String displayContent, bool isLongContent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onDoubleTap: () {
            if (!_isLiked) {
              _handleLike();
            }
          },
          child: Html(
            data: displayContent,
            style: {
              "body": Style(
                fontSize: FontSize(15),
                color: Colors.black87,
                lineHeight: LineHeight(1.35),
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
              ),
              "p": Style(
                margin: Margins.only(bottom: 8),
              ),
              "a": Style(
                color: AppColors.primary,
                textDecoration: TextDecoration.none,
              ),
              "b": Style(fontWeight: FontWeight.bold),
              "strong": Style(fontWeight: FontWeight.bold),
              "i": Style(fontStyle: FontStyle.italic),
              "em": Style(fontStyle: FontStyle.italic),
              "br": Style(margin: Margins.zero),
            },
            onLinkTap: (url, _, __) async {
              if (url != null) {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              }
            },
          ),
        ),
        if (isLongContent && !_expanded)
          GestureDetector(
            onTap: () => setState(() => _expanded = true),
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                context.tr('see_more'),
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildImage() {
    final imageUrl = widget.forum.photo ?? AppConstants.defaultForumPost;

    return GestureDetector(
      onTap: () => _showFullScreenImage(imageUrl),
      onDoubleTap: () {
        if (!_isLiked) {
          _handleLike();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        constraints: const BoxConstraints(maxHeight: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 0.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 200,
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
                height: 200,
                color: Colors.grey.shade100,
                child: Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.grey.shade400,
                    size: 40,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showFullScreenImage(String imageUrl) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (context, animation, secondaryAnimation) {
          return _FullScreenImageViewer(
            imageUrl: imageUrl,
            animation: animation,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Widget _buildActionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // Comment
        _buildActionButton(
          icon: Icons.chat_bubble_outline,
          count: _commentsCount,
          color: Colors.grey.shade600,
          onTap: () {
            HapticFeedback.lightImpact();
            showCommentBottomSheet(forumId: widget.forum.id);
          },
        ),
        // Like
        _buildActionButton(
          icon: _isLiked ? Icons.favorite : Icons.favorite_border,
          count: _likesCount,
          color: _isLiked ? Colors.pink : Colors.grey.shade600,
          onTap: _handleLike,
          animation: _likeScaleAnimation,
        ),
        // Share
        _buildActionButton(
          icon: Icons.ios_share_outlined,
          count: null,
          color: Colors.grey.shade600,
          onTap: _handleShare,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required int? count,
    required Color color,
    required VoidCallback onTap,
    Animation<double>? animation,
  }) {
    final iconWidget = Icon(icon, color: color, size: 20);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            animation != null
                ? ScaleTransition(scale: animation, child: iconWidget)
                : iconWidget,
            if (count != null) ...[
              const SizedBox(width: 6),
              Text(
                _formatCount(count),
                style: TextStyle(
                  fontSize: 13,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

class _FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;
  final Animation<double> animation;

  const _FullScreenImageViewer({
    required this.imageUrl,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Dismiss on tap background
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(color: Colors.transparent),
          ),
          // Image with zoom
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Hero(
                  tag: imageUrl,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) {
                      return const Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.white54,
                          size: 60,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
