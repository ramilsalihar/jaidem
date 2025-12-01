import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:jaidem/core/data/models/jaidem/person_model.dart';
import 'package:jaidem/core/routes/app_router.dart';
import 'package:jaidem/core/widgets/fields/user_name_field.dart';
import 'package:jaidem/features/jaidems/presentation/helpers/jaidem_pop_up.dart';
import 'package:jaidem/features/jaidems/presentation/widgets/buttons/jaidem_action_buttons.dart';
import 'package:jaidem/features/jaidems/presentation/widgets/layouts/jaidem_details.dart';
import 'package:jaidem/features/jaidems/presentation/widgets/layouts/jaidem_image_viewer.dart';

class JaidemCard extends StatefulWidget {
  const JaidemCard({
    super.key,
    required this.person,
  });

  final PersonModel person;

  @override
  State<JaidemCard> createState() => _JaidemCardState();
}

class _JaidemCardState extends State<JaidemCard> with JaidemPopUp {
  @override
  Widget build(BuildContext context) {
    const bool showRating = true;

    return GestureDetector(
      onTap: () => showJaidemDetails(widget.person),
      child: Container(
        height: 350,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            /// Profile Image
            JaidemImageViewer(imageUrl: widget.person.avatar),

            /// Content Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Name
                    UserNameField(fullname: widget.person.fullname ?? ''),

                    const SizedBox(height: 10),

                    /// Rating — if needed
                    // if (showRating) RatingField(rating: 2),
                    // const SizedBox(height: 10),

                    /// Details (take remaining space)
                    Expanded(
                      child: JaidemDetails(
                        speciality: widget.person.speciality ?? '',
                        interest: widget.person.interest ?? '',
                        phone: widget.person.phone ?? 'Не указан',
                        email: widget.person.email ?? 'Не указан',
                        
                        university: widget.person.university ?? '',
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// Buttons
                    JaidemActionButtons(
                      instagram: widget.person.socialMedias?['instagram'],
                      whatsapp: widget.person.socialMedias?['whatsapp'],
                      onTap: () {
                        context.router.push(ProfileRoute(person: widget.person));
                      },
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
