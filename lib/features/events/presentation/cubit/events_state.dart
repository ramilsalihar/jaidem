part of 'events_cubit.dart';

enum EventsStatus {
  initial,
  loading,
  loaded,
  error,
}

enum AttendanceStatus {
  initial,
  loading,
  success,
  error,
}

enum EventAttendancesStatus {
  initial,
  loading,
  loaded,
  error,
}

class EventsState extends Equatable {
  const EventsState({
    this.eventsStatus = EventsStatus.initial,
    this.attendanceStatus = AttendanceStatus.initial,
    this.eventAttendancesStatus = EventAttendancesStatus.initial,
    this.requiredEvents = const [],
    this.optionalEvents = const [],
    this.eventAttendances,
    this.errorMessage,
  });

  final EventsStatus eventsStatus;
  final AttendanceStatus attendanceStatus;
  final EventAttendancesStatus eventAttendancesStatus;
  final List<EventEntity> requiredEvents;
  final List<EventEntity> optionalEvents;
  final EventAttendancesResponse? eventAttendances;
  final String? errorMessage;

  EventsState copyWith({
    EventsStatus? eventsStatus,
    AttendanceStatus? attendanceStatus,
    EventAttendancesStatus? eventAttendancesStatus,
    List<EventEntity>? requiredEvents,
    List<EventEntity>? optionalEvents,
    EventAttendancesResponse? eventAttendances,
    String? errorMessage,
    bool clearAttendances = false,
  }) {
    return EventsState(
      eventsStatus: eventsStatus ?? this.eventsStatus,
      attendanceStatus: attendanceStatus ?? this.attendanceStatus,
      eventAttendancesStatus: eventAttendancesStatus ?? this.eventAttendancesStatus,
      requiredEvents: requiredEvents ?? this.requiredEvents,
      optionalEvents: optionalEvents ?? this.optionalEvents,
      eventAttendances: clearAttendances ? null : (eventAttendances ?? this.eventAttendances),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        eventsStatus,
        attendanceStatus,
        eventAttendancesStatus,
        requiredEvents,
        optionalEvents,
        eventAttendances,
        errorMessage,
      ];
}