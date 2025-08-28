import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/core/widgets/buttons/app_button.dart';

mixin EventDialogs<State extends StatefulWidget> {
  void showSkipEvent(BuildContext context) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Укажите причину почему не придете на мероприятие'),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: TextFormField(
            controller: textController,
            style: context.textTheme.bodyLarge,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.lightGrey,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            maxLines: 3,
          ),
          actions: [
            Column(
              children: [
                AppButton(
                  text: 'Отправить',
                  borderRadius: 10,
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    // Handle submit
                  },
                ),
                const SizedBox(height: 12),
                AppButton(
                  text: 'Отменить',
                  borderRadius: 10,
                  padding: EdgeInsets.zero,
                  isOutlined: true,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
