import 'package:jaidem/core/data/models/jaidem/details/flow_model.dart';
import 'package:jaidem/features/events/data/models/attendance_model.dart';
import 'package:jaidem/features/events/data/models/event_model.dart';
import 'package:jaidem/features/events/domain/entities/event_entity.dart';

class EventMapper {
  // ----------- JSON → Model -----------

  static EventModel fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      createdBy: json['created_by'],
      participants: (json['participants'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      flow: json['flow'] != null
          ? FlowModel(
              id: json['flow']['id'],
              name: json['flow']['name'],
              description: json['flow']['description'],
              year: json['flow']['year'],
            )
          : null,
      title: json['title'],
      description: json['description'],
      conditions: json['conditions'],
      date: json['date'],
      location: json['location'],
      phone: json['phone'],
      email: json['email'],
      generation: json['generation'],
      image: json['image'],
      video: json['video'],
      isRequired: json['is_required'],
      like: json['like'],
      presentNumber: json['present_number'],
      absentNumber: json['absent_number'],
      respectfulNumber: json['respectful_number'],
    );
  }

  // ----------- Model → JSON -----------

  static Map<String, dynamic> toJson(EventModel model) {
    return {
      'id': model.id,
      'created_by': model.createdBy,
      'participants': model.participants ?? [],
      // 'flow': model.flow == null
      //     ? null
      //     : {
      //         'id': model.flow!.id,
      //         'name': model.flow!.name,
      //         'description': model.flow!.description,
      //         'year': model.flow!.year,
      //       },
      // 'title': model.title,
      // 'description': model.description,
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
      'present_number': model.presentNumber,
      'absent_number': model.absentNumber,
      'respectful_number': model.respectfulNumber,
    };
  }

  // ----------- Model → Entity -----------

  static EventEntity toEntity(EventModel model) {
    return EventEntity(
      id: model.id,
      createdBy: model.createdBy,
      participants: model.participants ?? [],
      flow: model.flow,
      title: model.title,
      description: model.description,
      conditions: model.conditions,
      date: model.date != null ? DateTime.tryParse(model.date!) : null,
      location: model.location,
      phone: model.phone,
      email: model.email,
      generation: model.generation,
      image: model.image,
      video: model.video,
      isRequired: model.isRequired,
      like: model.like,
      presentNumber: model.presentNumber,
      absentNumber: model.absentNumber,
      respectfulNumber: model.respectfulNumber,
    );
  }

  // ----------- Entity → Model -----------

  static EventModel toModel(EventEntity entity) {
    return EventModel(
      id: entity.id,
      createdBy: entity.createdBy,
      participants: entity.participants,
      flow: entity.flow,
      title: entity.title,
      description: entity.description,
      conditions: entity.conditions,
      date: entity.date?.toIso8601String(),
      location: entity.location,
      phone: entity.phone,
      email: entity.email,
      generation: entity.generation,
      image: entity.image,
      video: entity.video,
      isRequired: entity.isRequired,
      like: entity.like,
      presentNumber: entity.presentNumber,
      absentNumber: entity.absentNumber,
      respectfulNumber: entity.respectfulNumber,
    );
  }
}
