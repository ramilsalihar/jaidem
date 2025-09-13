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

class EventsState extends Equatable {
  const EventsState({
    this.eventsStatus = EventsStatus.initial,
    this.attendanceStatus = AttendanceStatus.initial,
    this.requiredEvents = const [],
    this.optionalEvents = const [],
    this.errorMessage,
  });

  final EventsStatus eventsStatus;
  final AttendanceStatus attendanceStatus;
  final List<EventEntity> requiredEvents;
  final List<EventEntity> optionalEvents;
  final String? errorMessage;

  EventsState copyWith({
    EventsStatus? eventsStatus,
    AttendanceStatus? attendanceStatus,
    List<EventEntity>? requiredEvents,
    List<EventEntity>? optionalEvents,
    String? errorMessage,
  }) {
    return EventsState(
      eventsStatus: eventsStatus ?? this.eventsStatus,
      attendanceStatus: attendanceStatus ?? this.attendanceStatus,
      requiredEvents: requiredEvents ?? this.requiredEvents,
      optionalEvents: optionalEvents ?? this.optionalEvents,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        eventsStatus,
        attendanceStatus,
        requiredEvents,
        optionalEvents,
        errorMessage,
      ];
}