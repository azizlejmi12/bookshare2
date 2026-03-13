import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime eventDate;
  final int maxParticipants;
  final int registeredCount;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.eventDate,
    required this.maxParticipants,
    required this.registeredCount,
  });

  factory EventModel.fromMap(Map<String, dynamic> data, String id) {
    return EventModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      eventDate: (data['eventDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      maxParticipants: data['maxParticipants'] ?? 0,
      registeredCount: data['registeredCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'eventDate': Timestamp.fromDate(eventDate),
      'maxParticipants': maxParticipants,
      'registeredCount': registeredCount,
    };
  }
}
