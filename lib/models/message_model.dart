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
}
