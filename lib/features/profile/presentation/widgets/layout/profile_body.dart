import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:jaidem/core/data/models/jaidem/person_model.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';

class ProfileBody extends StatelessWidget {
  const ProfileBody({
    super.key,
    required this.person,
    this.canEdit,
  });

  final PersonModel person;
  final bool? canEdit;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            context.router.pushPath('/profile/edit');
          },
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
                person.aboutMe ?? 'Нету данных',
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
