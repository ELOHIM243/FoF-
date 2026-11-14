import 'package:flutter/material.dart';
import '../../core/l10n/l10n_ext.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/conversation.dart';
import '../../data/models/message.dart';
import '../../data/repositories/chat_repository.dart';

class ChatScreen extends StatefulWidget {
  final Conversation conversation;
  final ChatRepository repo;
  const ChatScreen({super.key, required this.conversation, required this.repo});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  List<Message> _msgs = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final m = await widget.repo.getMessages(widget.conversation.id);
    if (mounted) setState(() => _msgs = m);
  }

  Future<void> _send() async {
    if (_ctrl.text.trim().isEmpty) return;
    await widget.repo.sendMessage(widget.conversation.id, _ctrl.text.trim());
    _ctrl.clear();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.conversation.name)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _msgs.length,
              itemBuilder: (context, i) {
                final m = _msgs[i];
                final isMe = m.isSentByMe;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? AppColors.primary : Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(m.text, style: TextStyle(color: isMe ? Colors.white : Colors.black)),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _ctrl, decoration: InputDecoration(hintText: context.l10n.chatInputPlaceholder, border: const OutlineInputBorder()))),
                IconButton(icon: const Icon(Icons.send, color: AppColors.primary), onPressed: _send),
              ],
            ),
          )
        ],
      ),
    );
  }
}
