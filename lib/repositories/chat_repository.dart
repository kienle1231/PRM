import 'dart:async';
import '../models/message_model.dart';
import '../models/chat_room_model.dart';
import 'package:uuid/uuid.dart';

/// Abstract interface for chat operations.
abstract class ChatRepository {
  Stream<List<MessageModel>> getMessages(String chatId);
  Stream<List<ChatRoomModel>> getChatRooms();
  Future<void> sendMessage(String chatId, MessageModel message);
  Future<void> markMessagesAsRead(String chatId, String userId);
}

// ── Mock Implementation ────────────────────────────────────────────────────────
/// Simulates real-time messaging with a StreamController.
class MockChatRepository implements ChatRepository {
  final _uuid = const Uuid();
  final Map<String, List<MessageModel>> _messages = {};
  final Map<String, StreamController<List<MessageModel>>> _controllers = {};

  MockChatRepository() {
    // Seed welcome messages
    final now = DateTime.now();
    _messages['support'] = [
      MessageModel(
        id: 'msg001',
        senderId: 'support',
        senderName: 'LAPTOPHUB Support',
        text: '👋 Xin chào! Tôi là nhân viên hỗ trợ LAPTOPHUB. Bạn cần tư vấn sản phẩm gì?',
        isRead: true,
        timestamp: now.subtract(const Duration(minutes: 5)),
      ),
      MessageModel(
        id: 'msg002',
        senderId: 'support',
        senderName: 'LAPTOPHUB Support',
        text: '💻 Chúng tôi có thể tư vấn về Laptop. Hãy cho chúng tôi biết nhu cầu của bạn!',
        isRead: true,
        timestamp: now.subtract(const Duration(minutes: 4, seconds: 30)),
      ),
    ];
  }

  @override
  Stream<List<ChatRoomModel>> getChatRooms() async* {
    // Just yield a mock empty list or derived list for now.
    yield _messages.entries.map((e) {
      final msgs = e.value;
      if (msgs.isEmpty) return null;
      final lastMsg = msgs.last;
      return ChatRoomModel(
        id: e.key,
        userId: e.key,
        lastMessage: lastMsg.text,
        lastMessageAt: lastMsg.timestamp,
        unreadByAdmin: msgs.any((m) => !m.isSupport && !m.isRead),
        createdAt: msgs.first.timestamp,
      );
    }).where((c) => c != null).cast<ChatRoomModel>().toList();
  }

  @override
  Stream<List<MessageModel>> getMessages(String chatId) {
    _controllers[chatId] ??= StreamController<List<MessageModel>>.broadcast();
    // Emit initial messages
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!(_controllers[chatId]?.isClosed ?? true)) {
        _controllers[chatId]!.add(List.from(_messages[chatId] ?? []));
      }
    });
    return _controllers[chatId]!.stream;
  }

  @override
  Future<void> sendMessage(String chatId, MessageModel message) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _messages[chatId] ??= [];
    _messages[chatId]!.add(message);

    // Emit updated list
    _controllers[chatId]?.add(List.from(_messages[chatId]!));

    // Simulate auto-reply from support after 1.5 seconds
    if (!message.isSupport) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        final reply = _buildAutoReply(message.text, chatId);
        _messages[chatId]!.add(reply);
        _controllers[chatId]?.add(List.from(_messages[chatId]!));
      });
    }

    // TODO: Firebase
    // await FirebaseFirestore.instance
    //     .collection('messages').doc(chatId).collection('messages')
    //     .doc(message.id).set(message.toJson());
  }

  @override
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    final list = _messages[chatId];
    if (list == null) return;
    _messages[chatId] = list.map((m) {
      if (m.senderId != userId) return m.copyWith(isRead: true);
      return m;
    }).toList();
  }

  /// Build a contextual auto-reply based on user message.
  MessageModel _buildAutoReply(String userText, String chatId) {
    final lower = userText.toLowerCase();
    String reply;

    if (lower.contains('laptop') || lower.contains('máy tính xách tay')) {
      reply = '💻 Chúng tôi có nhiều dòng laptop phù hợp! Bạn cần laptop cho mục đích gì: học tập, làm việc hay gaming? Ngân sách dự kiến là bao nhiêu?';
    } else if (lower.contains('gaming') || lower.contains('game')) {
      reply = '🎮 LAPTOPHUB có đầy đủ PC Gaming từ tầm trung đến high-end. Bạn muốn chơi game ở độ phân giải nào? 1080p hay 1440p?';
    } else if (lower.contains('giá') || lower.contains('bao nhiêu') || lower.contains('price')) {
      reply = '💰 Bạn vui lòng cho biết tên sản phẩm cụ thể để chúng tôi báo giá chính xác nhé!';
    } else if (lower.contains('bảo hành') || lower.contains('warranty')) {
      reply = '🛡️ LAPTOPHUB cam kết bảo hành chính hãng. Laptop: 12-24 tháng. PC Gaming: 24 tháng. Linh kiện: 3-36 tháng tùy loại.';
    } else if (lower.contains('giao hàng') || lower.contains('ship') || lower.contains('delivery')) {
      reply = '🚚 LAPTOPHUB giao hàng toàn quốc. Nội thành HCM/HN: 4-8 giờ. Tỉnh thành khác: 1-3 ngày. Miễn phí ship đơn trên 500k!';
    } else {
      reply = '🙂 Cảm ơn bạn đã liên hệ! Nhân viên tư vấn sẽ phản hồi trong vòng vài phút. Trong thời gian chờ, bạn có thể xem thêm sản phẩm tại mục "Sản phẩm" nhé!';
    }

    return MessageModel(
      id: _uuid.v4(),
      senderId: 'support',
      senderName: 'LAPTOPHUB Support',
      text: reply,
      isRead: false,
      timestamp: DateTime.now(),
    );
  }

  void dispose() {
    for (final ctrl in _controllers.values) {
      ctrl.close();
    }
  }
}
