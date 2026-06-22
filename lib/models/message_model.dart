import 'package:cloud_firestore/cloud_firestore.dart';

/// Chat message model.
class MessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final bool isRead;
  final DateTime timestamp;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.isRead,
    required this.timestamp,
  });

  /// True if this message was sent by support (not the user).
  bool get isSupport => senderId == 'support';

  MessageModel copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? text,
    bool? isRead,
    DateTime? timestamp,
  }) =>
      MessageModel(
        id: id ?? this.id,
        senderId: senderId ?? this.senderId,
        senderName: senderName ?? this.senderName,
        text: text ?? this.text,
        isRead: isRead ?? this.isRead,
        timestamp: timestamp ?? this.timestamp,
      );

  /// Serialize for Firestore (uses Timestamp for timestamp field).
  Map<String, dynamic> toFirestore() => {
        'senderId': senderId,
        'senderName': senderName,
        'text': text,
        'isRead': isRead,
        'timestamp': Timestamp.fromDate(timestamp),
      };

  /// Serialize for local / Mock storage (uses ISO string).
  Map<String, dynamic> toJson() => {
        'id': id,
        'senderId': senderId,
        'senderName': senderName,
        'text': text,
        'isRead': isRead,
        'timestamp': timestamp.toIso8601String(),
      };

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        id: json['id'] as String,
        senderId: json['senderId'] as String,
        senderName: json['senderName'] as String,
        text: json['text'] as String,
        isRead: json['isRead'] as bool,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  /// Deserialize from a Firestore document snapshot.
  factory MessageModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    final ts = data['timestamp'];
    final DateTime dt = ts is Timestamp
        ? ts.toDate()
        : DateTime.tryParse(ts?.toString() ?? '') ?? DateTime.now();

    return MessageModel(
      id: doc.id,
      senderId: data['senderId'] as String? ?? '',
      senderName: data['senderName'] as String? ?? '',
      text: data['text'] as String? ?? '',
      isRead: data['isRead'] as bool? ?? false,
      timestamp: dt,
    );
  }
}
