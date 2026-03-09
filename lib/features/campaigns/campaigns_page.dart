import 'package:flutter/material.dart';

class CampaignsPage extends StatelessWidget {
  const CampaignsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Promoções e Campanhas'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _campaignCard(
              icon: Icons.local_offer_outlined,
              title: 'Promoção do Mês',
              subtitle:
                  'Ative benefícios exclusivos e aproveite condições especiais na loja.',
              status: 'Ativa',
              statusColor: Colors.green,
            ),
            const SizedBox(height: 12),
            _campaignCard(
              icon: Icons.emoji_events_outlined,
              title: 'Campanha Cliente Protect',
              subtitle:
                  'Você está participando da campanha com vantagens em serviços e acessórios.',
              status: 'Participando',
              statusColor: Colors.orange,
            ),
            const SizedBox(height: 12),
            _campaignCard(
              icon: Icons.card_giftcard_outlined,
              title: 'Indique e Ganhe',
              subtitle:
                  'Indique amigos para conhecer a Protect e receba benefícios.',
              status: 'Disponível',
              statusColor: Colors.blue,
            ),
            const SizedBox(height: 20),
            Card(
              child: Column(
                children: const [
                  ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('Como funciona'),
                    subtitle: Text(
                      'As campanhas podem variar conforme o plano, a loja e o período vigente.',
                    ),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.access_time_outlined),
                    title: Text('Validade'),
                    subtitle: Text(
                      'Acompanhe os prazos e regras antes de usar qualquer benefício promocional.',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campaignCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: statusColor.withOpacity(0.12),
              child: Icon(icon, color: statusColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.black54,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Ver detalhes'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}