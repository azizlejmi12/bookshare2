import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String bookId;
  final String userId;
  final String userName; // Nom du reviewer
  final double rating; // 1 à 5 étoiles
  final String comment; // Avis court
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  // Factory pour créer depuis Firestore
  factory ReviewModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ReviewModel(
      id: id,
      bookId: data['bookId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonyme',
      rating: (data['rating'] ?? 0).toDouble(),
      comment: data['comment'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Convertir en Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'bookId': bookId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Créer une copie avec des modifications
  ReviewModel copyWith({
    String? userName,
    double? rating,
    String? comment,
  }) {
    return ReviewModel(
      id: id,
      bookId: bookId,
      userId: userId,
      userName: userName ?? this.userName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt,
    );
  }
}
