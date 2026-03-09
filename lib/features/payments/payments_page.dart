import 'package:flutter/material.dart';

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagamentos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _paymentCard(
              title: 'Boleto de Março',
              subtitle: 'Vencimento: 10/03/2026',
              status: 'Em aberto',
            ),
            const SizedBox(height: 12),
            _paymentCard(
              title: 'Boleto de Fevereiro',
              subtitle: 'Pago em 08/02/2026',
              status: 'Pago',
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentCard({
    required String title,
    required String subtitle,
    required String status,
  }) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.receipt_long),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(
          status,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: status == 'Pago' ? Colors.green : Colors.orange,
          ),
        ),
      ),
    );
  }
}