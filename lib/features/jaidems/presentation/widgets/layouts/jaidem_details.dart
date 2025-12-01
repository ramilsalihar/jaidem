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
    final List<Widget> items = [];

    void addField(String value, String label) {
      if (value.isNotEmpty && value.trim() != "") {
        items.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: DetailsTextField(
              label: label,
              value: value,
            ),
          ),
        );
      }
    }

    speciality.isEmpty ? null : addField(speciality, 'Адис/кесип/кызмат орду:');
    email.isEmpty ? null : addField(email, 'Email:');
    university.isEmpty ? null : addField(university, 'Университет:');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items,
    );
  }
}
