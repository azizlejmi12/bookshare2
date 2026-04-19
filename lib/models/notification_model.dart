import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type; // 'book_available', 'return_reminder', 'event_invitation'
  final String? bookId; // Optionnel - ID du livre concerné
  final String? eventId; // Optionnel - ID de l'événement
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.bookId,
    this.eventId,
    this.isRead = false,
    required this.createdAt,
  });

  // Factory pour créer depuis Firestore
  factory NotificationModel.fromFirestore(
      Map<String, dynamic> data, String id) {
    return NotificationModel(
      id: id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: data['type'] ?? '',
      bookId: data['bookId'],
      eventId: data['eventId'],
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Convertir en Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'bookId': bookId,
      'eventId': eventId,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Créer une copie avec des modifications
  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      userId: userId,
      title: title,
      message: message,
      type: type,
      bookId: bookId,
      eventId: eventId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}
