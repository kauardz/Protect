import 'package:flutter/material.dart';

class PlanPage extends StatelessWidget {
  const PlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Plano'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified_user_outlined, size: 30),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Plano Protect Premium',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Ativo',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const _InfoRow(
                      label: 'Cobertura',
                      value: 'Película, trocas e suporte especializado',
                    ),
                    const SizedBox(height: 12),
                    const _InfoRow(
                      label: 'Valor mensal',
                      value: 'R\$ 29,90',
                    ),
                    const SizedBox(height: 12),
                    const _InfoRow(
                      label: 'Próximo vencimento',
                      value: '10/03/2026',
                    ),
                    const SizedBox(height: 12),
                    const _InfoRow(
                      label: 'Forma de pagamento',
                      value: 'Boleto, Pix e Cartão',
                    ),
                    const SizedBox(height: 12),
                    const _InfoRow(
                      label: 'Loja vinculada',
                      value: 'Protect Belém',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Card(
              child: Column(
                children: const [
                  ListTile(
                    leading: Icon(Icons.shield_outlined),
                    title: Text('Películas grátis'),
                    subtitle: Text('2 disponíveis por ano'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.autorenew),
                    title: Text('Troca de película'),
                    subtitle: Text('1 troca disponível no período'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.support_agent_outlined),
                    title: Text('Suporte'),
                    subtitle: Text('Atendimento e acompanhamento pelo app'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Renovação será implementada em breve.'),
                    ),
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text(
                  'Renovar / Regularizar plano',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 135,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}