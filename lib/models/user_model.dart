class UserModel {
  final String uid;
  final String email;
  final String name;
  final String? photoUrl;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.photoUrl,
    required this.createdAt,
  });

  // Convertir depuis Firebase User
  factory UserModel.fromFirebaseUser(
    String uid,
    String email,
    String name,
  ) {
    return UserModel(
      uid: uid,
      email: email,
      name: name,
      createdAt: DateTime.now(),
    );
  }

  // TODO: Ajouter Firestore quand nécessaire
  // factory UserModel.fromFirestore(DocumentSnapshot doc) { ... }
  // Map<String, dynamic> toFirestore() { ... }

  // Copier avec modifications
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
