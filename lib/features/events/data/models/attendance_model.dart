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

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as int?,
      status: json['status'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      createdAt: json['created_at'] as String?,
      student: json['student']?.toString() ?? '',
      event: json['event'] is int ? json['event'] : 0,
    );
  }

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
