import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/core/widgets/buttons/app_button.dart';
import 'package:jaidem/core/widgets/fields/app_text_form_field.dart';

@RoutePage()
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final currentPass = TextEditingController();
  final newPass = TextEditingController();
  final confirmPass = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Text(
          'Сменить пароль',
          style: context.textTheme.headlineLarge,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const Divider(
              height: 50,
              color: AppColors.grey,
            ),
            AppTextFormField(
              label: 'Текущий пароль',
              hintText: 'Введите текущий пароль',
              controller: currentPass,
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              label: 'Новый пароль',
              hintText: 'Введите новый пароль',
              controller: newPass,
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              label: 'Подтвердите новый пароль',
              hintText: 'Введите новый пароль',
              controller: confirmPass,
            ),
            const SizedBox(height: kToolbarHeight),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Сохранить',
                    borderRadius: 10,
                    padding: EdgeInsets.zero,
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppButton(
                    text: 'Отменить',
                    isOutlined: true,
                    borderRadius: 10,
                    padding: EdgeInsets.zero,
                    onPressed: () => context.router.pop(),
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
