import 'package:jaidem/core/data/models/jaidem/details/flow_model.dart';
import 'package:jaidem/features/events/data/models/attendance_model.dart';

class EventEntity {
  final int id;
  final String? createdBy;
  final List<String> participants;
  final FlowModel flow;
  final String title;
  final String description;
  final String conditions;
  final DateTime date;
  final String location;
  final String phone;
  final String email;
  final String generation;
  final String image;
  final String video;
  final bool isRequired;
  final int like;
  final AttendanceModel? attendance;

  const EventEntity({
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
    this.attendance,
  });

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
    AttendanceModel? attendance,
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
      attendance: attendance ?? this.attendance,
    );
  }
}
