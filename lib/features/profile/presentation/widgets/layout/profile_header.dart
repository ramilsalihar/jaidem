
import 'package:flutter/material.dart';
import 'package:jaidem/core/data/models/jaidem/person_model.dart';
import 'package:jaidem/features/profile/presentation/widgets/layout/person_details.dart';
import 'package:jaidem/features/profile/presentation/widgets/layout/person_short_info.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.person});

  final PersonModel person;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PersonShortInfo(
          person: person,
        ),
        const SizedBox(height: 20),
        PersonDetails(person: person),
        const SizedBox(height: 20),
      ],
    );
  }
}
