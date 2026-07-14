import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a chat room metadata.
class ChatRoomModel {
  final String id;
  final String userId;
  final String lastMessage;
  final DateTime lastMessageAt;
  final bool unreadByAdmin;
  final DateTime createdAt;

  const ChatRoomModel({
    required this.id,
    required this.userId,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadByAdmin,
    required this.createdAt,
  });

  factory ChatRoomModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    
    DateTime parseTime(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    return ChatRoomModel(
      id: doc.id,
      userId: data['userId'] as String? ?? doc.id,
      lastMessage: data['lastMessage'] as String? ?? '',
      lastMessageAt: parseTime(data['lastMessageAt']),
      unreadByAdmin: data['unreadByAdmin'] as bool? ?? false,
      createdAt: parseTime(data['createdAt']),
    );
  }
}
