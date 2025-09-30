import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/core/widgets/buttons/app_button.dart';
import 'package:jaidem/core/widgets/fields/app_text_form_field.dart';

mixin JaidemFilters<T extends StatefulWidget> on State<T> {
  // Controllers for filter fields
  final TextEditingController flowController = TextEditingController();
  final TextEditingController generationController = TextEditingController();
  final TextEditingController universityController = TextEditingController();
  final TextEditingController specialityController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  void showFilters({
    required void Function(Map<String, String?> filters) onApply,
    required VoidCallback onReset,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.lightGrey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextFormField(
                    controller: flowController,
                    label: 'Поток',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  AppTextFormField(
                    controller: generationController,
                    label: 'Поколение',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  AppTextFormField(
                    controller: universityController,
                    label: 'Университет',
                  ),
                  const SizedBox(height: 10),
                  AppTextFormField(
                    controller: specialityController,
                    label: 'Специальность',
                  ),
                  const SizedBox(height: 10),
                  AppTextFormField(
                    controller: ageController,
                    label: 'Возраст',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    text: 'Применить',
                    borderRadius: 10,
                    onPressed: () {
                      final filters = {
                        'flow': flowController.text.isNotEmpty
                            ? flowController.text
                            : null,
                        'generation': generationController.text.isNotEmpty
                            ? generationController.text
                            : null,
                        'university': universityController.text.isNotEmpty
                            ? universityController.text
                            : null,
                        'speciality': specialityController.text.isNotEmpty
                            ? specialityController.text
                            : null,
                        'age': ageController.text.isNotEmpty
                            ? ageController.text
                            : null,
                      };
                      onApply(filters);
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(height: 10),
                  AppButton(
                    text: 'Сбросить',
                    isOutlined: true,
                    borderRadius: 10,
                    onPressed: () {
                      flowController.clear();
                      generationController.clear();
                      universityController.clear();
                      specialityController.clear();
                      ageController.clear();
                      onReset();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
