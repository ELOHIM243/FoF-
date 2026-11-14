import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/conversation.dart';
import '../models/message.dart';

class ChatRepository {
  final _supabase = Supabase.instance.client;

  // Récupérer les conversations depuis Supabase (pour l'instant on crée une fausse pour tester)
  Future<List<Conversation>> getConversations() async {
    // On va chercher les conversations dans la table 'conversations'
    final response = await _supabase.from('conversations').select();
    
    if (response.isEmpty) {
      // Si la table est vide, on crée une conversation de test
      final newConv = await _supabase.from('conversations').insert({
        'name': 'Discussion Générale',
        'is_group': false,
      }).select().single();
      
      return [Conversation(
        id: newConv['id'].toString(),
        name: newConv['name'],
        isGroup: false,
        isOnline: false,
        unreadCount: 0,
      )];
    }

    return response.map((row) => Conversation(
      id: row['id'].toString(),
      name: row['name'] ?? 'Inconnu',
      isGroup: row['is_group'] ?? false,
      isOnline: false,
      unreadCount: 0,
    )).toList();
  }

  // Récupérer les messages depuis Supabase
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
      isSentByMe: row['sender_id'] == 'moi', // À remplacer par le vrai ID utilisateur
    )).toList();
  }

  // Envoyer un message à Supabase (il sera sauvegardé sur internet !)
  Future<void> sendMessage(String convId, String text) async {
    await _supabase.from('messages').insert({
      'conversation_id': convId,
      'content': text,
      'sender_id': 'moi', // À remplacer par le vrai ID utilisateur
    });
  }

  Future<void> markAsRead(String convId) async {
    // Pas besoin pour l'instant
  }
}