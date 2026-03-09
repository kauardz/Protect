import 'package:flutter/material.dart';

class BenefitsPage extends StatelessWidget {
  const BenefitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Benefícios'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            _benefitCard(
              icon: Icons.shield,
              title: "Películas gratuitas",
              subtitle: "Você ainda possui 2 películas disponíveis este ano",
              color: Colors.blue,
            ),

            const SizedBox(height: 12),

            _benefitCard(
              icon: Icons.refresh,
              title: "Troca de película",
              subtitle: "Você possui 1 troca disponível",
              color: Colors.green,
            ),

            const SizedBox(height: 12),

            _benefitCard(
              icon: Icons.workspace_premium,
              title: "Plano Protect",
              subtitle: "Seu plano está ativo",
              color: Colors.orange,
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.qr_code),
                label: const Text("Gerar QR Code para uso na loja"),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("QR Code será implementado em breve"),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _benefitCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}