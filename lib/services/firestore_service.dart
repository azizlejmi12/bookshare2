import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==================== BOOKS ====================

  // Récupérer tous les livres en temps réel
  Stream<List<BookModel>> getBooks() {
    return _db.collection('books').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return BookModel.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  // Récupérer les livres par genre
  Stream<List<BookModel>> getBooksByGenre(String genre) {
    return _db
        .collection('books')
        .where('genre', isEqualTo: genre)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return BookModel.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  // Récupérer un livre par ID
  Future<BookModel?> getBook(String bookId) async {
    final doc = await _db.collection('books').doc(bookId).get();
    if (!doc.exists) return null;
    return BookModel.fromFirestore(doc.data()!, doc.id);
  }

  // ==================== USERS ====================

  // Sauvegarder un utilisateur
  Future<void> saveUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).set({
      'name': user.name,
      'email': user.email,
      'createdAt': Timestamp.fromDate(user.createdAt),
    });
  }

  // Récupérer un utilisateur
  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    return UserModel(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // ==================== LOANS (Emprunts) ====================

  // Créer un emprunt
  Future<void> createLoan({
    required String userId,
    required String bookId,
    required DateTime returnDate,
  }) async {
    await _db.collection('loans').add({
      'userId': userId,
      'bookId': bookId,
      'borrowDate': Timestamp.now(),
      'returnDate': Timestamp.fromDate(returnDate),
      'status': 'active',
    });

    // Marquer le livre comme indisponible
    await _db.collection('books').doc(bookId).update({
      'isAvailable': false,
    });
  }

  // Récupérer les emprunts d'un utilisateur
  Stream<List<Map<String, dynamic>>> getUserLoans(String userId) {
    return _db
        .collection('loans')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
    });
  }
}