
import 'package:flutter/material.dart';

import '../../core/l10n/l10n_ext.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/conversation.dart';
import '../../data/repositories/chat_repository.dart';
import '../chat/chat_screen.dart';
import '../settings/settings_screen.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  int _tab = 0;

  final ChatRepository _repo = ChatRepository();

  late Future<List<Conversation>> _conversationsFuture;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  void _loadConversations() {
    _conversationsFuture = _repo.getConversations();
  }

  Future<void> _refresh() async {
    setState(_loadConversations);
    await _conversationsFuture;
  }

  Future<void> _createConversation({
    required bool isGroup,
  }) async {
    final controller = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          isGroup ? 'Créer un groupe' : 'Ajouter un contact',
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: isGroup
                ? 'Nom du groupe'
                : 'Nom du contact',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                Navigator.pop(dialogContext, value);
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (name == null || name.trim().isEmpty) return;

    try {
      if (isGroup) {
        await _repo.createGroup(name.trim());
      } else {
        await _repo.createContact(name.trim());
      }

      if (!mounted) return;

      setState(_loadConversations);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Création réussie.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de création : $error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (_tab == 1) {
      return const SettingsScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.chatsTitle),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'contact') {
                _createConversation(isGroup: false);
              } else if (value == 'group') {
                _createConversation(isGroup: true);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'contact',
                child: Text('Ajouter un contact'),
              ),
              PopupMenuItem(
                value: 'group',
                child: Text('Créer un groupe'),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<Conversation>>(
        future: _conversationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 40),
                  const SizedBox(height: 12),
                  const Text('Impossible de charger les conversations.'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () {
                      setState(_loadConversations);
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final conversations = snapshot.data ?? [];

          if (conversations.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: const [
                  SizedBox(height: 180),
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 55,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text('Aucune conversation pour le moment.'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final conversation = conversations[index];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: conversation.isGroup
                        ? AppColors.secondary
                        : AppColors.primary,
                    child: Text(
                      conversation.initial,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(conversation.name),
                  subtitle: Text(
                    conversation.lastMessage?.text ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: conversation.unreadCount > 0
                      ? Badge(
                          label: Text(
                            conversation.unreadCount.toString(),
                          ),
                        )
                      : null,
                  onTap: () async {
                    try {
                      await _repo.markAsRead(conversation.id);

                      if (!context.mounted) return;

                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            conversation: conversation,
                            repo: _repo,
                          ),
                        ),
                      );

                      if (!mounted) return;
                      setState(_loadConversations);
                    } catch (error) {
                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erreur : $error'),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createConversation(isGroup: false),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) {
          setState(() => _tab = index);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.chat),
            label: l10n.chatsTabChats,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings),
            label: l10n.chatsTabSettings,
          ),
        ],
      ),
    );
  }
}
