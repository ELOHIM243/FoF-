
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/conversation.dart';
import '../models/message.dart';

class ChatRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? get _currentUserId {
    return _supabase.auth.currentUser?.id;
  }

  // Récupérer les conversations
  Future<List<Conversation>> getConversations() async {
    final response = await _supabase
        .from('conversations')
        .select()
        .order('created_at', ascending: false);

    return response.map((row) {
      return Conversation(
        id: row['id'].toString(),
        name: row['name']?.toString() ?? 'Inconnu',
        isGroup: row['is_group'] == true,
        isOnline: false,
        unreadCount: 0,
      );
    }).toList();
  }

  // Créer un contact
  Future<void> createContact(String name) async {
    final cleanName = name.trim();

    if (cleanName.isEmpty) {
      throw ArgumentError('Le nom du contact est obligatoire.');
    }

    await _supabase.from('conversations').insert({
      'name': cleanName,
      'is_group': false,
    });
  }

  // Créer un groupe
  Future<void> createGroup(String name) async {
    final cleanName = name.trim();

    if (cleanName.isEmpty) {
      throw ArgumentError('Le nom du groupe est obligatoire.');
    }

    await _supabase.from('conversations').insert({
      'name': cleanName,
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

    final userId = _currentUserId;

    return response.map((row) {
      return Message(
        id: row['id'].toString(),
        text: row['content']?.toString() ?? '',
        createdAt: DateTime.parse(
          row['created_at'].toString(),
        ),
        status: MessageStatus.sent,
        isSentByMe: userId != null &&
            row['sender_id']?.toString() == userId,
      );
    }).toList();
  }

  // Envoyer un message
  Future<void> sendMessage(
    String convId,
    String text,
  ) async {
    final userId = _currentUserId;

    if (userId == null) {
      throw StateError(
        'Connexion Supabase obligatoire pour envoyer un message.',
      );
    }

    final cleanText = text.trim();

    if (cleanText.isEmpty) {
      throw ArgumentError('Le message ne peut pas être vide.');
    }

    await _supabase.from('messages').insert({
      'conversation_id': convId,
      'content': cleanText,
      'sender_id': userId,
    });
  }

  // Accusés de lecture
  Future<void> markAsRead(String convId) async {
    // À implémenter avec une table de lecture dédiée.
  }
}
