import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/core/widgets/buttons/app_button.dart';
import 'package:jaidem/core/widgets/fields/app_text_form_field.dart';

@RoutePage()
class AddGoalPage extends StatelessWidget {
  const AddGoalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Text(
          'Новая задача',
          style: context.textTheme.headlineMedium,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const Divider(
              height: 50,
              color: AppColors.grey,
            ),
            AppTextFormField(
              label: 'Название задачи',
              hintText: 'Выучить 20 слов',
              controller: TextEditingController(),
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              label: 'Время с',
              hintText: '',
              readOnly: true,
              trailing: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.access_time),
              ),
              controller: TextEditingController(text: '15:00'),
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              label: 'Время до',
              hintText: '',
              readOnly: true,
              trailing: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.access_time),
              ),
              controller: TextEditingController(text: '16:00'),
            ),
            const SizedBox(height: 16),
            AppTextFormField(
              label: 'Напоминание',
              hintText: 'Утром 09:00',
              controller: TextEditingController(),
            ),
            const SizedBox(height: 20),
             Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Сохранить',
                    borderRadius: 10,
                    padding: EdgeInsets.zero,
                    onPressed: (){},
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppButton(
                    text: 'Отменить',
                    isOutlined: true,
                    borderRadius: 10,
                    padding: EdgeInsets.zero,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
