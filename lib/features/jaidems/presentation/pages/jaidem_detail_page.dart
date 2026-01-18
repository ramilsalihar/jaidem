import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jaidem/core/data/models/jaidem/person_model.dart';
import 'package:jaidem/core/data/services/contact_service.dart';
import 'package:jaidem/core/localization/app_localizations.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class JaidemDetailPage extends StatelessWidget {
  const JaidemDetailPage({super.key, required this.person});

  final PersonModel person;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Header with gradient and avatar
            _buildHeader(context),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  // Stats Row
                  _buildStatsRow(context),

                  const SizedBox(height: 24),

                  // Quick Actions
                  _buildQuickActions(context),

                  const SizedBox(height: 24),

                  // About Section
                  if (person.aboutMe != null && person.aboutMe!.isNotEmpty)
                    _buildAboutSection(context),

                  // Info List
                  _buildInfoList(context),

                  const SizedBox(height: 24),

                  // Contact Section
                  _buildContactSection(context),

                  SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
            // Top bar with back button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    context.tr('profile'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Avatar
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 3,
                ),
              ),
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white24,
                ),
                child: ClipOval(
                  child: person.avatar != null && person.avatar!.isNotEmpty
                      ? Image.network(
                          person.avatar!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                        )
                      : _buildDefaultAvatar(),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                person.fullname ?? context.tr('unknown'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 6),

            // Specialty
            if (person.speciality != null && person.speciality!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  person.speciality!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            const SizedBox(height: 16),

            // Tags
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  if (person.flow.name.isNotEmpty)
                    _buildTag('${context.tr('flow')} ${person.flow.name}'),
                  if (person.generation != null && person.generation!.isNotEmpty)
                    _buildTag(person.generation!),
                  if (person.state.nameKg != null && person.state.nameKg!.isNotEmpty)
                    _buildTag(person.state.nameKg!),
                ],
              ),
            ),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    final initial = (person.fullname?.isNotEmpty ?? false)
        ? person.fullname![0].toUpperCase()
        : 'U';
    return Container(
      color: Colors.white24,
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Age
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _buildStatItem('${person.age}', context.tr('age')),
          ),
          Container(
            width: 1,
            height: 36,
            color: Colors.grey.shade300,
          ),
          // Course year
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _buildStatItem('${person.courseYear}', context.tr('course_year')),
          ),
          if (person.university != null && person.university!.isNotEmpty) ...[
            Container(
              width: 1,
              height: 36,
              color: Colors.grey.shade300,
            ),
            // University - expanded to take remaining space
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _buildUniversityItem(person.university!, context.tr('university')),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade800,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildUniversityItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final hasWhatsApp = person.socialMedias?['whatsapp']?.isNotEmpty ?? false;
    final hasInstagram = person.socialMedias?['instagram']?.isNotEmpty ?? false;
    final hasPhone = person.phone?.isNotEmpty ?? false;

    if (!hasWhatsApp && !hasInstagram && !hasPhone) {
      return const SizedBox();
    }

    return Row(
      children: [
        if (hasWhatsApp)
          Expanded(
            child: _buildActionButton(
              icon: 'assets/icons/whatsapp.png',
              label: 'WhatsApp',
              color: const Color(0xFF25D366),
              onTap: () {
                HapticFeedback.lightImpact();
                ContactService().openWhatsapp(person.socialMedias!['whatsapp']!);
              },
            ),
          ),
        if (hasWhatsApp && (hasInstagram || hasPhone))
          const SizedBox(width: 12),
        if (hasInstagram)
          Expanded(
            child: _buildActionButton(
              icon: 'assets/icons/insta.png',
              label: 'Instagram',
              color: const Color(0xFFE4405F),
              onTap: () {
                HapticFeedback.lightImpact();
                ContactService().openInstagram(person.socialMedias!['instagram']!);
              },
            ),
          ),
        if (hasInstagram && hasPhone)
          const SizedBox(width: 12),
        if (hasPhone)
          Expanded(
            child: _buildActionButton(
              iconData: Icons.phone_rounded,
              label: context.tr('call'),
              color: AppColors.primary,
              onTap: () {
                HapticFeedback.lightImpact();
                ContactService().callToPhone(person.phone!);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton({
    String? icon,
    IconData? iconData,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Image.asset(
                icon,
                width: 20,
                height: 20,
              )
            else
              Icon(iconData, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.format_quote_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                context.tr('about_me'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              person.aboutMe!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoList(BuildContext context) {
    final items = <_InfoItem>[];

    if (person.region?.nameKg != null && person.region!.nameKg!.isNotEmpty) {
      items.add(_InfoItem(Icons.map_outlined, context.tr('district'), person.region!.nameKg!));
    }
    if (person.village != null && person.village!.name.isNotEmpty) {
      items.add(_InfoItem(Icons.location_city_outlined, context.tr('village'), person.village!.name));
    }
    if (person.interest != null && person.interest!.isNotEmpty) {
      items.add(_InfoItem(Icons.favorite_outline_rounded, context.tr('interests'), person.interest!));
    }
    if (person.skills != null && person.skills!.isNotEmpty) {
      items.add(_InfoItem(Icons.psychology_outlined, context.tr('skills'), person.skills!));
    }

    // Social media info
    final whatsapp = person.socialMedias?['whatsapp'];
    final instagram = person.socialMedias?['instagram'];
    if (whatsapp != null && whatsapp.isNotEmpty) {
      items.add(_InfoItem(Icons.chat_outlined, 'WhatsApp', whatsapp));
    }
    if (instagram != null && instagram.isNotEmpty) {
      items.add(_InfoItem(Icons.camera_alt_outlined, 'Instagram', instagram));
    }

    if (items.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: AppColors.primary,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              context.tr('information'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...items.map((item) => _buildInfoRow(item)),
      ],
    );
  }

  Widget _buildInfoRow(_InfoItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              item.icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                    height: 1.4,
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
    final hasPhone = person.phone != null && person.phone!.isNotEmpty;
    final hasEmail = person.email != null && person.email!.isNotEmpty;

    if (!hasPhone && !hasEmail) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.contact_phone_outlined,
              color: AppColors.primary,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              context.tr('contact'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (hasPhone)
          _buildContactRow(
            icon: Icons.phone_rounded,
            label: context.tr('phone'),
            value: person.phone!,
            color: AppColors.primary,
            onTap: () {
              HapticFeedback.lightImpact();
              ContactService().callToPhone(person.phone!);
            },
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
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.08),
              color.withValues(alpha: 0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
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
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 18,
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
