import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jaidem/core/data/models/jaidem/person_model.dart';
import 'package:jaidem/core/data/services/contact_service.dart';
import 'package:jaidem/core/routes/app_router.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

mixin JaidemPopUp<T extends StatefulWidget> on State<T> {
  void showJaidemDetails(PersonModel person) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return _JaidemDetailsSheet(person: person);
      },
    );
  }
}

class _JaidemDetailsSheet extends StatelessWidget {
  const _JaidemDetailsSheet({required this.person});

  final PersonModel person;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Content
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Header with gradient background
                  _buildHeroHeader(context),

                  // Quick Actions
                  _buildQuickActions(context),

                  const SizedBox(height: 20),

                  // Info Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildInfoCards(context),
                  ),

                  const SizedBox(height: 20),

                  // Contact Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildContactSection(context),
                  ),

                  const SizedBox(height: 24),

                  // View Profile Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildProfileButton(context),
                  ),

                  SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.shade700,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar with border
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white24,
                  ),
                  child: person.avatar != null
                      ? ClipOval(
                          child: Image.network(
                            person.avatar!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                          ),
                        )
                      : _buildDefaultAvatar(),
                ),
              ),

              const SizedBox(width: 16),

              // Name and info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.fullname ?? 'Белгисиз',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildHeaderChip(
                          'Агым ${person.flow.name}',
                          Icons.stream_rounded,
                        ),
                        if (person.generation != null) ...[
                          const SizedBox(width: 8),
                          _buildHeaderChip(
                            person.generation!,
                            Icons.group_outlined,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Stats row
          if (person.age != null ||
              person.university != null ||
              person.state.nameKg != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (person.age != null)
                    _buildStatItem('${person.age}', 'жаш'),
                  if (person.age != null &&
                      (person.university != null ||
                          person.state.nameKg != null))
                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.white24,
                    ),
                  if (person.university != null &&
                      person.university!.isNotEmpty)
                    Expanded(
                      child: _buildStatItem(
                        person.university!.length > 15
                            ? '${person.university!.substring(0, 15)}...'
                            : person.university!,
                        'окуу жайы',
                      ),
                    ),
                  if (person.university != null &&
                      person.state.nameKg != null &&
                      person.state.nameKg!.isNotEmpty)
                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.white24,
                    ),
                  if (person.state.nameKg != null &&
                      person.state.nameKg!.isNotEmpty)
                    _buildStatItem(
                      person.state.nameKg!.length > 12
                          ? '${person.state.nameKg!.substring(0, 12)}...'
                          : person.state.nameKg!,
                      'облус',
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.white.withValues(alpha: 0.9),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    final initial = (person.fullname?.isNotEmpty ?? false)
        ? person.fullname![0].toUpperCase()
        : 'U';
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final hasWhatsApp = person.socialMedias?['whatsapp']?.isNotEmpty ?? false;
    final hasInstagram = person.socialMedias?['instagram']?.isNotEmpty ?? false;
    final hasPhone = person.phone?.isNotEmpty ?? false;
    final hasEmail = person.email?.isNotEmpty ?? false;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (hasWhatsApp)
            _buildQuickActionButton(
              icon: 'assets/icons/whatsapp.png',
              label: 'WhatsApp',
              color: const Color(0xFF25D366),
              onTap: () {
                HapticFeedback.lightImpact();
                ContactService().openWhatsapp(person.socialMedias!['whatsapp']!);
              },
            ),
          if (hasInstagram)
            _buildQuickActionButton(
              icon: 'assets/icons/insta.png',
              label: 'Instagram',
              color: const Color(0xFFE4405F),
              onTap: () {
                HapticFeedback.lightImpact();
                ContactService().openInstagram(person.socialMedias!['instagram']!);
              },
            ),
          if (hasPhone)
            _buildQuickActionButton(
              iconData: Icons.phone_rounded,
              label: 'Чалуу',
              color: AppColors.primary,
              onTap: () {
                HapticFeedback.lightImpact();
                ContactService().callToPhone(person.phone!);
              },
            ),
          if (hasEmail)
            _buildQuickActionButton(
              iconData: Icons.email_rounded,
              label: 'Email',
              color: Colors.orange,
              onTap: () async {
                HapticFeedback.lightImpact();
                final url = Uri.parse('mailto:${person.email!}');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    String? icon,
    IconData? iconData,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: icon != null
                    ? Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(icon),
                      )
                    : Icon(iconData, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCards(BuildContext context) {
    final infoItems = <_InfoCardData>[];

    if (person.speciality != null && person.speciality!.isNotEmpty) {
      infoItems.add(_InfoCardData(
        icon: Icons.work_outline_rounded,
        title: 'Адистик',
        value: person.speciality!,
        color: Colors.blue,
      ));
    }

    if (person.courseYear != null) {
      infoItems.add(_InfoCardData(
        icon: Icons.calendar_today_rounded,
        title: 'Окуу жылы',
        value: '${person.courseYear}-жыл',
        color: Colors.purple,
      ));
    }

    if (person.region?.nameKg != null && person.region!.nameKg!.isNotEmpty) {
      infoItems.add(_InfoCardData(
        icon: Icons.location_on_rounded,
        title: 'Район',
        value: person.region!.nameKg!,
        color: Colors.teal,
      ));
    }

    if (person.interest != null && person.interest!.isNotEmpty) {
      infoItems.add(_InfoCardData(
        icon: Icons.favorite_rounded,
        title: 'Кызыкчылыктар',
        value: person.interest!,
        color: Colors.pink,
      ));
    }

    if (person.skills != null && person.skills!.isNotEmpty) {
      infoItems.add(_InfoCardData(
        icon: Icons.psychology_rounded,
        title: 'Көндүмдөр',
        value: person.skills!,
        color: Colors.amber,
      ));
    }

    if (infoItems.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Кошумча маалымат',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...infoItems.map((item) => _buildInfoCard(item)),
      ],
    );
  }

  Widget _buildInfoCard(_InfoCardData data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  data.color.withValues(alpha: 0.15),
                  data.color.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              data.icon,
              color: data.color,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    final hasPhone = person.phone != null && person.phone!.isNotEmpty;
    final hasEmail = person.email != null && person.email!.isNotEmpty;

    if (!hasPhone && !hasEmail) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Байланыш маалыматы',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              if (hasPhone)
                _buildContactRow(
                  icon: Icons.phone_rounded,
                  label: 'Телефон',
                  value: person.phone!,
                  color: AppColors.primary,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ContactService().callToPhone(person.phone!);
                  },
                  showDivider: hasEmail,
                ),
              if (hasEmail)
                _buildContactRow(
                  icon: Icons.email_rounded,
                  label: 'Email',
                  value: person.email!,
                  color: Colors.orange,
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    final url = Uri.parse('mailto:${person.email!}');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  },
                  showDivider: false,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required VoidCallback onTap,
    required bool showDivider,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: showDivider
              ? Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade100,
                    width: 1,
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: color,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.of(context).pop();
        context.router.push(JaidemDetailRoute(person: person));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.shade600,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 22,
            ),
            SizedBox(width: 10),
            Text(
              'Толук профилди көрүү',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(width: 6),
            Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white70,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCardData {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  _InfoCardData({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });
}
