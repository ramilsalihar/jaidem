import 'package:jaidem/core/data/models/jaidem/details/flow_model.dart';

class EventModel {
  final int id;
  final String? createdBy;
  final List<String> participants;
  final FlowModel flow;
  final String title;
  final String description;
  final String conditions;
  final String date;
  final String location;
  final String phone;
  final String email;
  final String generation;
  final String image;
  final String video;
  final bool isRequired;
  final int like;

  const EventModel({
    required this.id,
    this.createdBy,
    required this.participants,
    required this.flow,
    required this.title,
    required this.description,
    required this.conditions,
    required this.date,
    required this.location,
    required this.phone,
    required this.email,
    required this.generation,
    required this.image,
    required this.video,
    required this.isRequired,
    required this.like,
  });
}
