import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:protect/services/session_service.dart';
import 'package:protect/services/supabase_service.dart';
import 'package:protect/widgets/pix_qr_widget.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  List<dynamic> _payments = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    final profileId = SessionService.currentProfileId;

    if (profileId == null) {
      setState(() {
        _error = 'Cliente não identificado.';
        _loading = false;
      });
      return;
    }

    try {
      final data = await SupabaseService.client
          .from('payments')
          .select()
          .eq('profile_id', profileId)
          .order('vencimento', ascending: true);

      setState(() {
        _payments = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar pagamentos: $e';
        _loading = false;
      });
    }
  }

  String _formatMoney(dynamic value) {
    if (value == null) return 'R\$ 0,00';
    return 'R\$ ${value.toString()}';
  }

  Color _statusColor(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'pago':
        return Colors.green;
      case 'vencido':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Future<void> _copyText(String text, String message) async {
    await Clipboard.setData(ClipboardData(text: text));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showPaymentDetails(Map<String, dynamic> payment) {
    final pixCode = payment['pix_code']?.toString();
    final boletoCode = payment['boleto_code']?.toString();
    final paymentLink = payment['payment_link']?.toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              runSpacing: 12,
              children: [
                const Text(
                  'Detalhes do pagamento',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.attach_money),
                  title: const Text('Valor'),
                  subtitle: Text(_formatMoney(payment['valor'])),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_month),
                  title: const Text('Vencimento'),
                  subtitle: Text(
                    payment['vencimento']?.toString() ?? 'Não informado',
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Status'),
                  subtitle: Text(payment['status']?.toString() ?? 'Pendente'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.payments_outlined),
                  title: const Text('Método'),
                  subtitle: Text(payment['metodo']?.toString() ?? 'Não informado'),
                ),

                if (pixCode != null && pixCode.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  PixQrWidget(pixCode: pixCode),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _copyText(
                          pixCode,
                          'Código Pix copiado com sucesso.',
                        );
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('Copiar Pix'),
                    ),
                  ),
                ] else
                  const Text(
                    'Este pagamento não possui código Pix disponível.',
                    style: TextStyle(color: Colors.black54),
                  ),

                if (boletoCode != null && boletoCode.trim().isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _copyText(
                          boletoCode,
                          'Linha digitável copiada com sucesso.',
                        );
                      },
                      icon: const Icon(Icons.receipt_long),
                      label: const Text('Copiar boleto'),
                    ),
                  ),

                if (paymentLink != null && paymentLink.trim().isNotEmpty)
                  SelectableText(
                    'Link de pagamento: $paymentLink',
                    style: const TextStyle(fontSize: 14),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    if (_payments.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Nenhum pagamento encontrado.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _payments.length,
      itemBuilder: (context, index) {
        final payment = _payments[index] as Map<String, dynamic>;
        final status = payment['status']?.toString() ?? 'Pendente';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.payments),
            ),
            title: Text(
              _formatMoney(payment['valor']),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Vencimento: ${payment['vencimento']?.toString() ?? 'Não informado'}\n'
              'Método: ${payment['metodo']?.toString() ?? 'Não informado'}',
            ),
            trailing: Text(
              status,
              style: TextStyle(
                color: _statusColor(status),
                fontWeight: FontWeight.w700,
              ),
            ),
            onTap: () => _showPaymentDetails(payment),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagamentos'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _loading = true;
                _error = null;
              });
              _loadPayments();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
}