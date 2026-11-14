import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/conversation.dart';
import '../models/message.dart';

class ChatRepository {
  final _supabase = Supabase.instance.client;

  // Récupérer les conversations
  Future<List<Conversation>> getConversations() async {
    final response = await _supabase.from('conversations').select().order('created_at', ascending: false);
    
    return response.map((row) => Conversation(
      id: row['id'].toString(),
      name: row['name'] ?? 'Inconnu',
      isGroup: row['is_group'] ?? false,
      isOnline: false,
      unreadCount: 0,
    )).toList();
  }

  // Créer un contact (conversation simple)
  Future<void> createContact(String name) async {
    await _supabase.from('conversations').insert({
      'name': name,
      'is_group': false,
    });
  }

  // Créer un groupe
  Future<void> createGroup(String name) async {
    await _supabase.from('conversations').insert({
      'name': name,
      'is_group': true,
    });
  }

  // Récupérer les messages
  Future<List<Message>> getMessages(String convId) async {
    final response = await _supabase
        .from('messages')
        .select()
        .eq('conversation_id', convId)
        .order('created_at', ascending: true);

    return response.map((row) => Message(
      id: row['id'].toString(),
      text: row['content'] ?? '',
      createdAt: DateTime.parse(row['created_at']),
      status: MessageStatus.read,
      isSentByMe: row['sender_id'] == 'moi',
    )).toList();
  }

  // Envoyer un message
  Future<void> sendMessage(String convId, String text) async {
    await _supabase.from('messages').insert({
      'conversation_id': convId,
      'content': text,
      'sender_id': 'moi',
    });
  }

  Future<void> markAsRead(String convId) async {}
}