import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/core/widgets/buttons/app_button.dart';
import 'package:jaidem/core/widgets/fields/app_text_form_field.dart';

@RoutePage()
class ProfileEditFormPage extends StatelessWidget {
  const ProfileEditFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Text(
          'Редактировать профиль',
          style: context.textTheme.headlineLarge,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            color: AppColors.grey,
            height: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          top: 16,
          bottom: kToolbarHeight,
          left: 16,
          right: 16,
        ),
        child: Column(
          children: [
            AppTextFormField(
              label: 'Дата рождения',
              hintText: 'Введите дату рождения',
              controller: TextEditingController(),
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              label: 'Университет',
              hintText: 'Манас',
              controller: TextEditingController(),
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              label: 'Курс',
              hintText: '2',
              controller: TextEditingController(),
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              label: 'Специальность',
              hintText: 'Экономика и менеджмент',
              controller: TextEditingController(),
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              label: 'Регион',
              hintText: 'Нарын',
              controller: TextEditingController(),
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              label: 'Село/город',
              hintText: 'Кайырма',
              controller: TextEditingController(),
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              label: 'Интересы',
              hintText: 'Футбол, Чтение, Програ...',
              controller: TextEditingController(),
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              label: 'Телефон',
              hintText: 'Введите номер телефона',
              controller: TextEditingController(),
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              label: 'Соц сети',
              hintText: 'Инстаграм',
              controller: TextEditingController(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Сохранить',
                    borderRadius: 6,
                    backgroundColor: AppColors.primary.shade300,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppButton(
                    text: 'Отменить',
                    borderRadius: 6,
                    isOutlined: true,
                    textColor: AppColors.primary.shade300,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
