import 'package:flutter/material.dart';
import 'package:jaidem/core/widgets/buttons/app_button.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/events/presentation/helpers/event_dialogs.dart';

enum EventCardState {
  review,
  decision,
  share,
}

const double buttonHeight = 30.0;
const double buttonRadius = 10.0;

class EventActionButtons extends StatelessWidget with EventDialogs{
  final EventCardState status;
  final VoidCallback? primaryButtonAction;
  final String? secondaryButtonText;
  final VoidCallback? secondaryButtonAction;
  final String? tertiaryButtonText;
  final VoidCallback? tertiaryButtonAction;
  final VoidCallback? shareButtonAction;

  // Default constructor for review - single button
  const EventActionButtons({
    super.key,
    this.status = EventCardState.review,
    this.primaryButtonAction,
    this.secondaryButtonText,
    this.secondaryButtonAction,
    this.tertiaryButtonText,
    this.tertiaryButtonAction,
    this.shareButtonAction,
  });

  // Share action constructor - one button + share button
  const EventActionButtons.shareAction({
    super.key,
    this.primaryButtonAction,
    this.shareButtonAction,
  })  : status = EventCardState.share,
        secondaryButtonText = null,
        secondaryButtonAction = null,
        tertiaryButtonText = null,
        tertiaryButtonAction = null;

  // Decision action constructor - three buttons
  const EventActionButtons.decisionAction({
    super.key,
    required this.secondaryButtonText,
    required this.tertiaryButtonText,
    this.primaryButtonAction,
    this.secondaryButtonAction,
    this.tertiaryButtonAction,
  })  : status = EventCardState.decision,
        shareButtonAction = null;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case EventCardState.review:
        return AppButton(
          key: ValueKey('review_button'),
          height: buttonHeight,
          borderRadius: buttonRadius,
          backgroundColor: AppColors.primary.shade200,
          padding: const EdgeInsets.symmetric(vertical: 10),
          onPressed: primaryButtonAction ?? () {},
          text: "Пикир калтырыңыз",
        );

      case EventCardState.share:
        // Primary button + share button
        return Row(
          children: [
            Expanded(
              child: AppButton(
                key: ValueKey('share_button'),
                height: buttonHeight,
                borderRadius: buttonRadius,
                backgroundColor: AppColors.green,
                padding: const EdgeInsets.symmetric(vertical: 10),
                onPressed: primaryButtonAction ?? () {},
                text: "Мен катышкым келет",
              ),
            ),
            // const SizedBox(width: 8),
            // IconButton.filled(
            //   style: IconButton.styleFrom(
            //     backgroundColor: AppColors.primary.shade200,
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(buttonRadius),
            //     ),
            //   ),
            //   onPressed: shareButtonAction ?? () {},
            //   icon: Image.asset(
            //     'assets/icons/share.png',
            //     color: AppColors.white,
            //     height: 16,
            //   ),
            // ),
          ],
        );

      case EventCardState.decision:
        return Row(
          children: [
            Expanded(
              child: AppButton(
                key: ValueKey('decision_primary_button'),
                height: buttonHeight,
                borderRadius: buttonRadius,
                padding: const EdgeInsets.symmetric(vertical: 10),
                onPressed: primaryButtonAction ?? () {},
                backgroundColor: AppColors.green,
                text: "Барам",
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: AppButton(
                key: ValueKey('decision_secondary_button'),
                height: buttonHeight,
                borderRadius: buttonRadius,
                padding: const EdgeInsets.symmetric(vertical: 10),
                onPressed: secondaryButtonAction ?? () {
                  showSkipEvent(context);
                },
                backgroundColor: AppColors.red,
                text: 'Барбайм',
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: AppButton(
                key: ValueKey('decision_tertiary_button'),
                height: buttonHeight,
                borderRadius: buttonRadius,
                padding: const EdgeInsets.symmetric(vertical: 10),
                onPressed: tertiaryButtonAction ?? () {},
                backgroundColor: AppColors.orange,
                text: 'Ойлон',
              ),
            ),
          ],
        );
    }
  }
}
