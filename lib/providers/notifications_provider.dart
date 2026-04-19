import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationsProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  StreamSubscription<List<NotificationModel>>? _notificationsSub;
  StreamSubscription<List<NotificationModel>>? _unreadSub;
  String? _notificationsUserId;
  String? _unreadUserId;

  // Liste des notifications de l'utilisateur
  List<NotificationModel> _notifications = [];
  // Liste des notifications non lues
  List<NotificationModel> _unreadNotifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  List<NotificationModel> get unreadNotifications => _unreadNotifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _unreadNotifications.length;

  // ========== CHARGER LES NOTIFICATIONS DE L'UTILISATEUR ==========
  void loadUserNotifications(String userId) {
    if (_notificationsSub != null && _notificationsUserId == userId) return;

    _notificationsUserId = userId;
    _notificationsSub?.cancel();
    _isLoading = true;
    notifyListeners();

    _notificationsSub = _notificationService
        .getUserNotifications(userId)
        .listen(
          (notifs) {
            _notifications = notifs;
            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
          },
          onError: (error) {
            _errorMessage = 'Erreur lors du chargement des notifications.';
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  // ========== CHARGER LES NOTIFICATIONS NON LUES ==========
  void loadUnreadNotifications(String userId) {
    if (_unreadSub != null && _unreadUserId == userId) return;

    _unreadUserId = userId;
    _unreadSub?.cancel();

    _unreadSub = _notificationService
        .getUnreadNotifications(userId)
        .listen(
          (notifs) {
            _unreadNotifications = notifs;
            notifyListeners();
          },
          onError: (error) {
            _errorMessage =
                'Erreur lors du chargement des notifications non lues.';
            notifyListeners();
          },
        );
  }

  // ========== MARQUER UNE NOTIFICATION COMME LUE ==========
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
      // Mettre à jour localement la liste
      _notifications = _notifications.map((notif) {
        if (notif.id == notificationId) {
          return notif.copyWith(isRead: true);
        }
        return notif;
      }).toList();
      _unreadNotifications.removeWhere((notif) => notif.id == notificationId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors du marquage comme lu.';
      notifyListeners();
    }
  }

  // ========== MARQUER TOUTES LES NOTIFICATIONS COMME LUES ==========
  Future<void> markAllAsRead(String userId) async {
    try {
      await _notificationService.markAllAsRead(userId);
      _notifications = _notifications
          .map((notif) => notif.copyWith(isRead: true))
          .toList();
      _unreadNotifications.clear();
      notifyListeners();
    } catch (e) {
      _errorMessage =
          'Erreur lors du marquage de toutes les notifications.';
      notifyListeners();
    }
  }

  // ========== SUPPRIMER UNE NOTIFICATION ==========
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      _notifications.removeWhere((notif) => notif.id == notificationId);
      _unreadNotifications.removeWhere((notif) => notif.id == notificationId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression.';
      notifyListeners();
    }
  }

  // ========== ENVOYER UNE NOTIFICATION - LIVRE DISPONIBLE ==========
  Future<void> sendBookAvailableNotification(
    String userId,
    String bookTitle,
    String bookId,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _notificationService.sendBookAvailableNotification(
        userId,
        bookTitle,
        bookId,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'envoi de la notification.';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== ENVOYER UNE NOTIFICATION - RAPPEL DE RETOUR ==========
  Future<void> sendReturnReminderNotification(
    String userId,
    String bookTitle,
    String bookId,
    DateTime dueDate,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _notificationService.sendReturnReminderNotification(
        userId,
        bookTitle,
        bookId,
        dueDate,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'envoi du rappel.';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== ENVOYER UNE NOTIFICATION - INVITATION ÉVÉNEMENT ==========
  Future<void> sendEventInvitationNotification(
    String userId,
    String eventTitle,
    String eventId,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _notificationService.sendEventInvitationNotification(
        userId,
        eventTitle,
        eventId,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'envoi de l\'invitation.';
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _notificationsSub?.cancel();
    _unreadSub?.cancel();
    super.dispose();
  }
}
