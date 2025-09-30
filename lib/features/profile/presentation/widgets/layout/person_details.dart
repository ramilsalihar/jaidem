import 'package:flutter/material.dart';
import 'package:jaidem/core/data/models/jaidem/person_model.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/core/widgets/fields/details_text_field.dart';

class PersonDetails extends StatelessWidget {
  const PersonDetails({
    super.key,
    required this.person,
  });

  final PersonModel person;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          DetailsTextField(
            label: 'Возраст:',
            value: person.age.toString(),
            hasSpace: true,
            labelWidth: 150,
            labelStyle: context.textTheme.bodySmall?.copyWith(
              color: AppColors.grey,
            ),
            valueStyle: context.textTheme.bodySmall?.copyWith(
              color: AppColors.black,
            ),
          ),
          DetailsTextField(
            label: 'Год обучения:',
            value: person.courseYear.toString(),
            hasSpace: true,
            labelWidth: 150,
            labelStyle: context.textTheme.bodySmall?.copyWith(
              color: AppColors.grey,
            ),
            valueStyle: context.textTheme.bodySmall?.copyWith(
              color: AppColors.black,
            ),
          ),
          DetailsTextField(
            label: 'Специальность:',
            value: person.speciality ?? '',
            hasSpace: true,
            labelWidth: 150,
            labelStyle: context.textTheme.bodySmall?.copyWith(
              color: AppColors.grey,
            ),
            valueStyle: context.textTheme.bodySmall?.copyWith(
              color: AppColors.black,
            ),
          ),
          DetailsTextField(
            label: 'Регион:',
            value: person.region?.name ?? '',
            hasSpace: true,
            labelWidth: 150,
            labelStyle: context.textTheme.bodySmall?.copyWith(
              color: AppColors.grey,
            ),
            valueStyle: context.textTheme.bodySmall?.copyWith(
              color: AppColors.black,
            ),
          ),
          DetailsTextField(
            label: 'Село/город:',
            value: person.village?.name ?? '',
            hasSpace: true,
            labelWidth: 150,
            labelStyle: context.textTheme.bodySmall?.copyWith(
              color: AppColors.grey,
            ),
            valueStyle: context.textTheme.bodySmall?.copyWith(
              color: AppColors.black,
            ),
          ),
          DetailsTextField(
            label: 'Интересы/навыки:',
            value: person.interest ?? '',
            hasSpace: true,
            labelWidth: 150,
            labelStyle: context.textTheme.bodySmall?.copyWith(
              color: AppColors.grey,
            ),
            valueStyle: context.textTheme.bodySmall?.copyWith(
              color: AppColors.black,
            ),
          ),
          DetailsTextField(
            label: 'Телефон:',
            value: person.phone ?? '',
            hasSpace: true,
            labelWidth: 150,
            labelStyle: context.textTheme.bodySmall?.copyWith(
              color: AppColors.grey,
            ),
            valueStyle: context.textTheme.bodySmall?.copyWith(
              color: AppColors.black,
            ),
          ),
          DetailsTextField(
            label: 'Email:',
            value: person.email ?? '',
            hasSpace: true,
            labelWidth: 150,
            labelStyle: context.textTheme.bodySmall?.copyWith(
              color: AppColors.grey,
            ),
            valueStyle: context.textTheme.bodySmall?.copyWith(
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}
