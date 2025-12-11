import 'package:jaidem/core/data/models/jaidem/details/flow_model.dart';
import 'package:jaidem/features/events/data/models/attendance_model.dart';

class EventModel {
  final int? id;
  final String? createdBy;
  final List<String>? participants;
  final FlowModel? flow;

  final String title; // not nullable
  final String description; // not nullable

  final String? conditions;
  final String? date;
  final String? location;
  final String? phone;
  final String? email;
  final String? generation;
  final String? image;
  final String? video;

  final bool isRequired;
  final int? like;

  final int? presentNumber;
  final int? absentNumber;
  final int? respectfulNumber;

  const EventModel({
    this.id,
    this.createdBy,
    this.participants,
    this.flow,
    required this.title,
    required this.description,
    this.conditions,
    this.date,
    this.location,
    this.phone,
    this.email,
    this.generation,
    this.image,
    this.video,
    required this.isRequired,
    this.like,
    this.presentNumber,
    this.absentNumber,
    this.respectfulNumber,
  });
}
