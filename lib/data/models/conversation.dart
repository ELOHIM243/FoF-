import 'message.dart';

class Conversation {
  final String id;
  final String name;
  final bool isGroup;
  final bool isOnline;
  final int unreadCount;
  final Message? lastMessage;

  Conversation({
    required this.id,
    required this.name,
    this.isGroup = false,
    this.isOnline = false,
    this.unreadCount = 0,
    this.lastMessage,
  });

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';
}
