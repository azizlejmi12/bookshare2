import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/event_model.dart';

class EventsProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription<User?>? _authSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _eventsSub;
  final List<EventModel> _events = [];
  bool _isLoading = false;
  String? _error;

  EventsProvider() {
    _authSub = _auth.authStateChanges().listen((user) {
      if (user == null) {
        _eventsSub?.cancel();
        _events.clear();
        _error = null;
        _isLoading = false;
        notifyListeners();
        return;
      }

      loadEvents();
    });
  }

  List<EventModel> get events => List.unmodifiable(_events);
  bool get isLoading => _isLoading;
  String? get error => _error;

  void loadEvents() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _eventsSub?.cancel();
    _eventsSub = _db.collection('events').orderBy('eventDate').snapshots().listen(
      (snapshot) async {
        _events
          ..clear()
          ..addAll(
            snapshot.docs.map(
              (doc) => EventModel.fromMap(doc.data(), doc.id),
            ),
          );
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void addEvent({
    required String title,
    required String description,
    required DateTime eventDate,
    required int maxParticipants,
  }) {
    _db.collection('events').add({
      'title': title,
      'description': description,
      'eventDate': Timestamp.fromDate(eventDate),
      'maxParticipants': maxParticipants,
      'registeredCount': 0,
      'participants': <String>[],
    });
  }

  void updateEvent({
    required String eventId,
    required String title,
    required String description,
    required DateTime eventDate,
    required int maxParticipants,
  }) {
    final index = _events.indexWhere((event) => event.id == eventId);
    if (index == -1) return;

    final current = _events[index];
    final trimmedParticipants = current.participants.take(maxParticipants).toList();

    _db.collection('events').doc(eventId).update({
      'title': title,
      'description': description,
      'eventDate': Timestamp.fromDate(eventDate),
      'maxParticipants': maxParticipants,
      'registeredCount': trimmedParticipants.length,
      'participants': trimmedParticipants,
    });
  }

  void deleteEvent(String eventId) {
    _db.collection('events').doc(eventId).delete();
  }

  Future<String?> addParticipant(String eventId, String participantName) async {
    final index = _events.indexWhere((event) => event.id == eventId);
    if (index == -1) return 'Événement introuvable.';

    final event = _events[index];
    final name = participantName.trim();
    if (name.isEmpty) return 'Nom participant invalide.';
    if (event.isFull) return 'Événement complet.';
    if (event.participants.contains(name)) return 'Participant déjà inscrit.';

    final participants = [...event.participants, name];
    try {
      await _db.collection('events').doc(eventId).update({
        'registeredCount': participants.length,
        'participants': participants,
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> removeParticipant(String eventId, String participantName) async {
    final index = _events.indexWhere((event) => event.id == eventId);
    if (index == -1) return 'Événement introuvable.';

    final event = _events[index];
    final participants = [...event.participants]..remove(participantName);

    try {
      await _db.collection('events').doc(eventId).update({
        'registeredCount': participants.length,
        'participants': participants,
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _eventsSub?.cancel();
    super.dispose();
  }
}