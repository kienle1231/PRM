import 'dart:async';
import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../repositories/chat_repository.dart';
import 'package:uuid/uuid.dart';

/// Manages real-time chat state for customer support.
class ChatViewModel extends ChangeNotifier {
  final MockChatRepository _repo;
  final _uuid = const Uuid();

  static const String _chatId = 'support';

  List<MessageModel> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  StreamSubscription<List<MessageModel>>? _subscription;

  ChatViewModel(this._repo);

  // ── Getters ───────────────────────────────────────────────────────────────
  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;

  /// Number of unread messages from support.
  int get unreadFromSupport =>
      _messages.where((m) => m.isSupport && !m.isRead).length;

  // ── Subscribe to Messages ─────────────────────────────────────────────────
  void subscribe(String userId) {
    _isLoading = true;
    notifyListeners();

    _subscription = _repo.getMessages(_chatId).listen((msgs) {
      _messages = msgs;
      _isLoading = false;
      notifyListeners();
    }, onError: (_) {
      _isLoading = false;
      notifyListeners();
    });
  }

  // ── Send Message ──────────────────────────────────────────────────────────
  Future<void> sendMessage(String text, String userId, String userName) async {
    if (text.trim().isEmpty) return;
    _isSending = true;
    notifyListeners();

    final message = MessageModel(
      id: _uuid.v4(),
      senderId: userId,
      senderName: userName,
      text: text.trim(),
      isRead: false,
      timestamp: DateTime.now(),
    );

    try {
      await _repo.sendMessage(_chatId, message);
    } catch (_) {
      // Silent fail
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  // ── Mark as Read ──────────────────────────────────────────────────────────
  Future<void> markAsRead(String userId) async {
    await _repo.markMessagesAsRead(_chatId, userId);
    _messages = _messages
        .map((m) => m.isSupport ? m.copyWith(isRead: true) : m)
        .toList();
    notifyListeners();
  }

  // ── Cleanup ───────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
