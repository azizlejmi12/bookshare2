import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/events_provider.dart';

class EventDetailScreen extends StatelessWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Consumer2<EventsProvider, AuthProvider>(
      builder: (context, eventsProvider, auth, child) {
        final event = eventsProvider.events.where((item) => item.id == eventId).firstOrNull;

        if (eventsProvider.isLoading && event == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Détail événement'),
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2C3E50),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (eventsProvider.error != null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Détail événement'),
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2C3E50),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Erreur de chargement : ${eventsProvider.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        if (event == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Événement'),
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2C3E50),
            ),
            body: const Center(
              child: Text('Événement introuvable.'),
            ),
          );
        }

        final currentUserName = auth.currentUser?.name;
        final isRegistered = currentUserName != null && event.participants.contains(currentUserName);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Détail événement'),
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF2C3E50),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                event.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 8),
              Text(event.description),
              const SizedBox(height: 12),
              Text('Date: ${_formatDate(event.eventDate)}'),
              Text('Participants: ${event.registeredCount}/${event.maxParticipants}'),
              Text('Places restantes: ${event.availableSpots}'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: currentUserName == null
                    ? null
                    : () async {
                        final message = isRegistered
                            ? await eventsProvider.removeParticipant(event.id, currentUserName)
                            : await eventsProvider.addParticipant(event.id, currentUserName);

                        if (message != null && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(message)),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C3E50),
                  foregroundColor: Colors.white,
                ),
                child: Text(isRegistered ? 'Se désinscrire' : 'S\'inscrire'),
              ),
              const SizedBox(height: 20),
              const Text(
                'Participants',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 8),
              if (event.participants.isEmpty)
                const Text('Aucun participant pour le moment.')
              else
                ...event.participants.map(
                  (participant) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.person),
                    title: Text(participant),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}