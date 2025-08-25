import 'package:flutter/material.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/core/widgets/fields/details_text_field.dart';
import 'package:jaidem/features/jaidems/domain/entities/jaidem_entity.dart';
import 'package:jaidem/features/jaidems/presentation/widgets/buttons/jaidem_action_buttons.dart';
import 'package:jaidem/core/widgets/fields/rating_field.dart';

mixin JaidemPopUp<T extends StatefulWidget> on State<T> {
  void showJaidemDetails(JaidemEntity person) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final size = MediaQuery.of(context).size;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              Container(
                width: size.width * 0.9,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Header with close button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            person.fullname ?? 'Нет имени',
                            style: context.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: AppColors.primary.shade200,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Поколение: ${person.generation} Поток: ${person.flow}',
                            style: context.textTheme.labelMedium?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Rating stars
                    RatingField(rating: 2),

                    const SizedBox(height: 20),

                    // Profile details
                    DetailsTextField(
                      label: 'Возраст:',
                      value: person.age.toString(),
                      hasSpace: true,
                      labelStyle: context.textTheme.bodySmall,
                      valueStyle: context.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    DetailsTextField(
                      label: 'Университет:',
                      value: person.university,
                      hasSpace: true,
                      labelStyle: context.textTheme.bodySmall,
                      valueStyle: context.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    DetailsTextField(
                      label: 'Курс:',
                      value: person.courseYear.toString(),
                      hasSpace: true,
                      labelStyle: context.textTheme.bodySmall,
                      valueStyle: context.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    DetailsTextField(
                      label: 'Специальность:',
                      value: person.speciality,
                      hasSpace: true,
                      labelStyle: context.textTheme.bodySmall,
                      valueStyle: context.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    DetailsTextField(
                      label: 'Регион:',
                      value: 'person.region',
                      hasSpace: true,
                      labelStyle: context.textTheme.bodySmall,
                      valueStyle: context.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    DetailsTextField(
                      label: 'Село/город:',
                      value: person.state.toString(),
                      hasSpace: true,
                      labelStyle: context.textTheme.bodySmall,
                      valueStyle: context.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    DetailsTextField(
                      label: 'Интересы:',
                      value: person.interest,
                      hasSpace: true,
                      labelStyle: context.textTheme.bodySmall,
                      valueStyle: context.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    DetailsTextField(
                      label: 'Телефон:',
                      value: person.phone ?? '0556 789 123',
                      hasSpace: true,
                      labelStyle: context.textTheme.bodySmall,
                      valueStyle: context.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    DetailsTextField(
                      label: 'Email:',
                      value: person.email ?? 'asel.amanova@gmail.com',
                      hasSpace: true,
                      labelStyle: context.textTheme.bodySmall,
                      valueStyle: context.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Social media and profile button row
                    JaidemActionButtons(
                      iconSize: 35,
                      spaceBetweenIcons: 10,
                      isButtonExtended: true,
                    )
                  ],
                ),
              ),
              Positioned(
                right: 10,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.grey),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
