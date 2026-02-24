import 'package:jaidem/features/menu/data/models/division_model.dart';

class FileModel {
  final int id;
  final String title;
  final String? file;
  final String usefulLinks;
  final Division? division;
  final String subdivision;

  FileModel({
    required this.id,
    required this.title,
    required this.file,
    required this.usefulLinks,
    this.division,
    required this.subdivision,
  });

  factory FileModel.fromJson(Map<String, dynamic> json) {
    // Handle subdivision which can be either a String or an object
    String subdivisionName = '';
    if (json['subdivision'] != null) {
      if (json['subdivision'] is String) {
        subdivisionName = json['subdivision'];
      } else if (json['subdivision'] is Map) {
        subdivisionName = json['subdivision']['name'] ?? '';
      }
    }

    return FileModel(
      id: json['id'],
      title: json['title'],
      file: json['file'],
      usefulLinks: json['useful_links'] ?? '',
      division: json['division'] != null
          ? Division.fromJson(json['division'])
          : null,
      subdivision: subdivisionName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'file': file,
      'useful_links': usefulLinks,
      'division': division?.toJson(),
      'subdivision': subdivision,
    };
  }
}
