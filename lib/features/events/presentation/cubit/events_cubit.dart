import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/features/events/data/models/attendance_model.dart';
import 'package:jaidem/features/events/domain/entities/event_entity.dart';
import 'package:jaidem/features/events/domain/repositories/event_repository.dart';
import 'package:jaidem/features/events/domain/usecases/get_events_usecase.dart';
import 'package:jaidem/features/events/domain/usecases/send_attendance_usecase.dart';
import 'package:jaidem/features/events/domain/usecases/update_attendance_usecase.dart';

part 'events_state.dart';

class EventsCubit extends Cubit<EventsState> {
  EventsCubit({
    required this.getEventsUsecase,
    required this.sendEventRequestUsecase,
    required this.updateAttendanceUsecase,
    required this.eventRepository,
    required this.currentUserId,
  }) : super(EventsState());

  final GetEventsUsecase getEventsUsecase;
  final SendAttendanceUsecase sendEventRequestUsecase;
  final UpdateAttendanceUsecase updateAttendanceUsecase;
  final EventRepository eventRepository;
  final String currentUserId;

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

        final requiredEvents = eventsWithAttendance.where((e) => e.isRequired).toList();
        final optionalEvents = eventsWithAttendance.where((e) => !e.isRequired).toList();
        emit(state.copyWith(
          eventsStatus: EventsStatus.loaded,
          requiredEvents: requiredEvents,
          optionalEvents: optionalEvents,
        ));
      },
    );
  }

  Future<List<EventEntity>> _fetchAttendanceForEvents(List<EventEntity> events) async {
    if (currentUserId.isEmpty) return events;

    final List<EventEntity> updatedEvents = [];

    for (final event in events) {
      final attendanceResult = await eventRepository.getAttendance(
        event.id,
        currentUserId,
      );

      attendanceResult.fold(
        (failure) => updatedEvents.add(event),
        (attendance) => updatedEvents.add(event.copyWith(attendance: attendance)),
      );
    }

    return updatedEvents;
  }

  Future<void> sendRequest(AttendanceModel attendance) async {
    emit(state.copyWith(attendanceStatus: AttendanceStatus.loading));

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

        // Refresh events to get updated attendance status
        fetchEvents();
      },
    );
  }

  Future<void> updateAttendance(AttendanceModel attendance) async {
    emit(state.copyWith(attendanceStatus: AttendanceStatus.loading));

    final result = await updateAttendanceUsecase(attendance);

    result.fold(
      (failure) => emit(state.copyWith(
        attendanceStatus: AttendanceStatus.error,
        errorMessage: failure,
      )),
      (successMessage) {
        emit(state.copyWith(
          attendanceStatus: AttendanceStatus.success,
        ));

        // Refresh events to get updated attendance status
        fetchEvents();
      },
    );
  }

  void resetAttendanceStatus() {
    emit(state.copyWith(attendanceStatus: AttendanceStatus.initial));
  }
}
