import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/events_provider.dart';
import 'event_detail_screen.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<EventsProvider, AuthProvider>(
      builder: (context, eventsProvider, auth, child) {
        final events = eventsProvider.events;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Événements'),
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF2C3E50),
          ),
          body: Builder(
            builder: (context) {
              if (eventsProvider.isLoading && events.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (eventsProvider.error != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Erreur de chargement : ${eventsProvider.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              if (events.isEmpty) {
                return const Center(
                  child: Text('Aucun événement disponible pour le moment.'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    color: const Color(0xFFF5F5F0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        event.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      subtitle: Text(
                        '${_formatDate(event.eventDate)} • ${event.registeredCount}/${event.maxParticipants} participants',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EventDetailScreen(eventId: event.id),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}