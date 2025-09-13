import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/core/utils/constants/app_constants.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/extensions/date_extension.dart';
import 'package:jaidem/core/utils/helpers/show.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/core/widgets/fields/details_text_field.dart';
import 'package:jaidem/features/events/data/models/attendance_model.dart';
import 'package:jaidem/features/events/domain/entities/event_entity.dart';
import 'package:jaidem/features/events/presentation/cubit/events_cubit.dart';
import 'package:jaidem/features/events/presentation/widgets/buttons/event_action_buttons.dart';
import 'package:jaidem/features/events/presentation/widgets/dialogs/event_dialog.dart';

class EventCard extends StatefulWidget {
  const EventCard({super.key, required this.event});

  final EventEntity event;

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> with EventDialog, Show {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              widget.event.image,
              width: double.infinity,
              fit: BoxFit.cover,
              height: 100,
              errorBuilder: (context, error, stackTrace) {
                return Image.network(
                  AppConstants.defaultEventImage,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  height: 100,
                );
              },
            ),
          ),
          const SizedBox(height: 7),
          DetailsTextField(
            label: 'Тема:',
            value: widget.event.title,
            labelStyle: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.grey,
            ),
            valueStyle: context.textTheme.bodyMedium?.copyWith(
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 1),
          DetailsTextField(
            label: 'Когда:',
            value: widget.event.date.toReadableDate(),
            labelStyle: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.grey,
            ),
            valueStyle: context.textTheme.bodyMedium?.copyWith(
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 5),
          DetailsTextField(
            label: 'Где:',
            value: widget.event.location,
            labelStyle: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.grey,
            ),
            valueStyle: context.textTheme.bodyMedium?.copyWith(
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          BlocBuilder<EventsCubit, EventsState>(
            builder: (context, state) {
              return EventActionButtons(
                status: widget.event.isRequired
                    ? EventCardState.decision
                    : EventCardState.share,
                primaryButtonAction: () {
                  var attendance = AttendanceModel(
                    status: 'will go',
                    reason: 'will go',
                    student: '',
                    event: widget.event.id,
                  );
                  if (widget.event.isRequired) {
                    context.read<EventsCubit>().sendRequest(attendance);
                  } else {
                    attendance =
                        attendance.copyWith(reason: "Хочу участвовать");
                    context.read<EventsCubit>().sendRequest(attendance);
                  }
                },
                secondaryButtonAction: () {
                  var attendance = AttendanceModel(
                    status: 'will not go',
                    reason: '',
                    student: '',
                    event: widget.event.id,
                  );
                  showEventDialog(onConfirm: (val) {
                    attendance = attendance.copyWith(reason: val);

                    if (val != null) {
                      context.read<EventsCubit>().sendRequest(attendance);
                    }
                  });
                },
                tertiaryButtonAction: () {
                  var attendance = AttendanceModel(
                    status: 'maybe',
                    reason: 'Думаю',
                    student: '',
                    event: widget.event.id,
                  );
                  context.read<EventsCubit>().sendRequest(attendance);
                },
              );
            },
          )
        ],
      ),
    );
  }
}
