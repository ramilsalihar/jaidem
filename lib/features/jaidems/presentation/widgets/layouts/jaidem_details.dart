import 'package:flutter/material.dart';
import 'package:jaidem/core/widgets/fields/details_text_field.dart';

class JaidemDetails extends StatelessWidget {
  const JaidemDetails({
    super.key,
    required this.speciality,
    required this.interest,
    required this.phone,
    required this.email,
    required this.university,
  });

  final String speciality;
  final String interest;
  final String phone;
  final String email;
  final String university;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DetailsTextField(
          label: 'Спец/профессия/должность:',
          value: speciality,
        ),
        // DetailsTextField(
        //   label: 'Интересы/Навыки/Хобби:',
        //   value: interest,
        // ),
        DetailsTextField(
          label: 'Email:',
          value: email,
        ),
        DetailsTextField(
          label: 'Университет:',
          value: university,
        ),
      ],
    );
  }
}
