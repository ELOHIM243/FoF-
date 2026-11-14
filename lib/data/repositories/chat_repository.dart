import '../../core/storage/local_storage.dart';
import '../models/conversation.dart';
import '../models/message.dart';

class ChatRepository {
  final LocalStorage _storage;
  ChatRepository(this._storage);

  // La liste est maintenant vide au départ
  final List<Conversation> _convs = [];
  final Map<String, List<Message>> _messages = {};

  Future<List<Conversation>> getConversations() async => List.from(_convs);

  Future<List<Message>> getMessages(String convId) async => List.from(_messages[convId] ?? []);

  Future<void> markAsRead(String convId) async {
    final idx = _convs.indexWhere((c) => c.id == convId);
    if (idx >= 0) {
      _convs[idx] = Conversation(
        id: _convs[idx].id,
        name: _convs[idx].name,
        isGroup: _convs[idx].isGroup,
        isOnline: _convs[idx].isOnline,
        unreadCount: 0,
        lastMessage: _convs[idx].lastMessage,
      );
    }
  }

  Future<void> sendMessage(String convId, String text) async {
    final msg = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      createdAt: DateTime.now(),
      status: MessageStatus.sent,
      isSentByMe: true,
    );
    if (!_messages.containsKey(convId)) _messages[convId] = [];
    _messages[convId]!.add(msg);
    
    // Met à jour le dernier message dans la conversation
    final idx = _convs.indexWhere((c) => c.id == convId);
    if (idx >= 0) {
      _convs[idx] = Conversation(
        id: _convs[idx].id,
        name: _convs[idx].name,
        isGroup: _convs[idx].isGroup,
        isOnline: _convs[idx].isOnline,
        unreadCount: _convs[idx].unreadCount,
        lastMessage: msg,
      );
    }
  }
}