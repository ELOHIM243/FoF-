enum MessageStatus { sending, sent, delivered, read }

class Message {
  final String id;
  final String text;
  final DateTime createdAt;
  final MessageStatus status;
  final bool isSentByMe;

  Message({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.status,
    required this.isSentByMe,
  });

  Message copyWith({MessageStatus? status}) => Message(
        id: id, text: text, createdAt: createdAt,
        status: status ?? this.status, isSentByMe: isSentByMe,
      );
}
