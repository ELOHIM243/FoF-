import 'dart:math';
import '../../core/storage/local_storage.dart';
import '../models/conversation.dart';
import '../models/message.dart';

class ChatRepository {
  final LocalStorage _storage;
  ChatRepository(this._storage);

  final List<Conversation> _convs = [
    Conversation(id: 'c1', name: 'Marie', isOnline: true, unreadCount: 2, lastMessage: Message(id: 'm1', text: 'À demain !', createdAt: DateTime.now(), status: MessageStatus.read, isSentByMe: false)),
    Conversation(id: 'c2', name: 'Équipe Projet', isGroup: true, lastMessage: Message(id: 'm2', text: '📎 Fichier.pdf', createdAt: DateTime.now(), status: MessageStatus.read, isSentByMe: false)),
    Conversation(id: 'c3', name: 'Paul', lastMessage: Message(id: 'm3', text: '👍', createdAt: DateTime.now(), status: MessageStatus.read, isSentByMe: false)),
  ];

  final Map<String, List<Message>> _messages = {
    'c1': [
      Message(id: 'mm1', text: 'Salut ! 👋', createdAt: DateTime.now(), status: MessageStatus.read, isSentByMe: false),
      Message(id: 'mm2', text: 'Ça va et toi ?', createdAt: DateTime.now(), status: MessageStatus.read, isSentByMe: true),
    ],
  };

  Future<List<Conversation>> getConversations() async => List.from(_convs);

  Future<List<Message>> getMessages(String convId) async => List.from(_messages[convId] ?? []);

  Future<void> markAsRead(String convId) async {
    final idx = _convs.indexWhere((c) => c.id == convId);
    if (idx >= 0) {
      _convs[idx] = Conversation(id: _convs[idx].id, name: _convs[idx].name, isGroup: _convs[idx].isGroup, isOnline: _convs[idx].isOnline, unreadCount: 0, lastMessage: _convs[idx].lastMessage);
    }
  }

  Future<void> sendMessage(String convId, String text) async {
    final msg = Message(id: Random().nextInt(9999).toString(), text: text, createdAt: DateTime.now(), status: MessageStatus.sent, isSentByMe: true);
    if (!_messages.containsKey(convId)) _messages[convId] = [];
    _messages[convId]!.add(msg);
  }
}
