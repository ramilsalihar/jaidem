import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/features/events/data/models/attendance_model.dart';
import 'package:jaidem/features/events/domain/entities/event_entity.dart';
import 'package:jaidem/features/events/domain/repositories/event_repository.dart';
import 'package:jaidem/features/events/domain/usecases/get_events_usecase.dart';
import 'package:jaidem/features/events/domain/usecases/send_attendance_usecase.dart';
import 'package:jaidem/features/events/domain/usecases/update_event_usecase.dart';

part 'events_state.dart';

class EventsCubit extends Cubit<EventsState> {
  EventsCubit({
    required this.getEventsUsecase,
    required this.sendEventRequestUsecase,
    required this.updateEventUseCase,
  }) : super(EventsState());

  final GetEventsUsecase getEventsUsecase;
  final SendAttendanceUsecase sendEventRequestUsecase;
  final UpdateEventUseCase updateEventUseCase;

  Future<void> fetchEvents() async {
    emit(state.copyWith(eventsStatus: EventsStatus.loading));
    final result = await getEventsUsecase();

    result.fold(
      (failure) => emit(state.copyWith(
        eventsStatus: EventsStatus.error,
        errorMessage: failure,
      )),
      (events) async {
        // Fetch attendance for each event
        final eventsWithAttendance = await _fetchAttendanceForEvents(events);

        final requiredEvents =
            eventsWithAttendance.where((e) => e.isRequired).toList();
        final optionalEvents =
            eventsWithAttendance.where((e) => !e.isRequired).toList();
        emit(state.copyWith(
          eventsStatus: EventsStatus.loaded,
          requiredEvents: requiredEvents,
          optionalEvents: optionalEvents,
        ));
      },
    );
  }

  Future<void> sendRequest(
      AttendanceModel attendance, EventEntity event) async {
    emit(state.copyWith(attendanceStatus: AttendanceStatus.loading));

    // status in model: will go, will not go, maybe

    final result = await sendEventRequestUsecase(attendance);

    result.fold(
      (failure) => emit(state.copyWith(
        attendanceStatus: AttendanceStatus.error,
        errorMessage: failure,
      )),
      (successMessage) {
        emit(state.copyWith(
          attendanceStatus: AttendanceStatus.success,
        ));

        if (attendance.status == 'will go') {
          event = event.copyWith(presentNumber: event.presentNumber ?? 0 + 1);
        } else if (attendance.status == 'will not go') {
          event = event.copyWith(absentNumber: event.absentNumber ?? 0 + 1);
        } else {
          event =
              event.copyWith(respectfulNumber: event.respectfulNumber ?? 0 + 1);
        }

        // updateEvent(event);
      },
    );
  }

  Future<void> updateEvent(EventEntity event) async {
    emit(state.copyWith(eventsStatus: EventsStatus.loading));

    final result = await updateEventUseCase(event);

    result.fold(
      (failure) => emit(state.copyWith(
        eventsStatus: EventsStatus.error,
        errorMessage: failure,
      )),
      (successMessage) {
        emit(state.copyWith(
          eventsStatus: EventsStatus.loaded,
        ));

        // Optionally refresh events to get updated attendance status
        // fetchEvents();
      },
    );
  }

  void resetAttendanceStatus() {
    emit(state.copyWith(attendanceStatus: AttendanceStatus.initial));
  }
}
