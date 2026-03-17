import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/conversation_model.dart';
import '../models/message_model.dart';

class MessageService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<ConversationModel>> watchUserConversations(String userId) {
    return _db
        .collection('conversations')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
          final conversations = snapshot.docs
              .map((doc) => ConversationModel.fromMap(doc.data(), doc.id))
              .toList();

          conversations.sort((a, b) {
            final aDate = a.updatedAt ?? a.lastMessageAt ?? DateTime(1970);
            final bDate = b.updatedAt ?? b.lastMessageAt ?? DateTime(1970);
            return bDate.compareTo(aDate);
          });

          return conversations;
        });
  }

  Stream<List<MessageModel>> watchMessages(String conversationId) {
    return _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('sentAt')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) => MessageModel.fromMap(
                  doc.data(),
                  doc.id,
                  conversationId,
                ),
              )
              .toList();
        });
  }

  Future<String> createConversation({
    required String currentUserId,
    required String currentUserName,
    required String otherUserId,
    required String otherUserName,
  }) async {
    final existing = await _db
        .collection('conversations')
        .where('participants', arrayContains: currentUserId)
        .get();

    for (final doc in existing.docs) {
      final participants = List<String>.from(doc.data()['participants'] ?? const <String>[]);
      if (participants.length == 2 && participants.contains(otherUserId)) {
        return doc.id;
      }
    }

    final conversationRef = _db.collection('conversations').doc();
    final now = Timestamp.now();

    await conversationRef.set({
      'participants': [currentUserId, otherUserId],
      'participantNames': {
        currentUserId: currentUserName,
        otherUserId: otherUserName,
      },
      'lastMessage': '',
      'lastMessageAt': now,
      'updatedAt': now,
      'unreadCount': {
        currentUserId: 0,
        otherUserId: 0,
      },
    });

    return conversationRef.id;
  }

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final conversationRef = _db.collection('conversations').doc(conversationId);

    await _db.runTransaction((transaction) async {
      final conversationDoc = await transaction.get(conversationRef);
      if (!conversationDoc.exists) {
        throw Exception('Conversation introuvable.');
      }

      final data = conversationDoc.data() ?? <String, dynamic>{};
      final participants = List<String>.from(data['participants'] ?? const <String>[]);
      final currentUnreadRaw =
          (data['unreadCount'] as Map<String, dynamic>?) ?? <String, dynamic>{};
      final updatedUnread = currentUnreadRaw.map(
        (key, value) => MapEntry(key, (value as num?)?.toInt() ?? 0),
      );

      for (final userId in participants) {
        if (userId == senderId) {
          updatedUnread[userId] = 0;
        } else {
          updatedUnread[userId] = (updatedUnread[userId] ?? 0) + 1;
        }
      }

      final messageRef = conversationRef.collection('messages').doc();
      final now = Timestamp.now();

      transaction.set(messageRef, {
        'senderId': senderId,
        'text': trimmed,
        'sentAt': now,
        'readBy': [senderId],
      });

      transaction.update(conversationRef, {
        'lastMessage': trimmed,
        'lastMessageAt': now,
        'updatedAt': now,
        'unreadCount': updatedUnread,
      });
    });
  }

  Future<void> markConversationAsRead({
    required String conversationId,
    required String userId,
  }) async {
    final conversationRef = _db.collection('conversations').doc(conversationId);
    final conversationDoc = await conversationRef.get();

    if (conversationDoc.exists) {
      final data = conversationDoc.data() ?? <String, dynamic>{};
      final currentUnreadRaw =
          (data['unreadCount'] as Map<String, dynamic>?) ?? <String, dynamic>{};
      final updatedUnread = currentUnreadRaw.map(
        (key, value) => MapEntry(key, (value as num?)?.toInt() ?? 0),
      );
      updatedUnread[userId] = 0;
      await conversationRef.update({'unreadCount': updatedUnread});
    }

    final unreadMessages = await conversationRef
        .collection('messages')
        .orderBy('sentAt', descending: true)
        .limit(100)
        .get();

    final batch = _db.batch();
    for (final doc in unreadMessages.docs) {
      final data = doc.data();
      final senderId = (data['senderId'] as String?) ?? '';
      final readBy = List<String>.from(data['readBy'] ?? const <String>[]);
      if (senderId != userId && !readBy.contains(userId)) {
        batch.update(doc.reference, {
          'readBy': FieldValue.arrayUnion([userId]),
        });
      }
    }

    await batch.commit();
  }

  Future<void> deleteConversation({
    required String conversationId,
    required String userId,
  }) async {
    final conversationRef = _db.collection('conversations').doc(conversationId);
    final conversationDoc = await conversationRef.get();

    if (!conversationDoc.exists) return;

    final data = conversationDoc.data() ?? <String, dynamic>{};
    final participants = List<String>.from(
      data['participants'] ?? const <String>[],
    );

    if (!participants.contains(userId)) {
      throw Exception('Suppression non autorisee.');
    }

    while (true) {
      final messagesBatch = await conversationRef
          .collection('messages')
          .limit(400)
          .get();

      if (messagesBatch.docs.isEmpty) break;

      final batch = _db.batch();
      for (final doc in messagesBatch.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      if (messagesBatch.docs.length < 400) break;
    }

    await conversationRef.delete();
  }
}
