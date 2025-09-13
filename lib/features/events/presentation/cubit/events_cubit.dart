import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaidem/features/events/data/models/attendance_model.dart';
import 'package:jaidem/features/events/domain/entities/event_entity.dart';
import 'package:jaidem/features/events/domain/usecases/get_events_usecase.dart';
import 'package:jaidem/features/events/domain/usecases/send_attendance_usecase.dart';

part 'events_state.dart';

class EventsCubit extends Cubit<EventsState> {
  EventsCubit({
    required this.getEventsUsecase,
    required this.sendEventRequestUsecase,
  }) : super(EventsState());

  final GetEventsUsecase getEventsUsecase;
  final SendAttendanceUsecase sendEventRequestUsecase;

  Future<void> fetchEvents() async {
    emit(state.copyWith(eventsStatus: EventsStatus.loading));
    final result = await getEventsUsecase();

    result.fold(
      (failure) => emit(state.copyWith(
        eventsStatus: EventsStatus.error,
        errorMessage: failure,
      )),
      (events) {
        final requiredEvents = events.where((e) => e.isRequired).toList();
        final optionalEvents = events.where((e) => !e.isRequired).toList();
        emit(state.copyWith(
          eventsStatus: EventsStatus.loaded,
          requiredEvents: requiredEvents,
          optionalEvents: optionalEvents,
        ));
      },
    );
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

        // Optionally refresh events to get updated attendance status
        // fetchEvents();
      },
    );
  }

  // In your EventsCubit, add this method:
  void resetAttendanceStatus() {
    emit(state.copyWith(attendanceStatus: AttendanceStatus.initial));
  }
}
