import 'package:jaidem/core/data/models/jaidem/details/flow_model.dart';
import 'package:jaidem/features/events/data/models/attendance_model.dart';

class EventEntity {
  final int? id;
  final String? createdBy;
  final List<String>? participants;
  final FlowModel? flow;

  final String title; // not nullable
  final String description; // not nullable

  final String? conditions;
  final DateTime? date;
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

  const EventEntity({
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

  // add copy with
  EventEntity copyWith({
    int? id,
    String? createdBy,
    List<String>? participants,
    FlowModel? flow,
    String? title,
    String? description,
    String? conditions,
    DateTime? date,
    String? location,
    String? phone,
    String? email,
    String? generation,
    String? image,
    String? video,
    bool? isRequired,
    int? like,
    int? presentNumber,
    int? absentNumber,
    int? respectfulNumber,
  }) {
    return EventEntity(
      id: id ?? this.id,
      createdBy: createdBy ?? this.createdBy,
      participants: participants ?? this.participants,
      flow: flow ?? this.flow,
      title: title ?? this.title,
      description: description ?? this.description,
      conditions: conditions ?? this.conditions,
      date: date ?? this.date,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      generation: generation ?? this.generation,
      image: image ?? this.image,
      video: video ?? this.video,
      isRequired: isRequired ?? this.isRequired,
      like: like ?? this.like,
      presentNumber: presentNumber ?? this.presentNumber,
      absentNumber: absentNumber ?? this.absentNumber,
      respectfulNumber: respectfulNumber ?? this.respectfulNumber,
    );
  }
}
