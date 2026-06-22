import 'dart:async';
import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../repositories/chat_repository.dart';
import 'package:uuid/uuid.dart';

/// Manages real-time chat state for customer support.
class ChatViewModel extends ChangeNotifier {
  final ChatRepository _repo; // ← dùng interface, hỗ trợ cả Mock & Firebase
  final _uuid = const Uuid();

  String _chatId = 'support'; // sẽ được set per-user khi subscribe

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
  /// [userId] được dùng làm chatId để mỗi user có phòng chat riêng với admin.
  /// Nếu userId rỗng hoặc là 'guest', dùng chung phòng 'support'.
  void subscribe(String userId) {
    // Mỗi user có collection messages riêng: chats/{userId}/messages
    _chatId = (userId.isNotEmpty && userId != 'guest') ? userId : 'support';

    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();
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
