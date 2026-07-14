import 'dart:async';
import 'package:flutter/material.dart';
import '../models/chat_room_model.dart';
import '../repositories/chat_repository.dart';

class AdminChatViewModel extends ChangeNotifier {
  final ChatRepository _repo;
  List<ChatRoomModel> _rooms = [];
  bool _isLoading = true;
  StreamSubscription<List<ChatRoomModel>>? _subscription;

  AdminChatViewModel(this._repo) {
    _subscribe();
  }

  List<ChatRoomModel> get rooms => _rooms;
  bool get isLoading => _isLoading;
  
  int get totalUnread => _rooms.where((r) => r.unreadByAdmin).length;

  void _subscribe() {
    _subscription = _repo.getChatRooms().listen((data) {
      _rooms = data;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      print('AdminChatViewModel subscribe error: $e');
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> markAsRead(String chatId) async {
    // Admin marks as read when opening the chat room.
    // This calls markMessagesAsRead with the user's ID as sender.
    // Wait, the markMessagesAsRead expects the user's ID to exclude their own messages.
    // Since admin is reading, they want to mark the user's messages as read.
    await _repo.markMessagesAsRead(chatId, 'support');
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
