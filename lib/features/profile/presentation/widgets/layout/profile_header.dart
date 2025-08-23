import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/core/widgets/buttons/app_button.dart';
import 'package:jaidem/core/widgets/fields/rating_field.dart';
import 'package:jaidem/core/widgets/fields/user_name_field.dart';
import 'package:jaidem/features/jaidems/presentation/widgets/buttons/jaidem_action_buttons.dart';
import 'package:jaidem/features/jaidems/presentation/widgets/fields/jaidem_text_field.dart';
import 'package:jaidem/features/profile/domain/entities/user_entity.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.person});

  final UserEntity person;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        Container(
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
                        color: AppColors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserNameField(fullname: person.fullname ?? ''),
                    RatingField(
                      rating: 2,
                      iconSize: 15,
                    ),
                    const SizedBox(height: 5),
                    JaidemTextField(
                      label: 'Спец/профессия: ',
                      value: person.speciality ?? '',
                      labelStyle: context.textTheme.bodySmall?.copyWith(
                        color: AppColors.grey,
                      ),
                      valueStyle: context.textTheme.bodySmall?.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                    JaidemTextField(
                      label: 'Униерситет: ',
                      value: person.university ?? '',
                      labelStyle: context.textTheme.bodySmall?.copyWith(
                        color: AppColors.grey,
                      ),
                      valueStyle: context.textTheme.bodySmall?.copyWith(
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
        ),
        const SizedBox(height: 20),
        Container(
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
              JaidemTextField(
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
              JaidemTextField(
                label: 'Курс:',
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
              JaidemTextField(
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
              JaidemTextField(
                label: 'Регион:',
                value: 'person.region' ?? '',
                hasSpace: true,
                labelWidth: 150,
                labelStyle: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.grey,
                ),
                valueStyle: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.black,
                ),
              ),
              JaidemTextField(
                label: 'Село/город:',
                value: 'person.city' ?? '',
                hasSpace: true,
                labelWidth: 150,
                labelStyle: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.grey,
                ),
                valueStyle: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.black,
                ),
              ),
              JaidemTextField(
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
              JaidemTextField(
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
              JaidemTextField(
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
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () {},
          child: Container(
            width: 200,
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                'Редактировать профиль',
                style: context.textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: size.width,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.barColor,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Обо мне',
                style: context.textTheme.headlineLarge?.copyWith(
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                person.fullname ?? '',
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
