
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/l10n_ext.dart';
import '../../core/providers/app_state.dart';
import 'rules_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(l10n.settingsThemeDark),
            value: state.themeMode == ThemeMode.dark,
            onChanged: (v) => state.setThemeMode(
              v ? ThemeMode.dark : ThemeMode.light,
            ),
          ),
          ListTile(
            title: Text(l10n.settingsLanguage),
            trailing: DropdownButton<String>(
              value: state.locale.languageCode,
              items: const [
                DropdownMenuItem(value: 'fr', child: Text('FR')),
                DropdownMenuItem(value: 'en', child: Text('EN')),
                DropdownMenuItem(value: 'ar', child: Text('AR')),
              ],
              onChanged: (v) {
                if (v != null) state.setLocale(Locale(v));
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.gavel),
            title: const Text('Règles de la communauté'),
            subtitle: const Text('Consulter les 20 règles de FOF'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RulesScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: Text(
              l10n.settingsLogout,
              style: const TextStyle(color: Colors.red),
            ),
            onTap: () => state.logout(),
          ),
        ],
      ),
    );
  }
}
