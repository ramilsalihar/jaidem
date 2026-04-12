import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/core/data/injection.dart';
import 'package:jaidem/core/data/models/jaidem/person_model.dart';
import 'package:jaidem/core/data/services/contact_service.dart';
import 'package:jaidem/core/localization/app_localizations.dart';
import 'package:jaidem/core/routes/app_router.dart';
import 'package:jaidem/core/utils/constants/app_constants.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jaidem/features/menu/data/datasources/menu_remote_datasource.dart';
import 'package:jaidem/features/forum/presentation/cubit/forum_cubit.dart';
import 'package:jaidem/features/forum/presentation/widgets/cards/forum_card.dart';
import 'package:jaidem/features/profile/presentation/widgets/birthday_congrats_widget.dart';
import 'package:jaidem/features/birthday/domain/usecases/send_birthday_reaction_usecase.dart';
import 'package:jaidem/features/forum/data/services/forum_firebase_service.dart';
import 'package:jaidem/features/jaidems/presentation/cubit/jaidems_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class JaidemDetailPage extends StatefulWidget {
  const JaidemDetailPage({super.key, required this.person});

  final PersonModel person;

  @override
  State<JaidemDetailPage> createState() => _JaidemDetailPageState();
}

class _JaidemDetailPageState extends State<JaidemDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isOwnProfile = false;
  bool _isBirthday = false;
  bool _hasReacted = false;
  bool _isSendingReaction = false;
  PersonModel? _fullPerson;

  PersonModel get _person => _fullPerson ?? widget.person;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _isBirthday = isTodayBirthday(_person.birthday);
    _checkIfOwnProfile();
    _loadFullPerson();
  }

  Future<void> _loadFullPerson() async {
    final person = await context.read<JaidemsCubit>().getJaidemById(_person.id);
    if (mounted && person != null) {
      setState(() {
        _fullPerson = person;
        _isBirthday = isTodayBirthday(person.birthday);
      });
    }
  }

  Future<void> _sendBirthdayReaction() async {
    if (_hasReacted || _isSendingReaction) return;
    setState(() => _isSendingReaction = true);

    final useCase = sl<SendBirthdayReactionUseCase>();
    final result = await useCase(toUserId: _person.id);

    if (mounted) {
      result.fold(
        (error) {
          setState(() => _isSendingReaction = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red),
          );
        },
        (_) {
          setState(() {
            _hasReacted = true;
            _isSendingReaction = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('birthday_send_reaction')),
              backgroundColor: Colors.green,
            ),
          );
        },
      );
    }
  }

  void _checkIfOwnProfile() {
    final currentUserId = sl<SharedPreferences>().getString(AppConstants.userId) ?? '';

    // If viewing own profile, redirect to profile page
    if (currentUserId == _person.id.toString()) {
      _isOwnProfile = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // Replace with BottomBarRoute showing profile tab (index 4)
          context.router.replaceAll([BottomBarRoute(initialIndex: 4)]);
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showOptionsBottomSheet() {
    final userName = _person.fullname ?? '';
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
                title: Text(context.tr('report_user')),
                onTap: () {
                  Navigator.pop(ctx);
                  _showReportUserDialog();
                },
              ),
              ListTile(
                leading: Icon(Icons.block_rounded, color: Colors.red.shade600),
                title: Text(context.tr('block_user')),
                onTap: () {
                  Navigator.pop(ctx);
                  _showBlockUserDialog(userName);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showReportUserDialog() {
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
            context.tr('report_user'),
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
                      ForumFirebaseService().reportUser(
                        reportedUserId: _person.id,
                        reason: selectedReason!,
                        reportedUserName: _person.fullname,
                      );
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(
                          content: Text(this.context.tr('report_sent')),
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
              ForumFirebaseService().blockUser(
                _person.id,
                blockedUserName: _person.fullname,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.tr('user_blocked')),
                  backgroundColor: Colors.green,
                ),
              );
              // Go back after blocking
              Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    // Don't fetch forums if redirecting to own profile
    if (_isOwnProfile) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return BlocProvider(
      create: (context) => sl<ForumCubit>()..fetchAllForums(authorId: _person.id),
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              _buildSliverAppBar(context),
              const SliverToBoxAdapter(
                child: SizedBox(height: 16),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildProfileCard(context),
                ),
              ),
            ];
          },
          body: _buildAboutTab(context),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      leading: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).pop();
        },
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_back_rounded,
            color: Colors.grey.shade700,
            size: 22,
          ),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _showOptionsBottomSheet();
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.more_horiz,
              color: Colors.grey.shade700,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final hasWork = _person.workPlaces != null && _person.workPlaces!.isNotEmpty;
    final noUni = _person.noUniversity;

    String? uniLine;
    if (!noUni) {
      final specName = _person.spec?.getLocalizedName(locale) ?? _person.speciality;
      final univerName = _person.univer?.getLocalizedName(locale) ?? _person.university;
      final parts = <String>[
        if (specName != null && specName.isNotEmpty) specName,
        if (univerName != null && univerName.isNotEmpty) univerName,
      ];
      if (parts.isNotEmpty) uniLine = parts.join(' | ');
    }

    String? workLine;
    if (hasWork) {
      final latest = _person.workPlaces!.last;
      final parts = <String>[
        if (latest.position.isNotEmpty) latest.position,
        if (latest.name.isNotEmpty) latest.name,
      ];
      if (parts.isNotEmpty) workLine = parts.join(' | ');
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _person.avatar != null
                  ? () => _showFullImage(context, _person.avatar!)
                  : null,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary.shade100,
                  backgroundImage: _person.avatar != null
                      ? NetworkImage(_person.avatar!)
                      : null,
                  child: _person.avatar == null
                      ? Text(
                          (_person.fullname?.isNotEmpty ?? false)
                              ? _person.fullname![0].toUpperCase()
                              : 'U',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                  // Name
                  Text(
                    _person.fullname ?? context.tr('unknown'),
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (workLine != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      workLine,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (uniLine != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      uniLine,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (_person.flow.name.isNotEmpty || _person.category != null) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      alignment: WrapAlignment.center,
                      children: [
                        if (_person.flow.name.isNotEmpty)
                          _buildSmallTag('${context.tr('flow')} ${_person.flow.name}'),
                        if (_person.category != null)
                          _buildSmallTag(
                            _person.category!.getLocalizedName(
                              Localizations.localeOf(context).languageCode,
                            ),
                            color: Colors.amber.shade700,
                            bgColor: Colors.amber.shade50,
                            icon: Icons.workspace_premium_rounded,
                          ),
                      ],
                    ),
                  ],
                  if (_isBirthday) ...[
                    const SizedBox(height: 12),
                    _buildBirthdayCongrats(context),
                  ],
                  const SizedBox(height: 16),
                  _buildQuickActions(context),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBirthdayCongrats(BuildContext context) {
    return GestureDetector(
      onTap: _hasReacted ? null : _sendBirthdayReaction,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _hasReacted
                ? [Colors.grey.shade100, Colors.grey.shade50]
                : [Colors.pink.shade50, Colors.purple.shade50],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hasReacted
                ? Colors.grey.withValues(alpha: 0.3)
                : Colors.pink.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isSendingReaction)
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.pink.shade400),
                ),
              )
            else ...[
              Text(
                _hasReacted ? '✓' : '🎂',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 8),
              Text(
                _hasReacted
                    ? context.tr('birthday_already_reacted')
                    : context.tr('birthday_congrats_button'),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _hasReacted ? Colors.grey.shade500 : Colors.pink.shade600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSmallTag(
    String text, {
    Color? color,
    Color? bgColor,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor ?? AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color ?? AppColors.primary),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color ?? AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final hasWhatsApp = _person.socialMedias?['whatsapp']?.isNotEmpty ?? false;
    final hasInstagram = _person.socialMedias?['instagram']?.isNotEmpty ?? false;
    final hasTelegram = _person.telegram?.isNotEmpty ?? false;

    return Row(
      children: [
        // Write message button - always show as primary action
        Expanded(
          child: _buildActionButton(
            icon: Icons.message_rounded,
            label: context.tr('write_message'),
            color: AppColors.primary,
            isPrimary: true,
            onTap: () async {
              HapticFeedback.lightImpact();
              final currentUserId = sl<SharedPreferences>().getString(AppConstants.userId) ?? '';

              // If viewing own profile, go to profile page
              if (currentUserId == _person.id.toString()) {
                context.router.replaceAll([BottomBarRoute(initialIndex: 4)]);
                return;
              }

              // Ensure target user exists in Firebase with proper data
              await sl<MenuRemoteDatasource>().ensureUserExists(
                id: _person.id.toString(),
                name: _person.fullname ?? 'User',
                photoUrl: _person.avatar,
              );

              if (!context.mounted) return;

              context.router.push(
                ChatRoute(
                  chatType: 'users',
                  userId: _person.id.toString(),
                  userName: _person.fullname,
                  userAvatar: _person.avatar,
                ),
              );
            },
          ),
        ),
        if (hasWhatsApp) const SizedBox(width: 8),
        if (hasWhatsApp)
          Expanded(
            child: _buildActionButton(
              icon: Icons.chat_rounded,
              label: 'WhatsApp',
              color: const Color(0xFF25D366),
              onTap: () {
                HapticFeedback.lightImpact();
                ContactService().openWhatsapp(_person.socialMedias!['whatsapp']!);
              },
            ),
          ),
        if (hasInstagram) const SizedBox(width: 8),
        if (hasInstagram)
          Expanded(
            child: _buildActionButton(
              icon: Icons.camera_alt_rounded,
              label: 'Instagram',
              color: const Color(0xFFE4405F),
              onTap: () {
                HapticFeedback.lightImpact();
                ContactService().openInstagram(_person.socialMedias!['instagram']!);
              },
            ),
          ),
        if (hasTelegram) const SizedBox(width: 8),
        if (hasTelegram)
          Expanded(
            child: _buildActionButton(
              icon: Icons.send_rounded,
              label: 'Telegram',
              color: const Color(0xFF0088CC),
              onTap: () {
                HapticFeedback.lightImpact();
                ContactService().openTelegram(_person.telegram!);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isPrimary ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isPrimary ? Colors.white : color, size: 16),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isPrimary ? Colors.white : color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey.shade700,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          indicator: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, size: 18),
                  const SizedBox(width: 6),
                  Text(context.tr('profile_tab')),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.article_outlined, size: 18),
                  const SizedBox(width: 6),
                  Text(context.tr('posts')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsTab(BuildContext context) {
    return BlocBuilder<ForumCubit, ForumState>(
      builder: (context, state) {
        if (state.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          );
        }

        if (state.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  context.tr('error_loading_posts'),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<ForumCubit>().fetchAllForums(authorId: _person.id);
                  },
                  child: Text(context.tr('retry')),
                ),
              ],
            ),
          );
        }

        if (state.forums.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.article_outlined,
                  size: 64,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  context.tr('no_posts_yet'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr('user_has_no_posts'),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await context.read<ForumCubit>().fetchAllForums(authorId: _person.id);
          },
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: state.forums.length,
            itemBuilder: (context, index) {
              return Container(
                color: Colors.white,
                child: ForumCard(forum: state.forums[index]),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAboutTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Positions in Jaidem
          if (_person.positionsInJaidem != null && _person.positionsInJaidem!.isNotEmpty)
            _buildPositionsSection(),

          // Vklad to Jaidem
          if (_person.vkladToJaidem != null && _person.vkladToJaidem!.isNotEmpty)
            _buildAccentCard(
              context,
              title: context.tr('vklad_to_jaidem'),
              icon: Icons.handshake_rounded,
              content: _person.vkladToJaidem!,
              color: AppColors.primary,
            ),

          // About section
          if (_person.aboutMe != null && _person.aboutMe!.isNotEmpty)
            _buildAboutSection(context),

          // Info section
          _buildInfoSection(context),

          // Other Schools
          if (_person.otherSchools != null && _person.otherSchools!.isNotEmpty)
            _buildListSection(
              context,
              context.tr('other_education'),
              Icons.menu_book_outlined,
              _person.otherSchools!.map((s) {
                final parts = <String>[
                  if (s.description.isNotEmpty) s.description,
                  if (s.startDate != null || s.endDate != null) _formatDateRange(context, s.startDate, s.endDate),
                ];
                return MapEntry(s.name, parts.isNotEmpty ? parts.join(' · ') : null);
              }).toList(),
            ),

          // Additional Education
          if (_person.additionalEducations != null && _person.additionalEducations!.isNotEmpty)
            _buildListSection(
              context,
              context.tr('additional_education'),
              Icons.auto_stories_outlined,
              _person.additionalEducations!.map((e) {
                final parts = <String>[
                  if (e.description.isNotEmpty) e.description,
                  if (e.dateStart != null || e.dateEnd != null) _formatDateRange(context, e.dateStart, e.dateEnd),
                ];
                return MapEntry(e.title, parts.isNotEmpty ? parts.join(' · ') : null);
              }).toList(),
            ),

          // Work Places
          if (_person.workPlaces != null && _person.workPlaces!.isNotEmpty)
            _buildListSection(
              context,
              context.tr('work_experience'),
              Icons.work_outline_rounded,
              _person.workPlaces!.map((w) {
                final parts = <String>[
                  if (w.position.isNotEmpty) w.position,
                  if (w.startDate != null || w.endDate != null) _formatDateRange(context, w.startDate, w.endDate),
                  if (w.description.isNotEmpty) w.description,
                ];
                return MapEntry(w.name, parts.isNotEmpty ? parts.join(' · ') : null);
              }).toList(),
            ),

          // Success History
          if (_person.successHist != null && _person.successHist!.isNotEmpty)
            _buildListSection(
              context,
              context.tr('success_history'),
              Icons.emoji_events_outlined,
              _person.successHist!.map((s) => MapEntry(s.name, s.description.isNotEmpty ? s.description : null)).toList(),
            ),

          // New fields — accent cards
          if (_person.inWhatIcanHelp != null && _person.inWhatIcanHelp!.isNotEmpty)
            _buildAccentCard(
              context,
              title: context.tr('in_what_i_can_help'),
              icon: Icons.volunteer_activism_rounded,
              content: _person.inWhatIcanHelp!,
              color: Colors.green,
            ),
          if (_person.whatINeed != null && _person.whatINeed!.isNotEmpty)
            _buildAccentCard(
              context,
              title: context.tr('what_i_need'),
              icon: Icons.front_hand_rounded,
              content: _person.whatINeed!,
              color: Colors.orange,
            ),
          if (_person.openTo != null && _person.openTo!.isNotEmpty)
            _buildInfoCard(context, context.tr('open_to'), Icons.door_front_door_outlined, _person.openTo!),
          if (_person.tags != null && _person.tags!.isNotEmpty)
            _buildTagsSection(context, _person.tags!),

          // Booking link for advisors
          if (_person.isAdvisor &&
              _person.linkToReserve != null &&
              _person.linkToReserve!.isNotEmpty)
            _buildBookingLinkSection(context),

          // Contact section
          _buildContactSection(context),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPositionsSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _person.positionsInJaidem!.map((position) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    position,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                context.tr('about_me'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _person.aboutMe!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final items = <_InfoItem>[];

    // Birthday
    if (_person.birthday != null && _person.birthday!.isNotEmpty) {
      final birthDate = DateTime.tryParse(_person.birthday!);
      if (birthDate != null) {
        final formatted = '${birthDate.day.toString().padLeft(2, '0')}.${birthDate.month.toString().padLeft(2, '0')}.${birthDate.year}';
        items.add(_InfoItem(Icons.cake_outlined, context.tr('date_of_birth'), formatted));
      }
    }

    // Use univer object first, fallback to university string
    final univerName = _person.univer?.getLocalizedName(locale) ?? _person.university;
    if (univerName != null && univerName.isNotEmpty) {
      items.add(_InfoItem(Icons.school_outlined, context.tr('university'), univerName));
    }
    final regionName = _person.region?.getLocalizedName(locale);
    if (regionName != null && regionName.isNotEmpty) {
      items.add(_InfoItem(Icons.map_outlined, context.tr('district'), regionName));
    }
    final villageName = _person.village?.getLocalizedName(locale);
    if (villageName != null && villageName.isNotEmpty) {
      items.add(_InfoItem(Icons.location_city_outlined, context.tr('village'), villageName));
    }
    if (_person.interest != null && _person.interest!.isNotEmpty) {
      items.add(_InfoItem(Icons.favorite_outline, context.tr('interests'), _person.interest!));
    }
    if (_person.skills != null && _person.skills!.isNotEmpty) {
      items.add(_InfoItem(Icons.psychology_outlined, context.tr('skills'), _person.skills!));
    }
    if (_person.telegram != null && _person.telegram!.isNotEmpty) {
      items.add(_InfoItem(Icons.send_rounded, 'Telegram', _person.telegram!));
    }
    if (_person.category != null) {
      items.add(_InfoItem(Icons.workspace_premium_outlined, context.tr('member_category'), _person.category!.getLocalizedName(locale)));
    }

    if (items.isEmpty) return const SizedBox();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                context.tr('information'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => _buildInfoRow(item)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(_InfoItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.icon, size: 20, color: Colors.grey.shade500),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingLinkSection(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        final url = Uri.parse(_person.linkToReserve!);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.calendar_month_rounded, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('booking_link'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _person.linkToReserve!,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.open_in_new_rounded, size: 18, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  String _formatDateRange(BuildContext ctx, String? startDate, String? endDate) {
    String fmt(String d) {
      final dt = DateTime.tryParse(d);
      if (dt == null) return d;
      return '${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    }
    final currently = ctx.tr('currently');
    final s = startDate != null ? fmt(startDate) : null;
    final e = endDate != null ? fmt(endDate) : currently;
    if (s != null) return '$s — $e';
    return '— $e';
  }

  Widget _buildAccentCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String content,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.1),
                  color.withValues(alpha: 0.03),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: color,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, IconData icon, String content) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade800,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection(BuildContext context, List<String> tags) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tag_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                context.tr('tags'),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection(
    BuildContext context,
    String title,
    IconData icon,
    List<MapEntry<String, String?>> items,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.circle, size: 6, color: Colors.grey.shade400),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.key,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          if (item.value != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              item.value!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    final hasPhone = _person.phone != null && _person.phone!.isNotEmpty;
    final hasEmail = _person.email != null && _person.email!.isNotEmpty;

    if (!hasPhone && !hasEmail) return const SizedBox();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.contact_phone_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                context.tr('contact'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasPhone)
            _buildContactRow(
              icon: Icons.phone_rounded,
              value: _person.phone!,
              onTap: () {
                HapticFeedback.lightImpact();
                ContactService().callToPhone(_person.phone!);
              },
            ),
          if (hasEmail)
            _buildContactRow(
              icon: Icons.email_rounded,
              value: _person.email!,
              onTap: () async {
                HapticFeedback.lightImpact();
                final url = Uri.parse('mailto:${_person.email!}');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;

  _InfoItem(this.icon, this.label, this.value);
}
