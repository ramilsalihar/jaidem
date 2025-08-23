import 'package:flutter/material.dart';
import 'package:jaidem/features/jaidems/presentation/widgets/fields/jaidem_text_field.dart';

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
        JaidemTextField(
          label: 'Спец/профессия/должность:',
          value: speciality,
        ),
        JaidemTextField(
          label: 'Интересы/Навыки/Хобби:',
          value: interest,
        ),
        JaidemTextField(
          label: 'Телефон:',
          value: phone,
        ),
        JaidemTextField(
          label: 'Email:',
          value: email,
        ),
        JaidemTextField(
          label: 'Университет:',
          value: university,
        ),
      ],
    );
  }
}
