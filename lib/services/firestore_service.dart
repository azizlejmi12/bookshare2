import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book_model.dart';
import '../models/user_model.dart';
import 'notification_service.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

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
      'profileImageUrl': user.profileImageUrl,
      'isAdmin': user.isAdmin,
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
      profileImageUrl: data['profileImageUrl'],
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
  Future<String> addBook({
    required String title,
    required String author,
    required String genre,
    String? coverUrl,
  }) async {
    final docRef = await _db.collection('books').add({
      'title': title,
      'author': author,
      'genre': genre,
      'isAvailable': true,
      'coverUrl': coverUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
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
    String? coverUrl,
  }) async {
    final payload = <String, dynamic>{
      'title': title,
      'author': author,
      'genre': genre,
    };

    if (coverUrl != null) {
      payload['coverUrl'] = coverUrl;
    }

    await _db.collection('books').doc(bookId).update(payload);
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
    String? profileImageUrl,
    bool shouldUpdateProfileImage = false,
  }) async {
    final payload = <String, dynamic>{
      'name': name,
      'email': email,
    };

    if (shouldUpdateProfileImage) {
      payload['profileImageUrl'] = profileImageUrl;
    }

    await _db.collection('users').doc(uid).update(payload);
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
      throw Exception('Vous avez déjà emprunté ce livre.');
    }

    final bookRef = _db.collection('books').doc(bookId);
    final bookDoc = await bookRef.get();
    if (!bookDoc.exists) {
      throw Exception('Livre introuvable.');
    }

    final bookData = bookDoc.data();
    final isAvailable = (bookData?['isAvailable'] as bool?) ?? true;
    if (!isAvailable) {
      await _registerBookAvailabilityAlert(userId: userId, bookId: bookId);
      throw Exception(
        'Ce livre n\'est pas disponible actuellement. Vous serez notifié lorsqu\'il redeviendra disponible.',
      );
    }

    await _db.runTransaction((transaction) async {
      final txBookDoc = await transaction.get(bookRef);
      if (!txBookDoc.exists) {
        throw Exception('Livre introuvable.');
      }

      final txData = txBookDoc.data();
      final txIsAvailable = (txData?['isAvailable'] as bool?) ?? true;
      if (!txIsAvailable) {
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
    // Exécuter comme une transaction pour plus de robustesse.
    await _db.runTransaction((transaction) async {
      // 1. Lire et vérifier que l'utilisateur possède ce prêt
      final loanRef = _db.collection('loans').doc(loanId);
      final loanDoc = await transaction.get(loanRef);

      if (!loanDoc.exists) {
        throw Exception('Cet emprunt n\'existe pas.');
      }

      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      final loanUserId = loanDoc.data()?['userId'] as String?;

      if (loanUserId != currentUserId) {
        throw Exception(
          'Vous n\'avez pas la permission de retourner ce livre (ce n\'est pas votre emprunt).',
        );
      }

      // 2. Mettre à jour l'emprunt
      transaction.update(loanRef, {
        'returnDate': Timestamp.now(),
        'status': 'returned',
      });

      // 3. Remettre le livre disponible
      final bookRef = _db.collection('books').doc(bookId);
      transaction.update(bookRef, {'isAvailable': true});
    });

    // Notifier les utilisateurs abonnés à la disponibilité de ce livre.
    // Si la notification échoue, on garde le retour de livre comme succès.
    try {
      final loanDoc = await _db.collection('loans').doc(loanId).get();
      final returnedByUserId = loanDoc.data()?['userId'] as String?;
      if (returnedByUserId != null) {
        await _notifyBookAvailableSubscribers(
          bookId: bookId,
          excludeUserId: returnedByUserId,
        );
      }
    } catch (_) {}
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
      throw Exception('Impossible de prolonger plus d\'une fois.');
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

  // Envoyer des rappels de retour pour les emprunts qui arrivent bientôt.
  Future<void> sendDueSoonRemindersForUser(
    String userId, {
    int daysBefore = 2,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final limitDate = today.add(Duration(days: daysBefore + 1));

    final snapshot = await _db
        .collection('loans')
        .where('userId', isEqualTo: userId)
        .get();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final dueDate = (data['dueDate'] as Timestamp?)?.toDate();
      if (dueDate == null) continue;

      final status = (data['status'] as String?) ?? '';
      final isActiveLoan = status == 'active' || status == 'extended';
      if (!isActiveLoan) continue;

      if (!dueDate.isBefore(limitDate)) continue;

      // Ignorer les emprunts déjà échus pour ce rappel "bientôt".
      if (dueDate.isBefore(today)) continue;

      // Ne pas envoyer plusieurs rappels le même jour.
      final lastReminderAt = (data['lastReminderSentAt'] as Timestamp?)
          ?.toDate();
      final alreadySentToday =
          lastReminderAt != null &&
          lastReminderAt.year == today.year &&
          lastReminderAt.month == today.month &&
          lastReminderAt.day == today.day;
      if (alreadySentToday) continue;

      final bookId = (data['bookId'] as String?) ?? '';
      if (bookId.isEmpty) continue;

      final bookDoc = await _db.collection('books').doc(bookId).get();
      final bookTitle = (bookDoc.data()?['title'] as String?) ?? 'Ce livre';

      await _notificationService.sendReturnReminderNotification(
        userId,
        bookTitle,
        bookId,
        dueDate,
      );

      await doc.reference.update({'lastReminderSentAt': Timestamp.now()});
    }
  }

  Future<void> _registerBookAvailabilityAlert({
    required String userId,
    required String bookId,
  }) async {
    final existing = await _db
        .collection('book_alerts')
        .where('userId', isEqualTo: userId)
        .get();

    final alreadySubscribed = existing.docs.any((doc) {
      return (doc.data()['bookId'] as String?) == bookId;
    });

    if (alreadySubscribed) return;

    await _db.collection('book_alerts').add({
      'userId': userId,
      'bookId': bookId,
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> _notifyBookAvailableSubscribers({
    required String bookId,
    String? excludeUserId,
  }) async {
    final alertsSnapshot = await _db
        .collection('book_alerts')
        .where('bookId', isEqualTo: bookId)
        .get();

    if (alertsSnapshot.docs.isEmpty) return;

    final bookDoc = await _db.collection('books').doc(bookId).get();
    final bookTitle = (bookDoc.data()?['title'] as String?) ?? 'Ce livre';

    for (final alertDoc in alertsSnapshot.docs) {
      final userId = alertDoc.data()['userId'] as String?;
      if (userId == null || userId.isEmpty) {
        await alertDoc.reference.delete();
        continue;
      }

      if (excludeUserId != null && userId == excludeUserId) {
        await alertDoc.reference.delete();
        continue;
      }

      await _notificationService.sendBookAvailableNotification(
        userId,
        bookTitle,
        bookId,
      );

      // Supprimer l'abonnement une fois la notification envoyée.
      await alertDoc.reference.delete();
    }
  }
}
