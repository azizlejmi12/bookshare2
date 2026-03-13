import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationModel {
  final String id;
  final String userId;
  final String bookId;
  final int queuePosition;
  final String status;
  final DateTime createdAt;

  ReservationModel({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.queuePosition,
    required this.status,
    required this.createdAt,
  });

  factory ReservationModel.fromMap(Map<String, dynamic> data, String id) {
    return ReservationModel(
      id: id,
      userId: data['userId'] ?? '',
      bookId: data['bookId'] ?? '',
      queuePosition: data['queuePosition'] ?? 1,
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'bookId': bookId,
      'queuePosition': queuePosition,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
