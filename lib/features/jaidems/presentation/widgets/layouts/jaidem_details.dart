import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';

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
        _buildInfoField(
          'Спец/профессия/должность:',
          speciality,
          context,
        ),
        _buildInfoField(
          'Интересы/Навыки/Хобби:',
          interest,
          context,
        ),
        _buildInfoField('Телефон:', phone, context),
        _buildInfoField('Email:', email, context),
        _buildInfoField('Университет:', university, context),
      ],
    );
  }
}

Widget _buildInfoField(String label, String value, BuildContext context) {
  return RichText(
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    textHeightBehavior: TextHeightBehavior(
      applyHeightToFirstAscent: false,
      applyHeightToLastDescent: false,
    ),
    text: TextSpan(
      style: DefaultTextStyle.of(context).style,
      children: [
        TextSpan(
          text: label,
          style: context.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.grey,
          ),
        ),
        const TextSpan(text: ' '),
        TextSpan(
          text: value,
          style: context.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ],
    ),
  );
}
