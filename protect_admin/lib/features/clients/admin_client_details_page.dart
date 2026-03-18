import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminClientDetailsPage extends StatefulWidget {
  final String profileId;

  const AdminClientDetailsPage({
    super.key,
    required this.profileId,
  });

  @override
  State<AdminClientDetailsPage> createState() => _AdminClientDetailsPageState();
}

class _AdminClientDetailsPageState extends State<AdminClientDetailsPage> {
  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _plan;
  Map<String, dynamic>? _benefits;
  List<Map<String, dynamic>> _payments = [];
  List<Map<String, dynamic>> _tickets = [];

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('id, nome, cpf, telefone')
          .eq('id', widget.profileId)
          .maybeSingle();

      final plan = await Supabase.instance.client
          .from('plans')
          .select('id, nome_plano, valor, status, vencimento')
          .eq('profile_id', widget.profileId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      final benefits = await Supabase.instance.client
          .from('benefits')
          .select('id, peliculas_restantes, trocas_restantes, observacao')
          .eq('profile_id', widget.profileId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      final paymentsRaw = await Supabase.instance.client
          .from('payments')
          .select('id, valor, metodo, status, vencimento')
          .eq('profile_id', widget.profileId)
          .order('vencimento', ascending: false);

      final ticketsRaw = await Supabase.instance.client
          .from('support_tickets')
          .select('id, tipo, mensagem, status, created_at')
          .eq('profile_id', widget.profileId)
          .order('created_at', ascending: false);

      final payments = (paymentsRaw as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      final tickets = (ticketsRaw as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      if (!mounted) return;

      setState(() {
        _profile = profile == null ? null : Map<String, dynamic>.from(profile);
        _plan = plan == null ? null : Map<String, dynamic>.from(plan);
        _benefits =
            benefits == null ? null : Map<String, dynamic>.from(benefits);
        _payments = payments;
        _tickets = tickets;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Erro ao carregar dados do cliente: $e';
        _loading = false;
      });
    }
  }

  String _safeText(dynamic value, {String fallback = 'Não informado'}) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  String _formatMoney(dynamic value) {
    if (value == null) return 'R\$ 0,00';
    return 'R\$ ${value.toString()}';
  }

  Widget _sectionCard({
    required String title,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalhes do Cliente')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalhes do Cliente')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(_error!, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Cliente'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 1100;

          final leftColumn = Column(
            children: [
              _sectionCard(
                title: 'Cliente',
                child: Column(
                  children: [
                    _infoRow('Nome', _safeText(_profile?['nome'])),
                    _infoRow('CPF', _safeText(_profile?['cpf'])),
                    _infoRow('Telefone', _safeText(_profile?['telefone'])),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _sectionCard(
                title: 'Plano',
                child: Column(
                  children: [
                    _infoRow('Plano', _safeText(_plan?['nome_plano'])),
                    _infoRow('Status', _safeText(_plan?['status'])),
                    _infoRow('Valor', _formatMoney(_plan?['valor'])),
                    _infoRow('Vencimento', _safeText(_plan?['vencimento'])),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _sectionCard(
                title: 'Benefícios',
                child: Column(
                  children: [
                    _infoRow(
                      'Películas',
                      _safeText(_benefits?['peliculas_restantes']),
                    ),
                    _infoRow(
                      'Trocas',
                      _safeText(_benefits?['trocas_restantes']),
                    ),
                    _infoRow('Obs.', _safeText(_benefits?['observacao'])),
                  ],
                ),
              ),
            ],
          );

          final rightColumn = Column(
            children: [
              _sectionCard(
                title: 'Pagamentos',
                child: _payments.isEmpty
                    ? const Text('Nenhum pagamento encontrado.')
                    : Column(
                        children: _payments.map((payment) {
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(_formatMoney(payment['valor'])),
                            subtitle: Text(
                              'Vencimento: ${_safeText(payment['vencimento'])}',
                            ),
                            trailing: Text(_safeText(payment['status'])),
                          );
                        }).toList(),
                      ),
              ),
              const SizedBox(height: 16),
              _sectionCard(
                title: 'Chamados',
                child: _tickets.isEmpty
                    ? const Text('Nenhum chamado encontrado.')
                    : Column(
                        children: _tickets.map((ticket) {
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(_safeText(ticket['tipo'])),
                            subtitle: Text(_safeText(ticket['mensagem'])),
                            trailing: Text(_safeText(ticket['status'])),
                          );
                        }).toList(),
                      ),
              ),
            ],
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: leftColumn),
                      const SizedBox(width: 16),
                      Expanded(child: rightColumn),
                    ],
                  )
                : Column(
                    children: [
                      leftColumn,
                      const SizedBox(height: 16),
                      rightColumn,
                    ],
                  ),
          );
        },
      ),
    );
  }
}