
import 'package:flutter/material.dart';

import 'status_editor_screen.dart';

class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key});

  Future<void> _openEditor(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const StatusEditorScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VOIR+'),
        actions: [
          IconButton(
            tooltip: 'Créer un statut',
            onPressed: () => _openEditor(context),
            icon: const Icon(Icons.add_a_photo_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Mon statut
          Card(
            child: ListTile(
              leading: Stack(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    child: Icon(Icons.person, size: 30),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.green,
                      child: const Icon(
                        Icons.add,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              title: const Text(
                'Mon statut',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Ajouter une photo ou une vidéo',
              ),
              onTap: () => _openEditor(context),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Mises à jour récentes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Center(
            child: Column(
              children: [
                Icon(
                  Icons.circle_outlined,
                  size: 60,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Aucun statut pour le moment.',
                ),
                const SizedBox(height: 5),
                Text(
                  'Les nouveaux statuts apparaîtront ici.',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context),
        icon: const Icon(Icons.add),
        label: const Text('Créer un statut'),
      ),
    );
  }
}
