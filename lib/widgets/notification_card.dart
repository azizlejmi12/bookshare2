import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/notification_model.dart';
import '../providers/notifications_provider.dart';

/// Widget pour afficher une notification unique
class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onDismiss;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onDismiss,
  });

  // Récupérer l'icône basée sur le type de notification
  IconData _getIconForType() {
    switch (notification.type) {
      case 'book_available':
        return Icons.book;
      case 'return_reminder':
        return Icons.schedule;
      case 'event_invitation':
        return Icons.event;
      default:
        return Icons.notifications;
    }
  }

  // Récupérer la couleur basée sur le type
  Color _getColorForType() {
    switch (notification.type) {
      case 'book_available':
        return Colors.green;
      case 'return_reminder':
        return Colors.orange;
      case 'event_invitation':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          // Couleur de fond plus claire si non lue
          color:
              notification.isRead ? Colors.white : Colors.grey.shade100,
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getColorForType().withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIconForType(),
              color: _getColorForType(),
            ),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              notification.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          trailing: PopupMenuButton(
            itemBuilder: (context) => [
              // Marquer comme lu/non lu
              PopupMenuItem(
                child: Text(notification.isRead ? 'Marquer comme non lu' : 'Marquer comme lu'),
                onTap: () {
                  context
                      .read<NotificationsProvider>()
                      .markAsRead(notification.id);
                },
              ),
              // Supprimer
              PopupMenuItem(
                child: const Text('Supprimer'),
                onTap: onDismiss,
              ),
            ],
          ),
          onTap: () {
            // Si la notification n'est pas lue, la marquer comme lue au tap
            if (!notification.isRead) {
              context
                  .read<NotificationsProvider>()
                  .markAsRead(notification.id);
            }
          },
        ),
      ),
    );
  }
}

/// Widget pour afficher la liste de toutes les notifications
class NotificationsList extends StatefulWidget {
  final String userId;

  const NotificationsList({
    super.key,
    required this.userId,
  });

  @override
  State<NotificationsList> createState() => _NotificationsListState();
}

class _NotificationsListState extends State<NotificationsList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<NotificationsProvider>();
      provider.loadUserNotifications(widget.userId);
      provider.loadUnreadNotifications(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationsProvider>(
      builder: (context, notificationsProvider, _) {
        if (notificationsProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (notificationsProvider.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_off,
                    size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'Aucune notification',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: notificationsProvider.notifications.length,
          itemBuilder: (context, index) {
            final notification = notificationsProvider.notifications[index];
            return NotificationCard(
              notification: notification,
              onDismiss: () {
                notificationsProvider.deleteNotification(notification.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notification supprimée')),
                );
              },
            );
          },
        );
      },
    );
  }
}

/// Widget pour afficher le nombre de notifications non lues (badge)
class NotificationBadge extends StatefulWidget {
  final String userId;

  const NotificationBadge({
    super.key,
    required this.userId,
  });

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsProvider>().loadUnreadNotifications(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationsProvider>(
      builder: (context, notificationsProvider, _) {
        final unreadCount = notificationsProvider.unreadCount;

        if (unreadCount == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          child: Text(
            unreadCount > 9 ? '9+' : unreadCount.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}
