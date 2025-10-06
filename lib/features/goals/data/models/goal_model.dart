class GoalModel {
  final int? id;
  final String title;
  final String? description;
  final String status;
  final DateTime dateCreated;
  final DateTime dateUpdated;
  final DateTime? deadline;
  final String? frequency;
  final String? reminder;
  final double progress;
  final dynamic student;
  final int? category;

  const GoalModel({
    this.id,
    required this.title,
    this.description,
    required this.status,
    required this.dateCreated,
    required this.dateUpdated,
    this.deadline,
    this.frequency,
    this.reminder,
    required this.progress,
    this.student,
    this.category,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'] as int?,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: json['status'] as String,
      dateCreated: DateTime.parse(json['date_created'] as String),
      dateUpdated: DateTime.parse(json['date_updated'] as String),
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      frequency: json['frequency'] as String?,
      reminder: json['reminder'] as String?,
      progress: (json['progress'] as num).toDouble(),
      // student: json['student'] as Map<String, dynamic>,
      category: json['category'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'date_created': dateCreated.toIso8601String(),
      'date_updated': dateUpdated.toIso8601String(),
      'deadline': deadline != null 
          ? '${deadline!.year.toString().padLeft(4, '0')}-${deadline!.month.toString().padLeft(2, '0')}-${deadline!.day.toString().padLeft(2, '0')}'
          : null,
      'frequency': frequency,
      'reminder': reminder,
      'progress': progress,
      'student': student,
      'category': category,
    };
  }

  GoalModel copyWith({
    int? id,
    String? title,
    String? description,
    String? status,
    DateTime? dateCreated,
    DateTime? dateUpdated,
    DateTime? deadline,
    String? frequency,
    String? reminder,
    double? progress,
    dynamic student,
    int? category,
  }) {
    return GoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      dateCreated: dateCreated ?? this.dateCreated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      deadline: deadline ?? this.deadline,
      frequency: frequency ?? this.frequency,
      reminder: reminder ?? this.reminder,
      progress: progress ?? this.progress,
      student: student ?? this.student,
      category: category ?? this.category,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GoalModel &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.status == status &&
        other.dateCreated == dateCreated &&
        other.dateUpdated == dateUpdated &&
        other.deadline == deadline &&
        other.frequency == frequency &&
        other.reminder == reminder &&
        other.progress == progress &&
        other.student == student &&
        other.category == category;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        status.hashCode ^
        dateCreated.hashCode ^
        dateUpdated.hashCode ^
        deadline.hashCode ^
        frequency.hashCode ^
        reminder.hashCode ^
        progress.hashCode ^
        student.hashCode ^
        category.hashCode;
  }
}
