class BookModel {
  final String id;
  final String title;
  final String author;
  final String? coverUrl;
  final String? description;
  final String category;
  final String ownerId;
  final String ownerName;
  final bool isAvailable;
  final DateTime createdAt;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    this.coverUrl,
    this.description,
    required this.category,
    required this.ownerId,
    required this.ownerName,
    this.isAvailable = true,
    required this.createdAt,
  });

  // TODO: Ajouter Firestore quand nécessaire
  // factory BookModel.fromFirestore(DocumentSnapshot doc) { ... }
  // Map<String, dynamic> toFirestore() { ... }

  // Copier avec modifications
  BookModel copyWith({
    String? id,
    String? title,
    String? author,
    String? coverUrl,
    String? description,
    String? category,
    String? ownerId,
    String? ownerName,
    bool? isAvailable,
    DateTime? createdAt,
  }) {
    return BookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      coverUrl: coverUrl ?? this.coverUrl,
      description: description ?? this.description,
      category: category ?? this.category,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
