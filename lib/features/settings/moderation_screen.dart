
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ModerationScreen extends StatefulWidget {
  const ModerationScreen({super.key});

  @override
  State<ModerationScreen> createState() => _ModerationScreenState();
}

class _ModerationScreenState extends State<ModerationScreen> {
  late Future<List<Map<String, dynamic>>> _alerts;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  void _loadAlerts() {
    setState(() {
      _alerts = _getAlerts();
    });
  }

  Future<List<Map<String, dynamic>>> _getAlerts() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;

    if (user == null) {
      throw Exception('Connecte-toi pour consulter tes alertes.');
    }

    final data = await client
        .from('moderation_alerts')
        .select(
          'id, rule_number, level, title, message, status, issued_at, expires_at',
        )
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> _sendAppeal(
    String alertId,
    String message,
  ) async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      throw Exception('Connecte-toi pour envoyer un recours.');
    }

    final text = message.trim();

    if (text.length < 10 || text.length > 2000) {
      throw Exception(
        'Le recours doit contenir entre 10 et 2000 caractères.',
      );
    }

    await Supabase.instance.client
        .from('moderation_appeals')
        .insert({
      'alert_id': alertId,
      'user_id': user.id,
      'appeal_message': text,
    });
  }

  Future<void> _openAppeal(String alertId) async {
    final controller = TextEditingController();

    final message = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Contester cet avertissement'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          maxLength: 2000,
          decoration: const InputDecoration(
            hintText: 'Explique pourquoi tu contestes cette décision...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext, controller.text);
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (message == null) return;

    try {
      await _sendAppeal(alertId, message);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recours envoyé avec succès.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertes et avertissements'),
        actions: [
          IconButton(
            onPressed: _loadAlerts,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _alerts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Impossible de charger les alertes.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final alerts = snapshot.data ?? [];

          if (alerts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_user, size: 55),
                  SizedBox(height: 12),
                  Text(
                    'Aucune alerte pour le moment.',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              final level = alert['level'] ?? 1;
              final status = alert['status'] ?? 'active';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              alert['title'] ?? 'Avertissement FOF',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(alert['message'] ?? ''),
                      const SizedBox(height: 8),
                      Text('Règle concernée : ${alert['rule_number']}'),
                      Text('Niveau : $level / 5'),
                      Text('État : $status'),
                      if (alert['issued_at'] != null)
                        Text('Date : ${alert['issued_at']}'),
                      const SizedBox(height: 10),
                      if (status == 'active')
                        Align(
                          alignment: Alignment.centerRight,
                          child: OutlinedButton.icon(
                            onPressed: () => _openAppeal(
                              alert['id'].toString(),
                            ),
                            icon: const Icon(Icons.gavel),
                            label: const Text('Contester'),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
