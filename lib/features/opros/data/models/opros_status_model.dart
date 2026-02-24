class OprosStatusModel {
  final bool beforeCompleted;
  final bool afterCompleted;
  final String? afterOpenDate;

  const OprosStatusModel({
    required this.beforeCompleted,
    required this.afterCompleted,
    this.afterOpenDate,
  });

  factory OprosStatusModel.fromJson(Map<String, dynamic> json) {
    return OprosStatusModel(
      beforeCompleted: json['before_completed'] ?? false,
      afterCompleted: json['after_completed'] ?? false,
      afterOpenDate: json['after_open_date'] as String?,
    );
  }

  bool get isAfterOpen {
    if (afterOpenDate == null) return false;
    try {
      final openDate = DateTime.parse(afterOpenDate!);
      return !DateTime.now().isBefore(openDate);
    } catch (_) {
      return false;
    }
  }

  DateTime? get afterOpenDateTime {
    if (afterOpenDate == null) return null;
    try {
      return DateTime.parse(afterOpenDate!);
    } catch (_) {
      return null;
    }
  }
}
