import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationModel {
  final String id;
  final List<String> participants;
  final Map<String, String> participantNames;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final DateTime? updatedAt;
  final Map<String, int> unreadCount;

  ConversationModel({
    required this.id,
    required this.participants,
    required this.participantNames,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.updatedAt,
    required this.unreadCount,
  });

  factory ConversationModel.fromMap(Map<String, dynamic> data, String id) {
    final rawNames = (data['participantNames'] as Map<String, dynamic>?) ?? {};
    final rawUnread = (data['unreadCount'] as Map<String, dynamic>?) ?? {};

    return ConversationModel(
      id: id,
      participants: List<String>.from(data['participants'] ?? const <String>[]),
      participantNames: rawNames.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      ),
      lastMessage: (data['lastMessage'] as String?) ?? '',
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      unreadCount: rawUnread.map(
        (key, value) => MapEntry(key, (value as num?)?.toInt() ?? 0),
      ),
    );
  }

  String otherParticipantId(String currentUserId) {
    for (final id in participants) {
      if (id != currentUserId) return id;
    }
    return '';
  }

  String displayNameFor(String currentUserId) {
    final otherId = otherParticipantId(currentUserId);
    if (otherId.isEmpty) return 'Conversation';
    final name = participantNames[otherId] ?? '';
    if (name.isNotEmpty) return name;
    return 'Utilisateur';
  }

  int unreadFor(String userId) {
    return unreadCount[userId] ?? 0;
  }
}
