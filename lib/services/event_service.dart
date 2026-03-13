import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/event_model.dart';

class EventService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<EventModel>> getEvents() {
    return _db.collection('events').orderBy('eventDate').snapshots().map((
      snap,
    ) {
      return snap.docs
          .map((doc) => EventModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> addEvent({
    required String title,
    required String description,
    required DateTime eventDate,
    required int maxParticipants,
  }) {
    return _db.collection('events').add({
      'title': title,
      'description': description,
      'eventDate': Timestamp.fromDate(eventDate),
      'maxParticipants': maxParticipants,
      'registeredCount': 0,
    });
  }
}
