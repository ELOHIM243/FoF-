import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/l10n/l10n_ext.dart';
import '../../core/providers/app_state.dart';

class ProfileScreen extends StatefulWidget {
  final String phone;
  const ProfileScreen({super.key, required this.phone});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _ctrl = TextEditingController();

  Future<void> _submit() async {
    final name = _ctrl.text.trim();
    if (name.isEmpty) return;
    
    // Connexion
    await context.read<AppState>().login(name, widget.phone);
    
    // Pause pour éviter le bug de rafraîchissement
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(l10n.profileTitle, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            TextField(
              controller: _ctrl, 
              decoration: InputDecoration(labelText: l10n.profileNameLabel),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: Text(l10n.profileSubmit),
            )
          ],
        ),
      ),
    );
  }
}