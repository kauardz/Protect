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
      final data = await SupabaseService.getPayments(profileId);

      if (!mounted) return;

      setState(() {
        _payments = data;
        _error = null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Erro ao carregar pagamentos: $e';
        _loading = false;
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    await _loadPayments();
  }

  Color _statusColor(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'pago':
        return Colors.green;
      case 'vencido':
        return Colors.red;
      case 'pendente':
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }

  IconData _statusIcon(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'pago':
        return Icons.check_circle_outline;
      case 'vencido':
        return Icons.error_outline;
      case 'pendente':
        return Icons.schedule;
      default:
        return Icons.info_outline;
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
    final status = SupabaseService.safeText(
      payment['status'],
      fallback: 'Pendente',
    );

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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.attach_money),
                  title: const Text('Valor'),
                  subtitle: Text(SupabaseService.formatMoney(payment['valor'])),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_month),
                  title: const Text('Vencimento'),
                  subtitle: Text(SupabaseService.formatDate(payment['vencimento'])),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    _statusIcon(status),
                    color: _statusColor(status),
                  ),
                  title: const Text('Status'),
                  subtitle: Text(status),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.payments_outlined),
                  title: const Text('Método'),
                  subtitle: Text(
                    SupabaseService.safeText(payment['metodo']),
                  ),
                ),
                if (pixCode != null && pixCode.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  PixQrWidget(pixCode: pixCode),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _copyText(pixCode, 'Código Pix copiado com sucesso.');
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
                if (paymentLink != null && paymentLink.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Link de pagamento',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    paymentLink,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _refresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_payments.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: const [
            SizedBox(height: 120),
            Icon(Icons.payments_outlined, size: 48, color: Colors.black54),
            SizedBox(height: 12),
            Text(
              'Nenhum pagamento encontrado.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _payments.length,
        itemBuilder: (context, index) {
          final payment = _payments[index] as Map<String, dynamic>;
          final status = SupabaseService.safeText(
            payment['status'],
            fallback: 'Pendente',
          );

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: CircleAvatar(
                backgroundColor: _statusColor(status).withOpacity(0.12),
                child: Icon(
                  _statusIcon(status),
                  color: _statusColor(status),
                ),
              ),
              title: Text(
                SupabaseService.formatMoney(payment['valor']),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Vencimento: ${SupabaseService.formatDate(payment['vencimento'])}\n'
                'Método: ${SupabaseService.safeText(payment['metodo'])}',
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagamentos'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
}