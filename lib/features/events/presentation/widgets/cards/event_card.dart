import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/core/utils/constants/app_constants.dart';
import 'package:jaidem/core/utils/extensions/date_extension.dart';
import 'package:jaidem/core/utils/extensions/theme_extension.dart';
import 'package:jaidem/core/utils/helpers/show.dart';
import 'package:jaidem/core/utils/style/app_colors.dart';
import 'package:jaidem/features/events/data/models/attendance_model.dart';
import 'package:jaidem/features/events/data/services/event_firebase_service.dart';
import 'package:jaidem/features/events/domain/entities/event_entity.dart';
import 'package:jaidem/features/events/presentation/cubit/events_cubit.dart';
import 'package:jaidem/features/events/presentation/widgets/dialogs/event_dialog.dart';

class EventCard extends StatefulWidget {
  const EventCard({
    super.key,
    required this.event,
    this.isRequired = false,
  });

  final EventEntity event;
  final bool isRequired;

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> with EventDialog {
  final EventFirebaseService _firebaseService = EventFirebaseService();

  int _likeCount = 0;
  bool _isLiked = false;
  bool _isLikeLoading = false;

  bool get _isEventInFuture => widget.event.date.isAfter(DateTime.now());

  @override
  void initState() {
    super.initState();
    _loadLikeData();
  }

  Future<void> _loadLikeData() async {
    final cubit = context.read<EventsCubit>();
    final userId = cubit.currentUserId;

    final count = await _firebaseService.getLikeCount(widget.event.id);
    final liked = userId.isNotEmpty
        ? await _firebaseService.hasUserLiked(widget.event.id, userId)
        : false;

    if (mounted) {
      setState(() {
        _likeCount = count;
        _isLiked = liked;
      });
    }
  }

  Future<void> _toggleLike() async {
    final cubit = context.read<EventsCubit>();
    final userId = cubit.currentUserId;

    if (userId.isEmpty) return;
    if (_isLikeLoading) return;

    setState(() {
      _isLikeLoading = true;
    });

    try {
      HapticFeedback.lightImpact();
      final nowLiked =
          await _firebaseService.toggleLike(widget.event.id, userId);

      if (mounted) {
        setState(() {
          _isLiked = nowLiked;
          _likeCount = nowLiked ? _likeCount + 1 : _likeCount - 1;
          _isLikeLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLikeLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
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
              widget.event.image ?? '',
              width: double.infinity,
              fit: BoxFit.cover,
              height: 120,
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
          const SizedBox(height: 5),
          DetailsTextField(
            label: 'Тема:',
            hasSpace: true,
            value: widget.event.title,
            labelStyle: context.textTheme.labelLarge?.copyWith(
              color: AppColors.grey,
            ),
            valueStyle: context.textTheme.labelLarge?.copyWith(
              color: Colors.black,
            ),
          ),
          DetailsTextField(
            label: 'Когда:',
            value: widget.event.date?.toReadableDate() ?? '',
            hasSpace: true,
            labelStyle: context.textTheme.labelLarge?.copyWith(
              color: AppColors.grey,
            ),
            valueStyle: context.textTheme.labelLarge?.copyWith(
              color: Colors.black,
            ),
          ),
          DetailsTextField(
            label: 'Где:',
            value: widget.event.location ?? '',
            hasSpace: true,
            labelStyle: context.textTheme.labelLarge?.copyWith(
              color: AppColors.grey,
            ),
            valueStyle: context.textTheme.labelLarge?.copyWith(
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 5),
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
                    event: widget.event.id ?? 0,
                  );
                  if (widget.event.isRequired) {
                    context
                        .read<EventsCubit>()
                        .sendRequest(attendance, widget.event);
                  } else {
                    attendance =
                        attendance.copyWith(reason: "Хочу участвовать");
                    context
                        .read<EventsCubit>()
                        .sendRequest(attendance, widget.event);
                  }
                },
                secondaryButtonAction: () {
                  var attendance = AttendanceModel(
                    status: 'will not go',
                    reason: '',
                    student: '',
                    event: widget.event.id ?? 0,
                  );
                  showEventDialog(onConfirm: (val) {
                    attendance = attendance.copyWith(reason: val);

                    if (val != null) {
                      context
                          .read<EventsCubit>()
                          .sendRequest(attendance, widget.event);
                    }
                  });
                },
                tertiaryButtonAction: () {
                  var attendance = AttendanceModel(
                    status: 'maybe',
                    reason: 'Думаю',
                    student: '',
                    event: widget.event.id ?? 0,
                  );
                  context
                      .read<EventsCubit>()
                      .sendRequest(attendance, widget.event);
                },
              );
            },
          )
        ],
      ),
    );
  }

  void _handleAttendance(String status, String reason) {
    final attendance = AttendanceModel(
      status: status,
      reason: reason,
      student: '',
      event: widget.event.id,
    );
    context.read<EventsCubit>().sendRequest(attendance);
  }

  void _showDeclineDialog() {
    showEventDialog(onConfirm: (val) {
      if (val != null && val.isNotEmpty) {
        final attendance = AttendanceModel(
          status: 'will not go',
          reason: val,
          student: '',
          event: widget.event.id,
        );
        context.read<EventsCubit>().sendRequest(attendance);
      }
    });
  }
}
