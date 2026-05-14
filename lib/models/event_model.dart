import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime eventDate;
  final int maxParticipants;
  final int registeredCount;
  final List<String> participants;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.eventDate,
    required this.maxParticipants,
    required this.registeredCount,
    this.participants = const [],
  });

  int get availableSpots => maxParticipants - registeredCount;

  bool get isFull => availableSpots <= 0;

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? eventDate,
    int? maxParticipants,
    int? registeredCount,
    List<String>? participants,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      eventDate: eventDate ?? this.eventDate,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      registeredCount: registeredCount ?? this.registeredCount,
      participants: participants ?? this.participants,
    );
  }

  factory EventModel.fromMap(Map<String, dynamic> data, String id) {
    final participants = List<String>.from(data['participants'] ?? const []);
    return EventModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      eventDate: (data['eventDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      maxParticipants: data['maxParticipants'] ?? 0,
      registeredCount: data['registeredCount'] ?? participants.length,
      participants: participants,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'eventDate': Timestamp.fromDate(eventDate),
      'maxParticipants': maxParticipants,
      'registeredCount': registeredCount,
      'participants': participants,
    };
  }
}
