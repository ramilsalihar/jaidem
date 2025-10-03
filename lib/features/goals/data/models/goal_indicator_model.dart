class GoalIndicatorModel {
  final int? id;
  final String title;
  final String? startTime;
  final String? endTime;
  final String? reminder;
  final double progress;
  final int goal;

  const GoalIndicatorModel({
    this.id,
    required this.title,
    this.startTime,
    this.endTime,
    this.reminder,
    required this.progress,
    required this.goal,
  });

  factory GoalIndicatorModel.fromJson(Map<String, dynamic> json) {
    return GoalIndicatorModel(
      id: json['id'] as int?,
      title: json['title'] as String,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      reminder: json['reminder'] as String?,
      progress: (json['progress'] as num).toDouble(),
      goal: json['goal'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'start_time': startTime,
      'end_time': endTime,
      'reminder': reminder,
      'progress': progress,
      'goal': goal,
    };
  }

  GoalIndicatorModel copyWith({
    int? id,
    String? title,
    String? startTime,
    String? endTime,
    String? reminder,
    double? progress,
    int? goal,
  }) {
    return GoalIndicatorModel(
      id: id ?? this.id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      reminder: reminder ?? this.reminder,
      progress: progress ?? this.progress,
      goal: goal ?? this.goal,
    );
  }

  @override
  String toString() {
    return 'GoalIndicatorModel(id: $id, title: $title, progress: $progress, goal: $goal)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is GoalIndicatorModel &&
      other.id == id &&
      other.title == title &&
      other.startTime == startTime &&
      other.endTime == endTime &&
      other.reminder == reminder &&
      other.progress == progress &&
      other.goal == goal;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      title.hashCode ^
      startTime.hashCode ^
      endTime.hashCode ^
      reminder.hashCode ^
      progress.hashCode ^
      goal.hashCode;
  }
}