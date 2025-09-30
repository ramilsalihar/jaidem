import 'package:flutter/material.dart';
import 'package:jaidem/core/data/models/jaidem/person_model.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/core/widgets/fields/details_text_field.dart';
import 'package:jaidem/core/widgets/fields/user_name_field.dart';
import 'package:jaidem/features/jaidems/presentation/widgets/buttons/jaidem_action_buttons.dart';

class PersonShortInfo extends StatelessWidget {
  const PersonShortInfo({super.key, required this.person});

  final PersonModel person;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          (person.avatar != null &&
                  person.avatar!.isNotEmpty &&
                  person.avatar!.startsWith('http'))
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    person.avatar!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                )
              : Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: AppColors.primary,
                  ),
                ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserNameField(fullname: person.fullname ?? ''),
                // RatingField(
                //   rating: 2,
                //   iconSize: 15,
                // ),
                const SizedBox(height: 5),
                DetailsTextField(
                  label: 'Спец/профессия: ',
                  value: person.speciality ?? '',
                  labelStyle: context.textTheme.labelMedium?.copyWith(
                    color: AppColors.grey,
                  ),
                  valueStyle: context.textTheme.labelMedium?.copyWith(
                    color: AppColors.black,
                  ),
                ),
                DetailsTextField(
                  label: 'Униерситет: ',
                  value: person.university ?? '',
                  labelStyle: context.textTheme.labelMedium?.copyWith(
                    color: AppColors.grey,
                  ),
                  valueStyle: context.textTheme.labelMedium?.copyWith(
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 10),
                JaidemActionButtons(
                  hasTrailingButton: false,
                  iconSize: 20,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
