import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jaidem/core/data/models/jaidem/person_model.dart';
import 'package:jaidem/core/localization/app_localizations.dart';
import 'package:jaidem/core/network/dio_network.dart';
import 'package:jaidem/core/utils/constants/api_const.dart';
import 'package:jaidem/core/utils/constants/app_constants.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/forum/data/mappers/forum_mapper.dart';
import 'package:jaidem/features/forum/data/models/forum_model.dart';
import 'package:jaidem/features/notifications/presentation/pages/notification_mixin.dart';
import 'package:jaidem/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:jaidem/features/profile/presentation/widgets/birthday_congrats_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jaidem/core/data/injection.dart';
import 'package:jaidem/core/routes/app_router.dart';
import 'package:jaidem/features/opros/data/models/opros_status_model.dart';
import 'package:jaidem/features/opros/domain/usecases/get_opros_status_usecase.dart';
import 'package:jaidem/features/birthday/domain/usecases/get_my_birthday_reactions_usecase.dart';
import 'package:intl/intl.dart';
import 'package:jaidem/core/utils/helpers/content_filter.dart';

@RoutePage()
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with NotificationMixin, SingleTickerProviderStateMixin {
  bool _showBirthdayWidget = false;
  bool _birthdayChecked = false;
  bool _isBirthday = false;
  int _birthdayShownCount = 0;
  late TabController _tabController;

  OprosStatusModel? _oprosStatus;
  bool _oprosLoading = true;
  int _birthdayReactionCount = 0;

  static const _birthdayShownKey = 'birthday_shown_';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _loadUserProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadUserProfile() {
    context.read<ProfileCubit>().getUser();
    _loadOprosStatus();
  }

  Future<void> _loadOprosStatus() async {
    final useCase = sl<GetOprosStatusUseCase>();
    final result = await useCase();
    if (mounted) {
      result.fold(
        (error) => setState(() => _oprosLoading = false),
        (status) => setState(() {
          _oprosStatus = status;
          _oprosLoading = false;
        }),
      );
    }
  }

  Future<void> _loadBirthdayReactions() async {
    final useCase = sl<GetMyBirthdayReactionsUseCase>();
    final result = await useCase();
    if (mounted) {
      result.fold(
        (_) {},
        (response) => setState(() {
          _birthdayReactionCount = response.count;
        }),
      );
    }
  }

  String _todayKey() {
    final now = DateTime.now();
    return '$_birthdayShownKey${now.year}-${now.month}-${now.day}';
  }

  Future<void> _checkBirthday(PersonModel user) async {
    if (_birthdayChecked) return;
    _birthdayChecked = true;

    if (!isTodayBirthday(user.birthday)) return;

    _isBirthday = true;
    _loadBirthdayReactions();
    final prefs = await SharedPreferences.getInstance();
    _birthdayShownCount = prefs.getInt(_todayKey()) ?? 0;

    if (_birthdayShownCount < 2) {
      _birthdayShownCount++;
      await prefs.setInt(_todayKey(), _birthdayShownCount);
      if (mounted) {
        setState(() {
          _showBirthdayWidget = true;
        });
      }
    } else {
      if (mounted) setState(() {});
    }
  }

  void _showBirthdayDialog(PersonModel user) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (_) => BirthdayCongratsWidget(
        userName: user.fullname ?? '',
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final user = state is ProfileLoaded ? state.user : null;

          if (user == null) {
            return _buildLoadingState();
          }

          // Check birthday when user is loaded
          _checkBirthday(user);

          return Stack(
            children: [
              NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          _buildHeader(user),
                          if (!_oprosLoading &&
                              _oprosStatus != null &&
                              (double.tryParse(user.flow.name) ?? 0) >= 2.5)
                            _buildSurveyCards(),
                          if (_isBirthday && !_showBirthdayWidget)
                            _buildBirthdayCard(user),
                        ],
                      ),
                    ),
                  ];
                },
                body: _ProfileInfoTab(user: user),
              ),
              // Birthday celebration overlay
              if (_showBirthdayWidget)
                BirthdayCongratsWidget(
                  userName: user.fullname ?? '',
                  onClose: () {
                    setState(() {
                      _showBirthdayWidget = false;
                    });
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            context.tr('loading'),
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(PersonModel user) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.shade700,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top bar with notification
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr('profile'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          showNotificationPopup();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          context.router.push(ChatListRoute());
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.chat_bubble_outline_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Avatar
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white24,
                ),
                child: ClipOval(
                  child: user.avatar != null && user.avatar!.isNotEmpty
                      ? Image.network(
                          user.avatar!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildDefaultAvatar(user),
                        )
                      : _buildDefaultAvatar(user),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Name
            Text(
              user.fullname ?? 'Белгисиз',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),

            const SizedBox(height: 4),

            // Headline: work place and/or university info
            Builder(
              builder: (context) {
                final locale = Localizations.localeOf(context).languageCode;
                final hasWork = user.workPlaces != null && user.workPlaces!.isNotEmpty;
                final noUni = user.noUniversity;

                String? uniLine;
                if (!noUni) {
                  final specName = user.spec?.getLocalizedName(locale) ?? user.speciality;
                  final univerName = user.univer?.getLocalizedName(locale) ?? user.university;
                  final parts = <String>[
                    if (specName != null && specName.isNotEmpty) specName,
                    if (univerName != null && univerName.isNotEmpty) univerName,
                  ];
                  if (parts.isNotEmpty) uniLine = parts.join(' | ');
                }

                String? workLine;
                if (hasWork) {
                  final latest = user.workPlaces!.last;
                  final parts = <String>[
                    if (latest.position.isNotEmpty) latest.position,
                    if (latest.name.isNotEmpty) latest.name,
                  ];
                  if (parts.isNotEmpty) workLine = parts.join(' | ');
                }

                if (workLine == null && uniLine == null) return const SizedBox.shrink();

                final textStyle = TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w500,
                );

                return Column(
                  children: [
                    if (workLine != null)
                      Text(workLine, style: textStyle, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                    if (uniLine != null) ...[
                      if (workLine != null) const SizedBox(height: 2),
                      Text(uniLine, style: textStyle, textAlign: TextAlign.center),
                    ],
                  ],
                );
              },
            ),

            const SizedBox(height: 12),

            // Tags
            Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: [
                if (user.flow.name.isNotEmpty)
                  _buildTag('${context.tr('flow')} ${user.flow.name}'),
                if (user.generation != null && user.generation!.isNotEmpty)
                  _buildTag(user.generation!),
                Builder(
                  builder: (context) {
                    final locale = Localizations.localeOf(context).languageCode;
                    final stateName = user.state.getLocalizedName(locale);
                    if (stateName.isNotEmpty) return _buildTag(stateName);
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(PersonModel user) {
    final initial =
        (user.fullname?.isNotEmpty ?? false) ? user.fullname![0].toUpperCase() : 'U';
    return Container(
      color: Colors.white24,
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSurveyCards() {
    final status = _oprosStatus!;
    return Column(
      children: [
        // "Before" survey card
        if (!status.beforeCompleted)
          _buildSurveyCard(
            title: context.tr('opros_before_survey'),
            subtitle: context.tr('opros_fill_survey'),
            icon: Icons.assignment_outlined,
            isActive: true,
            onTap: () async {
              final result = await context.router.push(
                OprosSurveyRoute(surveyType: 'before'),
              );
              if (result == true) _loadOprosStatus();
            },
          ),
        // "After" survey card
        if (!status.afterCompleted && status.afterOpenDate != null)
          _buildSurveyCard(
            title: context.tr('opros_after_survey'),
            subtitle: status.isAfterOpen
                ? context.tr('opros_fill_survey')
                : '${context.tr('opros_opens_on')}${DateFormat('dd.MM.yyyy').format(status.afterOpenDateTime!)}',
            icon: Icons.assignment_turned_in_outlined,
            isActive: status.isAfterOpen,
            onTap: status.isAfterOpen
                ? () async {
                    final result = await context.router.push(
                      OprosSurveyRoute(surveyType: 'after'),
                    );
                    if (result == true) _loadOprosStatus();
                  }
                : null,
          ),
      ],
    );
  }

  Widget _buildSurveyCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isActive,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: isActive
          ? () {
              HapticFeedback.mediumImpact();
              onTap?.call();
            }
          : null,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isActive
                ? [AppColors.primary.withValues(alpha: 0.1), Colors.blue.shade50]
                : [Colors.grey.shade100, Colors.grey.shade50],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: isActive ? AppColors.primary : Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isActive ? AppColors.primary : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive ? Colors.blue.shade400 : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
            if (isActive)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.primary,
                ),
              )
            else
              Icon(Icons.lock_outline, size: 20, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildBirthdayCard(PersonModel user) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _showBirthdayDialog(user);
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.pink.shade50,
              Colors.purple.shade50,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.pink.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            const Text('🎂', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Туулган күнүң менен!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.pink.shade700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _birthdayReactionCount > 0
                        ? '${context.tr('birthday_people_reacted')}: $_birthdayReactionCount'
                        : 'Куттуктоону көрүү',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.purple.shade400,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.pink.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.pink.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTabBar(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey.shade600,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
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
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          splashBorderRadius: BorderRadius.circular(10),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_outline_rounded, size: 18),
                  const SizedBox(width: 6),
                  Text(context.tr('profile_info')),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.grid_view_rounded, size: 18),
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
}

// Modern Tab Bar Delegate for pinned tab bar
class _ModernTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _ModernTabBarDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 72;

  @override
  double get minExtent => 72;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}

// Profile Info Tab
class _ProfileInfoTab extends StatelessWidget {
  final PersonModel user;

  const _ProfileInfoTab({required this.user});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<ProfileCubit>().getUser(),
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Positions in Jaidem
            if (user.positionsInJaidem != null && user.positionsInJaidem!.isNotEmpty)
              _buildPositionsSection(),

            // About Section
            if (user.aboutMe != null && user.aboutMe!.isNotEmpty) _buildAboutSection(context),

            // Info List
            _buildInfoList(context),

            // Other Schools
            if (user.otherSchools != null && user.otherSchools!.isNotEmpty)
              _buildProfileListSection(
                context,
                context.tr('other_education'),
                Icons.menu_book_outlined,
                user.otherSchools!.map((s) {
                  final parts = <String>[
                    if (s.description.isNotEmpty) s.description,
                    if (s.startDate != null || s.endDate != null) _formatDateRange(context, s.startDate, s.endDate),
                  ];
                  return MapEntry(s.name, parts.isNotEmpty ? parts.join(' · ') : null);
                }).toList(),
              ),

            // Additional Education
            if (user.additionalEducations != null && user.additionalEducations!.isNotEmpty)
              _buildProfileListSection(
                context,
                context.tr('additional_education'),
                Icons.auto_stories_outlined,
                user.additionalEducations!.map((e) {
                  final parts = <String>[
                    if (e.description.isNotEmpty) e.description,
                    if (e.dateStart != null || e.dateEnd != null) _formatDateRange(context, e.dateStart, e.dateEnd),
                  ];
                  return MapEntry(e.title, parts.isNotEmpty ? parts.join(' · ') : null);
                }).toList(),
              ),

            // Work Places
            if (user.workPlaces != null && user.workPlaces!.isNotEmpty)
              _buildProfileListSection(
                context,
                context.tr('work_experience'),
                Icons.work_outline_rounded,
                user.workPlaces!.map((w) {
                  final parts = <String>[
                    if (w.position.isNotEmpty) w.position,
                    if (w.startDate != null || w.endDate != null) _formatDateRange(context, w.startDate, w.endDate),
                  ];
                  return MapEntry(w.name, parts.isNotEmpty ? parts.join(' · ') : null);
                }).toList(),
              ),

            // Success History
            if (user.successHist != null && user.successHist!.isNotEmpty)
              _buildProfileListSection(
                context,
                context.tr('success_history'),
                Icons.emoji_events_outlined,
                user.successHist!.map((s) => MapEntry(s.name, s.description.isNotEmpty ? s.description : null)).toList(),
              ),

            // New fields
            if (user.inWhatIcanHelp != null && user.inWhatIcanHelp!.isNotEmpty)
              _buildInfoCard(context, context.tr('in_what_i_can_help'), Icons.volunteer_activism_outlined, user.inWhatIcanHelp!),
            if (user.whatINeed != null && user.whatINeed!.isNotEmpty)
              _buildInfoCard(context, context.tr('what_i_need'), Icons.front_hand_outlined, user.whatINeed!),
            if (user.openTo != null && user.openTo!.isNotEmpty)
              _buildInfoCard(context, context.tr('open_to'), Icons.door_front_door_outlined, user.openTo!),
            if (user.vkladToJaidem != null && user.vkladToJaidem!.isNotEmpty)
              _buildInfoCard(context, context.tr('vklad_to_jaidem'), Icons.handshake_outlined, user.vkladToJaidem!),

            // Tags
            if (user.tags != null && user.tags!.isNotEmpty)
              _buildTagsSection(context, user.tags!),

            const SizedBox(height: 16),

            // Edit Profile Button
            _buildEditButton(context),

            const SizedBox(height: 16),

            // Delete Account Button
            _buildDeleteAccountButton(context),

            const SizedBox(height: 24),
          ],
        ),
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: user.positionsInJaidem!.map((position) {
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
            user.aboutMe!,
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

  Widget _buildInfoList(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final items = <_InfoItem>[];

    // Birthday
    if (user.birthday != null && user.birthday!.isNotEmpty) {
      final birthDate = DateTime.tryParse(user.birthday!);
      if (birthDate != null) {
        final formatted = '${birthDate.day.toString().padLeft(2, '0')}.${birthDate.month.toString().padLeft(2, '0')}.${birthDate.year}';
        items.add(_InfoItem(Icons.cake_outlined, context.tr('date_of_birth'), formatted));
      }
    }

    final regionName = user.region?.getLocalizedName(locale);
    if (regionName != null && regionName.isNotEmpty) {
      items.add(_InfoItem(Icons.map_outlined, context.tr('district'), regionName));
    }
    final villageName = user.village?.getLocalizedName(locale);
    if (villageName != null && villageName.isNotEmpty) {
      items.add(_InfoItem(Icons.location_city_outlined, context.tr('village'), villageName));
    }
    if (user.interest != null && user.interest!.isNotEmpty) {
      items.add(_InfoItem(Icons.favorite_outline_rounded, context.tr('interests'), user.interest!));
    }
    if (user.skills != null && user.skills!.isNotEmpty) {
      items.add(_InfoItem(Icons.psychology_outlined, context.tr('skills'), user.skills!));
    }

    final whatsapp = user.socialMedias?['whatsapp'];
    final instagram = user.socialMedias?['instagram'];
    if (whatsapp != null && whatsapp.isNotEmpty) {
      items.add(_InfoItem(Icons.chat_outlined, 'WhatsApp', whatsapp));
    }
    if (instagram != null && instagram.isNotEmpty) {
      items.add(_InfoItem(Icons.camera_alt_outlined, 'Instagram', instagram));
    }
    if (user.telegram != null && user.telegram!.isNotEmpty) {
      items.add(_InfoItem(Icons.send_rounded, 'Telegram', user.telegram!));
    }
    if (user.category != null) {
      final locale = Localizations.localeOf(context).languageCode;
      items.add(_InfoItem(Icons.workspace_premium_outlined, context.tr('member_category'), user.category!.getLocalizedName(locale)));
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

  Widget _buildProfileListSection(
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

  Widget _buildEditButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        context.router.pushPath('/profile/edit');
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primary.shade600],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              context.tr('edit_profile'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.mediumImpact();
        final confirmed = await showDeleteAccountDialog(context);
        if (confirmed == true && context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );

          await Future.delayed(const Duration(seconds: 1));

          if (context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.tr('account_deleted')),
                backgroundColor: Colors.green,
              ),
            );
            context.router.replacePath('/login');
          }
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade300, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: 20),
            const SizedBox(width: 10),
            Text(
              context.tr('delete_account'),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// User Posts Tab
class _UserPostsTab extends StatefulWidget {
  final int userId;

  const _UserPostsTab({required this.userId});

  @override
  State<_UserPostsTab> createState() => _UserPostsTabState();
}

class _UserPostsTabState extends State<_UserPostsTab> {
  List<ForumModel> _posts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prefs = sl<SharedPreferences>();
      final username = prefs.getString(AppConstants.userLogin);

      final response = await DioNetwork.appAPI.get(
        ApiConst.forum,
        queryParameters: {
          'author': widget.userId,
          'ordering': '-created_at',
        },
      );

      if (response.statusCode == 200) {
        final results = response.data['results'] as List;
        _posts = results.map((json) => ForumMapper.fromJson(json, username)).toList();
      } else {
        _error = 'Посттор жүктөлгөн жок';
      }
    } catch (e) {
      _error = 'Ката: $e';
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deletePost(int postId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(context.tr('delete_post_title')),
        content: Text(context.tr('delete_post_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.tr('no'), style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade500,
              foregroundColor: Colors.white,
            ),
            child: Text(context.tr('delete')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final response = await DioNetwork.appAPI.delete('${ApiConst.forum}$postId/');
        if (response.statusCode == 204 || response.statusCode == 200) {
          _loadPosts();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.tr('post_deleted')),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${context.tr('error')}: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showCreateEditPostDialog({ForumModel? post}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateEditPostSheet(
        post: post,
        userId: widget.userId,
        onSuccess: () {
          _loadPosts();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_error != null)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(_error!, style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadPosts,
                  child: Text(context.tr('reload')),
                ),
              ],
            ),
          )
        else if (_posts.isEmpty)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.article_outlined, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  context.tr('no_posts'),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr('no_posts_hint'),
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                ),
              ],
            ),
          )
        else
          RefreshIndicator(
            onRefresh: _loadPosts,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                return _buildPostCard(post);
              },
            ),
          ),
        // Add post button
        Positioned(
          right: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
          child: FloatingActionButton(
            onPressed: () => _showCreateEditPostDialog(),
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildPostCard(ForumModel post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post image
          if (post.photo != null && post.photo!.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                post.photo!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 180,
                  color: Colors.grey.shade200,
                  child: Icon(Icons.image, size: 48, color: Colors.grey.shade400),
                ),
              ),
            ),
          // Post content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Content text (strip HTML)
                if (post.content != null && post.content!.isNotEmpty)
                  Text(
                    _stripHtml(post.content!),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                      height: 1.5,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 12),
                // Date and actions
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(post.createdAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.favorite, size: 14, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      '${post.likesCount ?? 0}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                    const Spacer(),
                    // Edit button
                    GestureDetector(
                      onTap: () => _showCreateEditPostDialog(post: post),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.edit, size: 18, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Delete button
                    GestureDetector(
                      onTap: () => _deletePost(post.id),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.delete, size: 18, color: Colors.red.shade400),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}

// Create/Edit Post Sheet
class CreateEditPostSheet extends StatefulWidget {
  final ForumModel? post;
  final int userId;
  final VoidCallback onSuccess;

  const CreateEditPostSheet({
    super.key,
    this.post,
    required this.userId,
    required this.onSuccess,
  });

  @override
  State<CreateEditPostSheet> createState() => _CreateEditPostSheetState();
}

class _CreateEditPostSheetState extends State<CreateEditPostSheet> {
  final TextEditingController _contentController = TextEditingController();
  String? _photoUrl;
  File? _selectedImage;
  bool _isUploading = false;
  bool _isSaving = false;

  bool get isEditing => widget.post != null;

  @override
  void initState() {
    super.initState();
    if (widget.post != null) {
      _contentController.text = _stripHtml(widget.post!.content ?? '');
      _photoUrl = widget.post!.photo;
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .trim();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final formData = FormData.fromMap({
        'title': 'post_${DateTime.now().millisecondsSinceEpoch}',
        'image': await MultipartFile.fromFile(
          _selectedImage!.path,
          filename: 'post_image.jpg',
        ),
      });

      final response = await DioNetwork.appAPI.post(
        ApiConst.imageUpload,
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _photoUrl = response.data['image'] as String;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${context.tr('image_upload_error')}: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _savePost() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('content_required')), backgroundColor: Colors.orange),
      );
      return;
    }

    if (ContentFilter().containsObjectionableContent(_contentController.text)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('content_filtered_warning')),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final data = {
        'author': widget.userId,
        'title': 'from Jaidem App',
        'content': _contentController.text.trim(),
        'photo': _photoUrl ?? '',
        'is_publish': false,
      };

      Response response;
      if (isEditing) {
        response = await DioNetwork.appAPI.patch(
          '${ApiConst.forum}${widget.post!.id}/',
          data: data,
        );
      } else {
        response = await DioNetwork.appAPI.post(ApiConst.forum, data: data);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        widget.onSuccess();
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEditing ? context.tr('post_updated') : context.tr('post_created')),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${context.tr('error')}: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isEditing ? Icons.edit_note_rounded : Icons.add_box_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? context.tr('edit_post') : context.tr('new_post'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isEditing ? context.tr('update_post_hint') : context.tr('share_thoughts'),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close_rounded, size: 20, color: Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo section
                  Row(
                    children: [
                      Icon(Icons.photo_library_outlined, size: 18, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Text(
                        context.tr('photo'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const Spacer(),
                      if (_photoUrl != null || _selectedImage != null)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _photoUrl = null;
                              _selectedImage = null;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, size: 14, color: Colors.red.shade400),
                                const SizedBox(width: 4),
                                Text(
                                  context.tr('delete'),
                                  style: TextStyle(fontSize: 12, color: Colors.red.shade400),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _isUploading ? null : _pickImage,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: _selectedImage != null || (_photoUrl != null && _photoUrl!.isNotEmpty) ? 160 : 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _isUploading ? AppColors.primary : Colors.grey.shade200,
                          width: _isUploading ? 2 : 1,
                        ),
                      ),
                      child: _isUploading
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  context.tr('uploading'),
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                ),
                              ],
                            )
                          : _selectedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.file(_selectedImage!, fit: BoxFit.cover, width: double.infinity),
                                )
                              : _photoUrl != null && _photoUrl!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.network(_photoUrl!, fit: BoxFit.cover, width: double.infinity),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withValues(alpha: 0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(Icons.add_photo_alternate_outlined,
                                              size: 24, color: AppColors.primary),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              context.tr('add_photo'),
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                            Text(
                                              context.tr('select_from_gallery'),
                                              style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Content section
                  Row(
                    children: [
                      Icon(Icons.text_fields_rounded, size: 18, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Text(
                        context.tr('content_label'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextField(
                      controller: _contentController,
                      maxLines: 5,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                      decoration: InputDecoration(
                        hintText: context.tr('write_thoughts'),
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
            // Save button
            Container(
              padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: _isSaving ? null : _savePost,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _isSaving
                          ? [Colors.grey.shade400, Colors.grey.shade500]
                          : [AppColors.primary, AppColors.primary.shade600],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: _isSaving
                        ? []
                        : [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isSaving)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      else
                        Icon(isEditing ? Icons.check_rounded : Icons.send_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        _isSaving ? context.tr('saving') : (isEditing ? context.tr('save') : context.tr('publish')),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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

// Delete Account Confirmation Dialog
Future<bool?> showDeleteAccountDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red.shade400, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.tr('delete_account_title'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('delete_account_description'),
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5),
          ),
          const SizedBox(height: 16),
          Text(
            context.tr('delete_account_confirm'),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(context.tr('cancel'), style: TextStyle(color: Colors.grey.shade600)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade500,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(context.tr('yes_delete')),
        ),
      ],
    ),
  );
}
