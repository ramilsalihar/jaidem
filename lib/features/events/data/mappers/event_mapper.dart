import 'package:jaidem/core/data/models/jaidem/details/flow_model.dart';
import 'package:jaidem/features/events/data/models/attendance_model.dart';
import 'package:jaidem/features/events/data/models/event_model.dart';
import 'package:jaidem/features/events/domain/entities/event_entity.dart';

class EventMapper {
  // ----------- JSON <-> Model -----------

  static int _toInt(dynamic value, [int fallback = 0]) =>
      value is int ? value : int.tryParse(value.toString()) ?? fallback;

  static EventModel fromJson(Map<String, dynamic> json) {
    final flowList = json['flow'] as List<dynamic>? ?? [];
    return EventModel(
      id: _toInt(json['id']),
      createdBy: json['created_by']?.toString(),
      participants: (json['participants'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      flows: flowList
          .map((f) => FlowModel.fromJson(f as Map<String, dynamic>))
          .toList(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      conditions: json['conditions']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      generation: json['generation']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      video: json['video']?.toString() ?? '',
      isRequired: json['is_required'] == true,
      like: _toInt(json['like']),
      attendance: json['attendance'] != null
          ? AttendanceModel.fromJson(json['attendance'])
          : null,
    );
  }

  static Map<String, dynamic> toJson(EventModel model) {
    return {
      'id': model.id,
      'created_by': model.createdBy,
      'participants': model.participants,
      'flow': model.flows.map((f) => {
        'id': f.id,
        'name': f.name,
        'description': f.description,
        'year': f.year,
      }).toList(),
      'title': model.title,
      'description': model.description,
      'conditions': model.conditions,
      'date': model.date,
      'location': model.location,
      'phone': model.phone,
      'email': model.email,
      'generation': model.generation,
      'image': model.image,
      'video': model.video,
      'is_required': model.isRequired,
      'like': model.like,
    };
  }

  // ----------- Model <-> Entity -----------

  static EventEntity toEntity(EventModel model) {
    return EventEntity(
      id: model.id,
      createdBy: model.createdBy,
      participants: model.participants,
      flows: model.flows,
      title: model.title,
      description: model.description,
      conditions: model.conditions,
      date: DateTime.parse(model.date),
      location: model.location,
      phone: model.phone,
      email: model.email,
      generation: model.generation,
      image: model.image,
      video: model.video,
      isRequired: model.isRequired,
      like: model.like,
      attendance: model.attendance,
    );
  }

  static EventModel toModel(EventEntity entity) {
    return EventModel(
      id: entity.id,
      createdBy: entity.createdBy,
      participants: entity.participants,
      flows: entity.flows,
      title: entity.title,
      description: entity.description,
      conditions: entity.conditions,
      date: entity.date.toIso8601String(),
      location: entity.location,
      phone: entity.phone,
      email: entity.email,
      generation: entity.generation,
      image: entity.image,
      video: entity.video,
      isRequired: entity.isRequired,
      like: entity.like,
      attendance: entity.attendance,
    );
  }
}
