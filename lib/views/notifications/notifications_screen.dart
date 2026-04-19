import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../widgets/notification_card.dart';

/// Page pour afficher toutes les notifications de l'utilisateur
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les notifications au lancement de la page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final notifProvider = Provider.of<NotificationsProvider>(
        context,
        listen: false,
      );

      if (authProvider.currentUser != null) {
        notifProvider.loadUserNotifications(authProvider.currentUser!.uid);
        notifProvider.loadUnreadNotifications(authProvider.currentUser!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notifications')),
        body: const Center(child: Text('Veuillez vous connecter.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        elevation: 0,
        actions: [
          // Bouton pour marquer toutes les notifications comme lues
          Consumer<NotificationsProvider>(
            builder: (context, notifProvider, _) {
              if (notifProvider.unreadCount == 0) {
                return const SizedBox.shrink();
              }

              return IconButton(
                icon: const Icon(Icons.done_all),
                tooltip: 'Marquer tout comme lu',
                onPressed: () {
                  notifProvider.markAllAsRead(currentUser.uid);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Toutes les notifications ont été marquées comme lues.',
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationsProvider>(
        builder: (context, notifProvider, _) {
          // Afficher un message de chargement
          if (notifProvider.isLoading && notifProvider.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Afficher un message vide
          if (notifProvider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Aucune notification',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vos notifications apparaîtront ici.',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          // Afficher les notifications groupées par statut (non lues d'abord)
          final unreadNotifications = notifProvider.notifications
              .where((notif) => !notif.isRead)
              .toList();
          final readNotifications = notifProvider.notifications
              .where((notif) => notif.isRead)
              .toList();

          return RefreshIndicator(
            onRefresh: () async {
              notifProvider.loadUserNotifications(currentUser.uid);
              notifProvider.loadUnreadNotifications(currentUser.uid);
            },
            child: ListView(
              children: [
                // Section - Notifications non lues
                if (unreadNotifications.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Non lues (${unreadNotifications.length})',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                  ...unreadNotifications.map((notif) {
                    return NotificationCard(
                      notification: notif,
                      onDismiss: () {
                        notifProvider.deleteNotification(notif.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Notification supprimée.'),
                          ),
                        );
                      },
                    );
                  }),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(),
                  ),
                ],

                // Section - Notifications lues
                if (readNotifications.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Text(
                      'Lues (${readNotifications.length})',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                ...readNotifications.map((notif) {
                  return NotificationCard(
                    notification: notif,
                    onDismiss: () {
                      notifProvider.deleteNotification(notif.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notification supprimée.'),
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
