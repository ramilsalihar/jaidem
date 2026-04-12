class ProjectModel {
  final int id;
  final String title;
  final String text;
  final List<String> images;
  final int priority;
  final DateTime dateCreated;
  final int interestedCount;

  const ProjectModel({
    required this.id,
    required this.title,
    required this.text,
    required this.images,
    required this.priority,
    required this.dateCreated,
    required this.interestedCount,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      text: json['text'] as String? ?? '',
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      priority: json['priority'] as int? ?? 0,
      dateCreated: DateTime.parse(json['dateCreated'] as String),
      interestedCount: json['interested_count'] as int? ?? 0,
    );
  }
}
