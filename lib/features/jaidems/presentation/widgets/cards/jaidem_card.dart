import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/jaidems/domain/entities/jaidem_entity.dart';
import 'package:jaidem/features/jaidems/presentation/helpers/jaidem_pop_up.dart';
import 'package:jaidem/features/jaidems/presentation/widgets/buttons/jaidem_action_buttons.dart';
import 'package:jaidem/features/jaidems/presentation/widgets/fields/rating_field.dart';
import 'package:jaidem/features/jaidems/presentation/widgets/layouts/jaidem_details.dart';
import 'package:jaidem/features/jaidems/presentation/widgets/layouts/jaidem_image_viewer.dart';

class JaidemCard extends StatefulWidget {
  const JaidemCard({
    super.key,
    required this.person,
  });

  final JaidemEntity person;

  @override
  State<JaidemCard> createState() => _JaidemCardState();
}

class _JaidemCardState extends State<JaidemCard> with JaidemPopUp {
  @override
  Widget build(BuildContext context) {
    final bool showRating = true;
    return GestureDetector(
      onTap: () => showJaidemDetails(widget.person),
      child: Container(
        height: 375,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Profile Image Section
            JaidemImageViewer(imageUrl: widget.person.avatar),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Rating Row
                  _buildNameAndRating(widget.person, context),

                  const SizedBox(height: 10),

                  // Star Rating
                  if (showRating) RatingField(rating: 2),

                  const SizedBox(height: 10),

                  // Information Fields
                  JaidemDetails(
                    speciality: widget.person.speciality,
                    interest: widget.person.interest,
                    phone: widget.person.phone ?? 'Не указан',
                    email: widget.person.email ?? 'Не указан',
                    university: widget.person.university,
                  ),

                  const SizedBox(height: 20),

                  // Social Media and Profile Button Row
                  JaidemActionButtons()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameAndRating(JaidemEntity model, BuildContext context) {
    return Row(
      children: [
        // Online indicator dot
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 8),

        // Name
        Expanded(
          child: Text(
            model.fullname ?? '',
            style: context.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Rating badge
        if (true)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '1.7',
              style: context.textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
