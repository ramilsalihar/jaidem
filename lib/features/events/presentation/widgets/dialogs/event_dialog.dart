import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/core/widgets/buttons/app_button.dart';
import 'package:jaidem/core/widgets/fields/app_text_form_field.dart';

mixin EventDialog<T extends StatefulWidget> on State<T> {
  void showEventDialog({
    required Function(String?) onConfirm,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final controller = TextEditingController();
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  'Укажите причину почему не придете на мероприятие',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w300,
                      ),
                  textAlign: TextAlign.center,
                ),

                // Text Field
                AppTextFormField(
                  label: '',
                  hintText: 'Ваша причина',
                  controller: controller,
                  maxLines: 5,
                ),
                const SizedBox(height: 20),

                // Confirm Button
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    text: 'Отправить',
                    borderRadius: 10,
                    onPressed: () {
                      Navigator.of(context).pop();
                      onConfirm(controller.text);
                    },
                    backgroundColor: AppColors.primary,
                    textColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),

                // Cancel Button
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    text: 'Отменить',
                    borderRadius: 10,
                    isOutlined: true,
                    onPressed: () {
                      Navigator.of(context).pop();
                      onConfirm(null);
                    },
                    backgroundColor: Colors.transparent,
                    textColor: AppColors.primary,
                    borderColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
