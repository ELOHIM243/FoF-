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
    _repo = ChatRepository(context.read<AppState>().storage);
    _load();
  }

  Future<void> _load() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_tab == 1) return const SettingsScreen();
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.chatsTitle)),
      body: _loading ? const Center(child: CircularProgressIndicator()) : FutureBuilder(
        future: _repo.getConversations(),
        builder: (context, snap) {
          if (!snap.hasData) return const SizedBox();
          final convs = snap.data!;
          return ListView.builder(
            itemCount: convs.length,
            itemBuilder: (context, i) {
              final c = convs[i];
              return ListTile(
                leading: CircleAvatar(backgroundColor: c.isGroup ? AppColors.secondary : AppColors.primary, child: Text(c.initial, style: const TextStyle(color: Colors.white))),
                title: Text(c.name),
                subtitle: Text(c.lastMessage?.text ?? ''),
                trailing: c.unreadCount > 0 ? Badge(label: Text(c.unreadCount.toString())) : null,
                onTap: () async {
                  await _repo.markAsRead(c.id);
                  if (context.mounted) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(conversation: c, repo: _repo)));
                  }
                  setState(() {});
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
