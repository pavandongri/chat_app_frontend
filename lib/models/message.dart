import 'message_status.dart';

/// A single message row, as returned by `/api/messages*`. That module's
/// JSON is camelCase (like `/api/profile`), not the snake_case most of the
/// rest of the backend uses.
class Message {
  const Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.status,
    required this.editedAt,
    required this.createdAt,
  });

  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final MessageStatus status;
  final DateTime? editedAt;
  final DateTime createdAt;

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      message: json['message'] as String,
      status: messageStatusFromJson(json['status'] as String),
      editedAt: json['editedAt'] == null
          ? null
          : DateTime.parse(json['editedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Message copyWith({
    String? message,
    MessageStatus? status,
    DateTime? editedAt,
  }) {
    return Message(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      message: message ?? this.message,
      status: status ?? this.status,
      editedAt: editedAt ?? this.editedAt,
      createdAt: createdAt,
    );
  }
}
