import 'package:cloud_firestore/cloud_firestore.dart';

class BookModel {
  final String id;
  final String title;
  final String author;
  final String genre;
  final bool isAvailable;
  final String? coverUrl;
  final DateTime? createdAt;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.genre,
    this.isAvailable = true,
    this.coverUrl,
    this.createdAt,
  });

  // Factory depuis Firestore
  factory BookModel.fromFirestore(Map<String, dynamic> data, String id) {
    return BookModel(
      id: id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      genre: data['genre'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
      coverUrl: data['coverUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // Convertir en Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'author': author,
      'genre': genre,
      'isAvailable': isAvailable,
      'coverUrl': coverUrl,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }
}