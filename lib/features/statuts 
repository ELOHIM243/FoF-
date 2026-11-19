
import 'package:flutter/material.dart';

class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statuts'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('VOIR+'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: Stack(
              children: [
                const CircleAvatar(
                  radius: 28,
                  child: Icon(Icons.person),
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
            title: const Text('Mon statut'),
            subtitle: const Text('Ajouter une mise à jour'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Publication des statuts à connecter.'),
                ),
              );
            },
          ),
          const Divider(height: 30),
          const Text(
            'Mises à jour récentes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Column(
              children: [
                Icon(
                  Icons.circle_outlined,
                  size: 55,
                  color: Colors.grey,
                ),
                SizedBox(height: 12),
                Text('Aucun statut pour le moment.'),
                SizedBox(height: 5),
                Text(
                  'Les nouveaux statuts apparaîtront ici.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
