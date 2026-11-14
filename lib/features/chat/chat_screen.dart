import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/l10n/l10n_ext.dart';
import '../../core/providers/app_state.dart';
import '../../core/theme/app_theme.dart';
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
  late ChatRepository _repo;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _repo = ChatRepository();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 300)); // Petit délai pour l'effet
    if (mounted) setState(() => _loading = false);
  }

  // Fonction pour afficher la fenêtre de création
  void _showCreateDialog({required bool isGroup}) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isGroup ? 'Nouveau Groupe' : 'Nouveau Contact'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: isGroup ? 'Nom du groupe' : 'Nom du contact'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                if (isGroup) {
                  await _repo.createGroup(name);
                } else {
                  await _repo.createContact(name);
                }
                if (context.mounted) Navigator.pop(context);
                _load(); // Recharger la liste
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_tab == 1) return const SettingsScreen();
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.chatsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Ajouter un contact',
            onPressed: () => _showCreateDialog(isGroup: false),
          ),
          IconButton(
            icon: const Icon(Icons.group_add),
            tooltip: 'Créer un groupe',
            onPressed: () => _showCreateDialog(isGroup: true),
          ),
        ],
      ),
      body: _loading 
          ? const Center(child: CircularProgressIndicator()) 
          : FutureBuilder(
              future: _repo.getConversations(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Erreur: ${snap.error}'));
                }
                final convs = snap.data ?? [];
                if (convs.isEmpty) {
                  return const Center(child: Text('Aucune conversation. Ajoutez-en une !'));
                }
                return ListView.builder(
                  itemCount: convs.length,
                  itemBuilder: (context, i) {
                    final c = convs[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: c.isGroup ? AppColors.secondary : AppColors.primary,
                        child: Icon(c.isGroup ? Icons.group : Icons.person, color: Colors.white),
                      ),
                      title: Text(c.name),
                      subtitle: Text(c.isGroup ? 'Groupe' : 'Contact'),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(conversation: c, repo: _repo)));
                      },
                    );
                  },
                );
              },
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.chat), label: l10n.chatsTabChats),
          NavigationDestination(icon: const Icon(Icons.settings), label: l10n.chatsTabSettings),
        ],
      ),
    );
  }
}