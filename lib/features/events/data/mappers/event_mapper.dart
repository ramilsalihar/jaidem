import 'package:jaidem/core/data/models/flow_model.dart';
import 'package:jaidem/features/events/data/models/event_model.dart';
import 'package:jaidem/features/events/domain/entities/event_entity.dart';

class EventMapper {
  // ----------- JSON <-> Model -----------

  static EventModel fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      createdBy: json['created_by'],
      participants: (json['participants'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      flow: FlowModel(
        id: json['flow']['id'],
        name: json['flow']['name'],
        description: json['flow']['description'],
        year: json['flow']['year'],
      ),
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
    );
  }

  static Map<String, dynamic> toJson(EventModel model) {
    return {
      'id': model.id,
      'created_by': model.createdBy,
      'participants': model.participants,
      'flow': {
        'id': model.flow.id,
        'name': model.flow.name,
        'description': model.flow.description,
        'year': model.flow.year,
      },
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
      flow: FlowModel(
        id: model.flow.id,
        name: model.flow.name,
        description: model.flow.description,
        year: model.flow.year,
      ),
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
    );
  }

  static EventModel toModel(EventEntity entity) {
    return EventModel(
      id: entity.id,
      createdBy: entity.createdBy,
      participants: entity.participants,
      flow: FlowModel(
        id: entity.flow.id,
        name: entity.flow.name,
        description: entity.flow.description,
        year: entity.flow.year,
      ),
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
    );
  }
}
