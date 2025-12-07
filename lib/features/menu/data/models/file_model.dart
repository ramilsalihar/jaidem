import 'package:jaidem/features/menu/data/models/division_model.dart';

class FileModel {
  final int id;
  final String title;
  final String? file;
  final String usefulLinks;
  final Division division;
  final String subdivision;

  FileModel({
    required this.id,
    required this.title,
    required this.file,
    required this.usefulLinks,
    required this.division,
    required this.subdivision,
  });

  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      id: json['id'],
      title: json['title'],
      file: json['file'],
      usefulLinks: json['useful_links'],
      division: Division.fromJson(json['division']),
      subdivision: json['subdivision'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'file': file,
      'useful_links': usefulLinks,
      'division': division.toJson(),
      'subdivision': subdivision,
    };
  }
}
