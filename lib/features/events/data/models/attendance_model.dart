class AttendanceModel {
  final int? id;
  final String status;
  final String reason;
  final String? createdAt;
  final String student;
  final int event;

  const AttendanceModel({
    this.id,
    required this.status,
    required this.reason,
    this.createdAt,
    required this.student,
    required this.event,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'reason': reason,
      'student': student,
      'event': event,
    };
  }

  AttendanceModel copyWith({
    int? id,
    String? status,
    String? reason,
    String? createdAt,
    String? student,
    int? event,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      student: student ?? this.student,
      event: event ?? this.event,
    );
  }
}
