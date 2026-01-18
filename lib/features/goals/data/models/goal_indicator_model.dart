import 'package:jaidem/features/goals/data/models/goal_model.dart';

class GoalIndicatorModel {
  final int? id;
  final String title;
  final String? startTime;
  final String? endTime;
  final String? reminder;
  final double progress;
  final dynamic goal;

  const GoalIndicatorModel({
    this.id,
    required this.title,
    this.startTime,
    this.endTime,
    this.reminder,
    required this.progress,
    this.goal,
  });

  factory GoalIndicatorModel.fromJson(Map<String, dynamic> json) {
    return GoalIndicatorModel(
      id: json['id'] as int?,
      title: json['title'] as String,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      reminder: json['reminder'] as String?,
      progress: (json['progress'] as num).toDouble(),
      goal: json['goal'] != null && json['goal'] is Map<String, dynamic>
          ? GoalModel.fromJson(json['goal'] as Map<String, dynamic>)
          : json['goal'],
    );
  }

  Map<String, dynamic> toJson() {
    // Always send goal as ID (primary key), not as object
    final goalValue = goal is GoalModel ? (goal as GoalModel).id : goal;

    return {
      'id': id,
      'title': title,
      'start_time': startTime,
      'end_time': endTime,
      'reminder': reminder,
      'progress': progress,
      'goal': goalValue,
    };
  }

  GoalIndicatorModel copyWith({
    int? id,
    String? title,
    String? startTime,
    String? endTime,
    String? reminder,
    double? progress,
    dynamic goal,
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

  /// Helper method to get the goal ID as an integer
  int? get goalId {
    if (goal == null) return null;
    if (goal is int) return goal as int;
    if (goal is GoalModel) return (goal as GoalModel).id;
    return null;
  }

  /// Helper method to get the goal ID as a string for map keys
  String get goalIdString {
    final id = goalId;
    return id?.toString() ?? goal?.toString() ?? 'null';
  }

  /// Helper method to get the GoalModel if available
  GoalModel? get goalModel {
    if (goal is GoalModel) return goal as GoalModel;
    return null;
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
