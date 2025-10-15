import 'package:jaidem/features/goals/data/models/goal_indicator_model.dart';

class GoalTaskModel {
  final int? id;
  final String title;
  final bool isCompleted;
  final DateTime? dateCreated;
  final DateTime? dateUpdated;
  final dynamic indicator;

  const GoalTaskModel({
    this.id,
    required this.title,
    required this.isCompleted,
    this.dateCreated,
    this.dateUpdated,
    required this.indicator,
  });

  factory GoalTaskModel.fromJson(Map<String, dynamic> json) {
    return GoalTaskModel(
      id: json['id'] as int?,
      title: json['title'] as String,
      isCompleted: json['is_completed'] as bool,
      dateCreated: json['date_created'] != null
          ? DateTime.parse(json['date_created'] as String)
          : null,
      dateUpdated: json['date_updated'] != null
          ? DateTime.parse(json['date_updated'] as String)
          : null,
      indicator: json['indicator'] is Map<String, dynamic>
          ? GoalIndicatorModel.fromJson(
              json['indicator'] as Map<String, dynamic>)
          : json['indicator'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'is_completed': isCompleted,
      'date_created': dateCreated?.toIso8601String(),
      'date_updated': dateUpdated?.toIso8601String(),
      'indicator': indicatorId,
    };
  }

  GoalTaskModel copyWith({
    int? id,
    String? title,
    bool? isCompleted,
    DateTime? dateCreated,
    DateTime? dateUpdated,
    dynamic indicator,
  }) {
    return GoalTaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      dateCreated: dateCreated ?? this.dateCreated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      indicator: indicator ?? this.indicator,
    );
  }

  /// Helper method to get the indicator ID as an integer
  int? get indicatorId {
    if (indicator == null) return null;
    if (indicator is int) return indicator as int;
    if (indicator is GoalIndicatorModel)
      return (indicator as GoalIndicatorModel).id;
    return null;
  }

  /// Helper method to get the indicator ID as a string for map keys
  String get indicatorIdString {
    final id = indicatorId;
    return id?.toString() ?? indicator.toString();
  }

  @override
  String toString() {
    return 'GoalTaskModel(id: $id, title: $title, isCompleted: $isCompleted, indicator: $indicator)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GoalTaskModel &&
        other.id == id &&
        other.title == title &&
        other.isCompleted == isCompleted &&
        other.dateCreated == dateCreated &&
        other.dateUpdated == dateUpdated &&
        other.indicator == indicator;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        isCompleted.hashCode ^
        dateCreated.hashCode ^
        dateUpdated.hashCode ^
        indicator.hashCode;
  }
}
