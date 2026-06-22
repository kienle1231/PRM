import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../models/message_model.dart';
import 'chat_repository.dart';

/// Firebase Firestore real-time implementation of [ChatRepository].
///
/// Cấu trúc Firestore:
///   chats/{chatId}/messages/{messageId}
///   chats/{chatId}/meta   → { createdAt, lastMessage }
///
/// Mỗi user có phòng chat riêng với admin: chatId = userId.
class FirebaseChatRepository implements ChatRepository {
  FirebaseChatRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  final _uuid = const Uuid();

  DocumentReference<Map<String, dynamic>> _chatDoc(String chatId) =>
      _db.collection('chats').doc(chatId);

  CollectionReference<Map<String, dynamic>> _messages(String chatId) =>
      _chatDoc(chatId).collection('messages');

  // ── Get Messages Stream ───────────────────────────────────────────────────
  @override
  Stream<List<MessageModel>> getMessages(String chatId) {
    // Seed welcome message nếu đây là phòng mới (chạy async, không block stream)
    _ensureWelcomeMessage(chatId);

    return _messages(chatId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => MessageModel.fromFirestore(
                  doc as DocumentSnapshot<Map<String, dynamic>>,
                ))
            .toList());
  }

  /// Kiểm tra nếu phòng chat chưa có tin nhắn nào → tạo welcome message từ support.
  Future<void> _ensureWelcomeMessage(String chatId) async {
    try {
      final existing = await _messages(chatId).limit(1).get();
      if (existing.docs.isNotEmpty) return; // Đã có tin nhắn rồi

      // Tạo welcome message từ support
      final welcome = MessageModel(
        id: _uuid.v4(),
        senderId: 'support',
        senderName: 'LAPTOPHUB Support',
        text: '👋 Xin chào! Tôi là nhân viên hỗ trợ LAPTOPHUB. '
            'Bạn cần tư vấn sản phẩm gì? Chúng tôi sẵn sàng hỗ trợ bạn!',
        isRead: true,
        timestamp: DateTime.now(),
      );

      await _messages(chatId).doc(welcome.id).set(welcome.toFirestore());

      // Ghi meta để admin biết có user mới chat
      await _chatDoc(chatId).set({
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': welcome.text,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'userId': chatId,
        'unreadByAdmin': false,
      }, SetOptions(merge: true));
    } catch (_) {
      // Không ảnh hưởng đến stream nếu bị lỗi
    }
  }

  // ── Send Message ──────────────────────────────────────────────────────────
  @override
  Future<void> sendMessage(String chatId, MessageModel message) async {
    // Lưu tin nhắn vào sub-collection
    await _messages(chatId).doc(message.id).set(message.toFirestore());

    // Cập nhật meta của phòng chat (để admin thấy tin nhắn mới nhất)
    await _chatDoc(chatId).set({
      'lastMessage': message.text,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'userId': chatId,
      'unreadByAdmin': !message.isSupport, // user gửi → admin chưa đọc
    }, SetOptions(merge: true));
  }

  // ── Mark as Read ──────────────────────────────────────────────────────────
  @override
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      final snap = await _messages(chatId)
          .where('isRead', isEqualTo: false)
          .where('senderId', isNotEqualTo: userId)
          .get();

      if (snap.docs.isEmpty) return;

      final batch = _db.batch();
      for (final doc in snap.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (_) {
      // Silent fail
    }
  }
}
