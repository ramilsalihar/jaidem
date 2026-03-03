import 'package:flutter/material.dart';
import 'package:jaidem/core/data/models/jaidem/person_model.dart';
import 'package:jaidem/core/localization/app_localizations.dart';
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
            label: context.tr('label_age'),
            value: person.calculatedAge?.toString() ?? context.tr('no_data'),
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
            label: context.tr('label_course_year'),
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
            label: context.tr('label_specialty'),
            value: person.spec?.getLocalizedName(Localizations.localeOf(context).languageCode) ?? person.speciality ?? '',
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
            label: context.tr('label_region'),
            value: person.region?.getLocalizedName(Localizations.localeOf(context).languageCode) ?? '',
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
            label: context.tr('label_village_city'),
            value: person.village?.getLocalizedName(Localizations.localeOf(context).languageCode) ?? '',
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
            label: context.tr('label_interests_skills'),
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
            label: context.tr('label_phone'),
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
            label: context.tr('label_email'),
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
