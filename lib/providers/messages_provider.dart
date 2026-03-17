import 'dart:async';

import 'package:flutter/material.dart';

import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../services/message_service.dart';

class MessagesProvider extends ChangeNotifier {
  final MessageService _messageService = MessageService();

  StreamSubscription<List<ConversationModel>>? _conversationsSub;
  List<ConversationModel> _conversations = [];
  bool _isLoading = false;
  bool _isSending = false;
  bool _isDeleting = false;
  String? _error;

  List<ConversationModel> get conversations => _conversations;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  bool get isDeleting => _isDeleting;
  String? get error => _error;

  void watchConversations(String userId) {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _conversationsSub?.cancel();
    _conversationsSub = _messageService.watchUserConversations(userId).listen(
      (data) {
        _conversations = data;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Stream<List<MessageModel>> watchMessages(String conversationId) {
    return _messageService.watchMessages(conversationId);
  }

  Future<String?> createConversation({
    required String currentUserId,
    required String currentUserName,
    required String otherUserId,
    required String otherUserName,
  }) async {
    try {
      _error = null;
      notifyListeners();
      final id = await _messageService.createConversation(
        currentUserId: currentUserId,
        currentUserName: currentUserName,
        otherUserId: otherUserId,
        otherUserName: otherUserName,
      );
      return id;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> sendMessage({
    required String conversationId,
    required String senderId,
    required String text,
  }) async {
    try {
      _isSending = true;
      _error = null;
      notifyListeners();

      await _messageService.sendMessage(
        conversationId: conversationId,
        senderId: senderId,
        text: text,
      );

      _isSending = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isSending = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> markConversationAsRead({
    required String conversationId,
    required String userId,
  }) {
    return _messageService.markConversationAsRead(
      conversationId: conversationId,
      userId: userId,
    );
  }

  Future<bool> deleteConversation({
    required String conversationId,
    required String userId,
  }) async {
    try {
      _isDeleting = true;
      _error = null;
      notifyListeners();

      await _messageService.deleteConversation(
        conversationId: conversationId,
        userId: userId,
      );

      _isDeleting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isDeleting = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _conversationsSub?.cancel();
    super.dispose();
  }
}
