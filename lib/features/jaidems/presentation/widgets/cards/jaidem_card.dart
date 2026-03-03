import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jaidem/core/data/injection.dart';
import 'package:jaidem/core/data/models/jaidem/person_model.dart';
import 'package:jaidem/core/data/services/contact_service.dart';
import 'package:jaidem/core/routes/app_router.dart';
import 'package:jaidem/core/utils/constants/app_constants.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/menu/data/datasources/menu_remote_datasource.dart';
import 'package:jaidem/features/profile/presentation/widgets/birthday_congrats_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JaidemCard extends StatelessWidget {
  const JaidemCard({
    super.key,
    required this.person,
  });

  final PersonModel person;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.router.push(JaidemDetailRoute(person: person));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image with gradient overlay
            _buildProfileImage(),

            // Content Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and Flow Badge
                    _buildNameSection(),

                    const SizedBox(height: 8),

                    // Details
                    Expanded(
                      child: _buildDetailsSection(context),
                    ),

                    const SizedBox(height: 8),

                    // Action Buttons
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      children: [
        Container(
          height: 130,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5F5),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: person.avatar != null
                ? Image.network(
                    person.avatar!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildPlaceholderImage(),
                  )
                : _buildPlaceholderImage(),
          ),
        ),
        // Gradient overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.3),
                ],
              ),
            ),
          ),
        ),
        // Flow badge
        if (person.flow.name.isNotEmpty)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.shade400,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'Агым ${person.flow.name}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        // Birthday badge
        if (isTodayBirthday(person.birthday))
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text('🎂', style: TextStyle(fontSize: 14)),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.person_rounded,
          size: 48,
          color: AppColors.primary.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildNameSection() {
    return Text(
      person.fullname ?? 'Белгисиз',
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
        height: 1.2,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final items = <Widget>[];

    // Use spec object first, fallback to speciality string
    final specName = person.spec?.getLocalizedName(locale) ?? person.speciality;
    if (specName != null && specName.isNotEmpty) {
      items.add(_buildDetailItem(
        Icons.work_outline_rounded,
        specName,
      ));
    }

    // Use univer object first, fallback to university string
    final univerName = person.univer?.getLocalizedName(locale) ?? person.university;
    if (univerName != null && univerName.isNotEmpty) {
      items.add(_buildDetailItem(
        Icons.school_outlined,
        univerName,
        maxLines: 2,
      ));
    }

    final stateName = person.state.getLocalizedName(locale);
    if (stateName.isNotEmpty) {
      items.add(_buildDetailItem(
        Icons.location_on_outlined,
        stateName,
      ));
    }

    if (items.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.take(3).toList(),
    );
  }

  Widget _buildDetailItem(IconData icon, String text, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: maxLines > 1 ? 2 : 0),
            child: Icon(
              icon,
              size: 12,
              color: AppColors.primary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
                height: 1.2,
              ),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Write message button
        _buildWriteButton(),
        const SizedBox(width: 12),
        // WhatsApp button
        _buildSocialButton(
          'assets/icons/whatsapp.png',
          () {
            final whatsapp = person.socialMedias?['whatsapp'];
            if (whatsapp != null && whatsapp.isNotEmpty) {
              ContactService().openWhatsapp(whatsapp);
            }
          },
        ),
        const SizedBox(width: 12),
        // Instagram button
        _buildSocialButton(
          'assets/icons/insta.png',
          () {
            final instagram = person.socialMedias?['instagram'];
            if (instagram != null && instagram.isNotEmpty) {
              ContactService().openInstagram(instagram);
            }
          },
        ),
      ],
    );
  }

  Widget _buildWriteButton() {
    return Builder(
      builder: (context) {
        return GestureDetector(
          onTap: () async {
            HapticFeedback.lightImpact();
            final currentUserId =
                sl<SharedPreferences>().getString(AppConstants.userId) ?? '';

            if (currentUserId == person.id.toString()) {
              context.router.replaceAll([BottomBarRoute(initialIndex: 4)]);
              return;
            }

            await sl<MenuRemoteDatasource>().ensureUserExists(
              id: person.id.toString(),
              name: person.fullname ?? 'User',
              photoUrl: person.avatar,
            );

            if (!context.mounted) return;

            context.router.push(
              ChatRoute(
                chatType: 'users',
                userId: person.id.toString(),
                userName: person.fullname,
                userAvatar: person.avatar,
              ),
            );
          },
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                Icons.message_rounded,
                size: 16,
                color: AppColors.primary,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSocialButton(String assetPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Image.asset(
            assetPath,
            width: 16,
            height: 16,
          ),
        ),
      ),
    );
  }
}
