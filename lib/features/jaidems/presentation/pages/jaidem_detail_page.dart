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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _isBirthday = isTodayBirthday(widget.person.birthday);
    _checkIfOwnProfile();
  }

  Future<void> _sendBirthdayReaction() async {
    if (_hasReacted || _isSendingReaction) return;
    setState(() => _isSendingReaction = true);

    final useCase = sl<SendBirthdayReactionUseCase>();
    final result = await useCase(toUserId: widget.person.id);

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
    if (currentUserId == widget.person.id.toString()) {
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

  @override
  Widget build(BuildContext context) {
    // Don't fetch forums if redirecting to own profile
    if (_isOwnProfile) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return BlocProvider(
      create: (context) => sl<ForumCubit>()..fetchAllForums(authorId: widget.person.id),
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              _buildSliverAppBar(context),
            ];
          },
          body: Column(
            children: [
              _buildTabBar(context),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPostsTab(context),
                    _buildAboutTab(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 340,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).pop();
        },
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
      actions: const [],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Cover photo
            Container(
              height: 180,
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
              child: widget.person.avatar != null
                  ? ShaderMask(
                      shaderCallback: (rect) {
                        return LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.3),
                            Colors.black.withValues(alpha: 0.1),
                          ],
                        ).createShader(rect);
                      },
                      blendMode: BlendMode.darken,
                      child: Image.network(
                        widget.person.avatar!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox(),
                      ),
                    )
                  : null,
            ),
            // Profile info card
            Positioned(
              top: 130,
              left: 16,
              right: 16,
              child: _buildProfileCard(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary.shade100,
                  backgroundImage: widget.person.avatar != null
                      ? NetworkImage(widget.person.avatar!)
                      : null,
                  child: widget.person.avatar == null
                      ? Text(
                          (widget.person.fullname?.isNotEmpty ?? false)
                              ? widget.person.fullname![0].toUpperCase()
                              : 'U',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              // Name and headline
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.person.fullname ?? context.tr('unknown'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    // Use spec object first, fallback to speciality string
                    Builder(
                      builder: (context) {
                        final specName = widget.person.spec?.name ?? widget.person.speciality;
                        if (specName != null && specName.isNotEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              specName,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 8),
                    // Tags
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (widget.person.flow.name.isNotEmpty)
                          _buildSmallTag('${context.tr('flow')} ${widget.person.flow.name}'),
                        if (widget.person.generation != null &&
                            widget.person.generation!.isNotEmpty)
                          _buildSmallTag(widget.person.generation!),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Birthday congrats button
          if (_isBirthday) ...[
            const SizedBox(height: 12),
            _buildBirthdayCongrats(context),
          ],
          const SizedBox(height: 16),
          // Quick actions
          _buildQuickActions(context),
        ],
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

  Widget _buildSmallTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final hasWhatsApp = widget.person.socialMedias?['whatsapp']?.isNotEmpty ?? false;
    final hasInstagram = widget.person.socialMedias?['instagram']?.isNotEmpty ?? false;

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
              if (currentUserId == widget.person.id.toString()) {
                context.router.replaceAll([BottomBarRoute(initialIndex: 4)]);
                return;
              }

              // Ensure target user exists in Firebase with proper data
              await sl<MenuRemoteDatasource>().ensureUserExists(
                id: widget.person.id.toString(),
                name: widget.person.fullname ?? 'User',
                photoUrl: widget.person.avatar,
              );

              if (!context.mounted) return;

              context.router.push(
                ChatRoute(
                  chatType: 'users',
                  userId: widget.person.id.toString(),
                  userName: widget.person.fullname,
                  userAvatar: widget.person.avatar,
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
                ContactService().openWhatsapp(widget.person.socialMedias!['whatsapp']!);
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
                ContactService().openInstagram(widget.person.socialMedias!['instagram']!);
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
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isPrimary ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isPrimary ? Colors.white : color, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isPrimary ? Colors.white : color,
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
                  const Icon(Icons.article_outlined, size: 18),
                  const SizedBox(width: 6),
                  Text(context.tr('posts')),
                ],
              ),
            ),
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
                    context.read<ForumCubit>().fetchAllForums(authorId: widget.person.id);
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
            await context.read<ForumCubit>().fetchAllForums(authorId: widget.person.id);
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
          // About section
          if (widget.person.aboutMe != null && widget.person.aboutMe!.isNotEmpty)
            _buildAboutSection(context),

          // Info section
          _buildInfoSection(context),

          // Contact section
          _buildContactSection(context),

          const SizedBox(height: 24),
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
            widget.person.aboutMe!,
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
    final items = <_InfoItem>[];

    // Use univer object first, fallback to university string
    final univerName = widget.person.univer?.name ?? widget.person.university;
    if (univerName != null && univerName.isNotEmpty) {
      items.add(_InfoItem(Icons.school_outlined, context.tr('university'), univerName));
    }
    if (widget.person.region?.nameKg != null && widget.person.region!.nameKg!.isNotEmpty) {
      items.add(_InfoItem(Icons.map_outlined, context.tr('district'), widget.person.region!.nameKg!));
    }
    if (widget.person.village != null && widget.person.village!.name.isNotEmpty) {
      items.add(_InfoItem(Icons.location_city_outlined, context.tr('village'), widget.person.village!.name));
    }
    if (widget.person.interest != null && widget.person.interest!.isNotEmpty) {
      items.add(_InfoItem(Icons.favorite_outline, context.tr('interests'), widget.person.interest!));
    }
    if (widget.person.skills != null && widget.person.skills!.isNotEmpty) {
      items.add(_InfoItem(Icons.psychology_outlined, context.tr('skills'), widget.person.skills!));
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

  Widget _buildContactSection(BuildContext context) {
    final hasPhone = widget.person.phone != null && widget.person.phone!.isNotEmpty;
    final hasEmail = widget.person.email != null && widget.person.email!.isNotEmpty;

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
              value: widget.person.phone!,
              onTap: () {
                HapticFeedback.lightImpact();
                ContactService().callToPhone(widget.person.phone!);
              },
            ),
          if (hasEmail)
            _buildContactRow(
              icon: Icons.email_rounded,
              value: widget.person.email!,
              onTap: () async {
                HapticFeedback.lightImpact();
                final url = Uri.parse('mailto:${widget.person.email!}');
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
