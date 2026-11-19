
import 'package:flutter/material.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  static const rules = [
    ['Respect', 'Respecter chaque utilisateur.'],
    ['Harcèlement', 'Ne pas insulter, intimider ou harceler.'],
    ['Menaces', 'Ne pas menacer les autres.'],
    ['Discrimination', 'Ne pas tenir de propos discriminatoires.'],
    ['Humiliation', 'Ne pas publier de contenus humiliants.'],
    ['Vie privée', 'Protéger les informations personnelles.'],
    ['Violence', 'Ne pas publier de contenus violents choquants.'],
    ['Contenus sexuels', 'Les contenus sexuels explicites sont interdits.'],
    ['Désinformation', 'Ne pas diffuser volontairement de fausses informations.'],
    ['Consentement', 'Ne pas publier les médias privés d’autrui sans autorisation.'],
    ['Copyright', 'Respecter les droits d’auteur et les licences musicales.'],
    ['Arnaques', 'Ne pas tromper les utilisateurs pour obtenir de l’argent.'],
    ['Publicité', 'Ne pas diffuser de publicités frauduleuses.'],
    ['Liens dangereux', 'Ne pas partager de liens malveillants.'],
    ['Faux comptes', 'Ne pas créer de faux comptes pour tromper ou harceler.'],
    ['Identité', 'Ne pas usurper l’identité d’une personne.'],
    ['Bots', 'Ne pas manipuler les abonnés et statistiques.'],
    ['Spam', 'Ne pas envoyer de messages répétitifs non désirés.'],
    ['Sécurité', 'Ne pas pirater ou perturber FOF.'],
    ['Modération', 'Respecter les décisions et utiliser le recours disponible.'],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Règles de FOF')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Les 20 règles sont obligatoires pour tous les utilisateurs de FOF.',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...List.generate(rules.length, (index) {
            return Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(rules[index][0]),
                subtitle: Text(rules[index][1]),
              ),
            );
          }),
          const SizedBox(height: 16),
          const Text(
            'En cas de violation confirmée, une alerte sera envoyée. '
            'Chaque utilisateur pourra connaître le motif de la sanction '
            'et demander un réexamen.',
          ),
        ],
      ),
    );
  }
}
