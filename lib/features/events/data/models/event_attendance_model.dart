class EventAttendanceStudent {
  final int id;
  final String fullname;
  final String avatar;

  const EventAttendanceStudent({
    required this.id,
    required this.fullname,
    required this.avatar,
  });

  factory EventAttendanceStudent.fromJson(Map<String, dynamic> json) {
    return EventAttendanceStudent(
      id: json['id'] as int? ?? 0,
      fullname: json['fullname']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? '',
    );
  }
}

class EventAttendanceItem {
  final int id;
  final EventAttendanceStudent student;
  final String status;
  final String reason;
  final String? createdAt;

  const EventAttendanceItem({
    required this.id,
    required this.student,
    required this.status,
    required this.reason,
    this.createdAt,
  });

  factory EventAttendanceItem.fromJson(Map<String, dynamic> json) {
    return EventAttendanceItem(
      id: json['id'] as int? ?? 0,
      student: EventAttendanceStudent.fromJson(
        json['student'] is Map<String, dynamic>
            ? json['student']
            : {'id': 0, 'fullname': '', 'avatar': ''},
      ),
      status: json['status']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
    );
  }
}

class EventAttendancesResponse {
  final int willGoCount;
  final int willNotGoCount;
  final int maybeCount;
  final int totalCount;
  final List<EventAttendanceItem> results;

  const EventAttendancesResponse({
    required this.willGoCount,
    required this.willNotGoCount,
    required this.maybeCount,
    required this.totalCount,
    required this.results,
  });

  factory EventAttendancesResponse.fromJson(Map<String, dynamic> json) {
    return EventAttendancesResponse(
      willGoCount: json['will_go_count'] as int? ?? 0,
      willNotGoCount: json['will_not_go_count'] as int? ?? 0,
      maybeCount: json['maybe_count'] as int? ?? 0,
      totalCount: json['total_count'] as int? ?? 0,
      results: (json['results'] as List<dynamic>?)
              ?.map((e) =>
                  EventAttendanceItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
