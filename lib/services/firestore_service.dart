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
      isAdmin: data['isAdmin'] ?? false,
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
    await _db.collection('books').doc(bookId).update({'isAvailable': false});
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
            return {'id': doc.id, ...doc.data()};
          }).toList();
        });
  }
  // ==================== ADMIN ====================

  // Récupérer tous les utilisateurs (pour admin)
  Stream<List<UserModel>> getAllUsers() {
    return _db.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  // Promouvoir un utilisateur en admin
  Future<void> promoteToAdmin(String userId) async {
    await _db.collection('users').doc(userId).update({'isAdmin': true});
  }

  // Rétrograder un admin en utilisateur normal
  Future<void> demoteFromAdmin(String userId) async {
    await _db.collection('users').doc(userId).update({'isAdmin': false});
  }

  // Ajouter un livre (admin)
  Future<void> addBook({
    required String title,
    required String author,
    required String genre,
  }) async {
    await _db.collection('books').add({
      'title': title,
      'author': author,
      'genre': genre,
      'isAvailable': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Modifier disponibilité d'un livre
  Future<void> toggleBookAvailability(String bookId, bool isAvailable) async {
    await _db.collection('books').doc(bookId).update({
      'isAvailable': isAvailable,
    });
  }

  // Modifier un livre
  Future<void> updateBook({
    required String bookId,
    required String title,
    required String author,
    required String genre,
  }) async {
    await _db.collection('books').doc(bookId).update({
      'title': title,
      'author': author,
      'genre': genre,
    });
  }

  // Supprimer un livre
  Future<void> deleteBook(String bookId) async {
    await _db.collection('books').doc(bookId).delete();
  }

  // Mettre à jour un utilisateur
  Future<void> updateUser({
    required String uid,
    required String name,
    required String email,
  }) async {
    await _db.collection('users').doc(uid).update({
      'name': name,
      'email': email,
    });
  }

  // Supprimer un utilisateur
  Future<void> deleteUser(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }
  // ==================== LOANS AMÉLIORÉS ====================

  // Emprunter un livre (version améliorée avec dueDate)
  Future<void> borrowBook({
    required String userId,
    required String bookId,
    int durationDays = 7, // Durée par défaut : 7 jours
  }) async {
    final alreadyBorrowedByUser = await _db
        .collection('loans')
        .where('userId', isEqualTo: userId)
        .where('bookId', isEqualTo: bookId)
        .where('status', whereIn: ['active', 'extended'])
        .limit(1)
        .get();

    if (alreadyBorrowedByUser.docs.isNotEmpty) {
      throw Exception('Vous avez deja emprunte ce livre.');
    }

    final bookRef = _db.collection('books').doc(bookId);

    await _db.runTransaction((transaction) async {
      final bookDoc = await transaction.get(bookRef);
      if (!bookDoc.exists) {
        throw Exception('Livre introuvable.');
      }

      final data = bookDoc.data();
      final isAvailable = (data?['isAvailable'] as bool?) ?? true;
      if (!isAvailable) {
        throw Exception('Ce livre n\'est pas disponible actuellement.');
      }

      // Vérifie l'état courant puis écrit emprunt + indisponibilité atomiquement.
      final loanRef = _db.collection('loans').doc();
      final borrowDate = DateTime.now();
      final dueDate = borrowDate.add(Duration(days: durationDays));

      transaction.set(loanRef, {
        'userId': userId,
        'bookId': bookId,
        'borrowDate': Timestamp.fromDate(borrowDate),
        'dueDate': Timestamp.fromDate(dueDate),
        'returnDate': null,
        'status': 'active',
        'renewalCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      transaction.update(bookRef, {'isAvailable': false});
    });
  }

  // Retourner un livre
  Future<void> returnBook(String loanId, String bookId) async {
    final batch = _db.batch();

    // 1. Mettre à jour l'emprunt
    final loanRef = _db.collection('loans').doc(loanId);
    batch.update(loanRef, {
      'returnDate': Timestamp.now(),
      'status': 'returned',
    });

    // 2. Remettre le livre disponible
    final bookRef = _db.collection('books').doc(bookId);
    batch.update(bookRef, {'isAvailable': true});

    await batch.commit();
  }

  // Prolonger un emprunt (une seule fois)
  Future<void> renewLoan(String loanId, [int extraDays = 7]) async {
    final loanDoc = await _db.collection('loans').doc(loanId).get();
    if (!loanDoc.exists) return;

    final data = loanDoc.data()!;
    final currentDueDate = (data['dueDate'] as Timestamp).toDate();
    final renewalCount = data['renewalCount'] ?? 0;

    // Maximum 1 prolongation
    if (renewalCount >= 1) {
      throw Exception('Impossible de prolonger plus d\'une fois');
    }

    final newDueDate = currentDueDate.add(Duration(days: extraDays));

    await _db.collection('loans').doc(loanId).update({
      'dueDate': Timestamp.fromDate(newDueDate),
      'status': 'extended',
      'renewalCount': renewalCount + 1,
    });
  }

  // Récupérer les emprunts d'un utilisateur (temps réel avec LoanModel)
  Stream<List<Map<String, dynamic>>> getUserLoansDetailed(String userId) {
    return _db
        .collection('loans')
        .where('userId', isEqualTo: userId)
        .orderBy('borrowDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return {'id': doc.id, ...doc.data()};
          }).toList();
        });
  }

  // Récupérer les emprunts en cours d'un utilisateur
  Stream<List<Map<String, dynamic>>> getUserActiveLoans(String userId) {
    return _db
        .collection('loans')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final active = snapshot.docs.where((doc) {
            final status = doc.data()['status'];
            return status == 'active' || status == 'extended';
          }).toList();

          active.sort((a, b) {
            final aData = a.data();
            final bData = b.data();
            final aDue = (aData['dueDate'] as Timestamp?)?.toDate();
            final bDue = (bData['dueDate'] as Timestamp?)?.toDate();

            if (aDue == null && bDue == null) return 0;
            if (aDue == null) return 1;
            if (bDue == null) return -1;
            return aDue.compareTo(bDue);
          });

          return active.map((doc) {
            return {'id': doc.id, ...doc.data()};
          }).toList();
        });
  }

  // Récupérer l'historique des emprunts d'un utilisateur
  Stream<List<Map<String, dynamic>>> getUserLoanHistory(String userId) {
    return _db
        .collection('loans')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final history = snapshot.docs.where((doc) {
            final status = doc.data()['status'];
            return status == 'returned' || status == 'overdue';
          }).toList();

          history.sort((a, b) {
            final aData = a.data();
            final bData = b.data();
            final aReturn = (aData['returnDate'] as Timestamp?)?.toDate();
            final bReturn = (bData['returnDate'] as Timestamp?)?.toDate();
            final aDue = (aData['dueDate'] as Timestamp?)?.toDate();
            final bDue = (bData['dueDate'] as Timestamp?)?.toDate();

            final aDate = aReturn ?? aDue;
            final bDate = bReturn ?? bDue;

            if (aDate == null && bDate == null) return 0;
            if (aDate == null) return 1;
            if (bDate == null) return -1;
            return bDate.compareTo(aDate);
          });

          return history.map((doc) {
            return {'id': doc.id, ...doc.data()};
          }).toList();
        });
  }

  // Vérifier si un livre est déjà emprunté par l'utilisateur
  Future<bool> isBookAlreadyBorrowed(String userId, String bookId) async {
    final snapshot = await _db
        .collection('loans')
        .where('userId', isEqualTo: userId)
        .where('bookId', isEqualTo: bookId)
        .where('status', whereIn: ['active', 'extended'])
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  // Récupérer les emprunts en retard (pour notifications)
  Stream<List<Map<String, dynamic>>> getOverdueLoans() {
    final now = DateTime.now();
    return _db
        .collection('loans')
        .where('status', whereIn: ['active', 'extended'])
        .where('dueDate', isLessThan: Timestamp.fromDate(now))
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return {'id': doc.id, ...doc.data()};
          }).toList();
        });
  }
}
