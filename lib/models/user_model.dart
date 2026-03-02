import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final DateTime createdAt;
  final bool isAdmin; // ← NOUVEAU

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.createdAt,
    this.isAdmin = false, // ← Par défaut, pas admin
  });

  // Factory depuis Firestore
  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isAdmin: data['isAdmin'] ?? false, // ← NOUVEAU
    );
  }

  // Factory depuis Firebase Auth
  factory UserModel.fromFirebaseUser(String uid, String email, String name) {
    return UserModel(
      uid: uid,
      name: name,
      email: email,
      createdAt: DateTime.now(),
      isAdmin: false, // ← Par défaut
    );
  }

  // Convertir en Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
      'isAdmin': isAdmin, // ← NOUVEAU
    };
  }

  // Méthode copyWith pour modifications
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    DateTime? createdAt,
    bool? isAdmin,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}