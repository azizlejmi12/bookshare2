import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ========== CRÉER UNE NOTIFICATION ==========
  Future<void> createNotification(NotificationModel notification) async {
    await _db.collection('notifications').add(notification.toFirestore());
  }

  // ========== RÉCUPÉRER LES NOTIFICATIONS D'UN UTILISATEUR ==========
  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final notifications = snapshot.docs.map((doc) {
            return NotificationModel.fromFirestore(doc.data(), doc.id);
          }).toList();

          // Tri côté client pour éviter l'index composite Firestore.
          notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return notifications;
        });
  }

  // ========== RÉCUPÉRER LES NOTIFICATIONS NON LUES ==========
  Stream<List<NotificationModel>> getUnreadNotifications(String userId) {
    return getUserNotifications(userId).map((notifications) {
      return notifications.where((notif) => !notif.isRead).toList();
    });
  }

  // ========== MARQUER UNE NOTIFICATION COMME LUE ==========
  Future<void> markAsRead(String notificationId) async {
    try {
      await _db.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      print('Erreur marquer comme lu: $e');
      rethrow;
    }
  }

  // ========== MARQUER TOUTES LES NOTIFICATIONS COMME LUES ==========
  Future<void> markAllAsRead(String userId) async {
    try {
      final query = await _db
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in query.docs) {
        final isRead = (doc.data()['isRead'] as bool?) ?? false;
        if (!isRead) {
          await doc.reference.update({'isRead': true});
        }
      }
    } catch (e) {
      print('Erreur marquer tous comme lu: $e');
      rethrow;
    }
  }

  // ========== SUPPRIMER UNE NOTIFICATION ==========
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _db.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      print('Erreur suppression notification: $e');
      rethrow;
    }
  }

  // ========== ENVOYER UNE NOTIFICATION - LIVRE DISPONIBLE ==========
  Future<void> sendBookAvailableNotification(
    String userId,
    String bookTitle,
    String bookId,
  ) async {
    final notification = NotificationModel(
      id: '',
      userId: userId,
      title: 'Livre disponible ! 📚',
      message: '$bookTitle est maintenant disponible à l\'emprunt.',
      type: 'book_available',
      bookId: bookId,
      createdAt: DateTime.now(),
    );

    await createNotification(notification);
  }

  // ========== ENVOYER UNE NOTIFICATION - RAPPEL DE RETOUR ==========
  Future<void> sendReturnReminderNotification(
    String userId,
    String bookTitle,
    String bookId,
    DateTime dueDate,
  ) async {
    final daysLeft = dueDate.difference(DateTime.now()).inDays;

    final notification = NotificationModel(
      id: '',
      userId: userId,
      title: 'Rappel de retour 🔔',
      message:
          'Vous devez retourner "$bookTitle" dans $daysLeft jour${daysLeft > 1 ? 's' : ''}.',
      type: 'return_reminder',
      bookId: bookId,
      createdAt: DateTime.now(),
    );

    await createNotification(notification);
  }

  // ========== ENVOYER UNE NOTIFICATION - INVITATION ÉVÉNEMENT ==========
  Future<void> sendEventInvitationNotification(
    String userId,
    String eventTitle,
    String eventId,
  ) async {
    final notification = NotificationModel(
      id: '',
      userId: userId,
      title: 'Invitation à un événement 🎉',
      message: 'Vous êtes invité à : $eventTitle',
      type: 'event_invitation',
      eventId: eventId,
      createdAt: DateTime.now(),
    );

    await createNotification(notification);
  }
}
