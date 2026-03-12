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
  List<dynamic> _payments = [];
  List<dynamic> _tickets = [];

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
          .select()
          .eq('id', widget.profileId)
          .maybeSingle();

      final plan = await Supabase.instance.client
          .from('plans')
          .select()
          .eq('profile_id', widget.profileId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      final benefits = await Supabase.instance.client
          .from('benefits')
          .select()
          .eq('profile_id', widget.profileId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      final payments = await Supabase.instance.client
          .from('payments')
          .select()
          .eq('profile_id', widget.profileId)
          .order('vencimento', ascending: false);

      final tickets = await Supabase.instance.client
          .from('support_tickets')
          .select()
          .eq('profile_id', widget.profileId)
          .order('created_at', ascending: false);

      if (!mounted) return;

      setState(() {
        _profile = profile;
        _plan = plan;
        _benefits = benefits;
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

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
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
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Cliente'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(_error!, textAlign: TextAlign.center),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _sectionTitle('Cliente'),
                              _infoRow('Nome', _safeText(_profile?['nome'])),
                              _infoRow('CPF', _safeText(_profile?['cpf'])),
                              _infoRow(
                                'Telefone',
                                _safeText(_profile?['telefone']),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _sectionTitle('Plano'),
                              _infoRow(
                                'Plano',
                                _safeText(_plan?['nome_plano']),
                              ),
                              _infoRow(
                                'Status',
                                _safeText(_plan?['status']),
                              ),
                              _infoRow(
                                'Valor',
                                _formatMoney(_plan?['valor']),
                              ),
                              _infoRow(
                                'Vencimento',
                                _safeText(_plan?['vencimento']),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _sectionTitle('Benefícios'),
                              _infoRow(
                                'Películas',
                                _safeText(_benefits?['peliculas_restantes']),
                              ),
                              _infoRow(
                                'Trocas',
                                _safeText(_benefits?['trocas_restantes']),
                              ),
                              _infoRow(
                                'Obs.',
                                _safeText(_benefits?['observacao']),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _sectionTitle('Pagamentos'),
                              if (_payments.isEmpty)
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text('Nenhum pagamento encontrado.'),
                                )
                              else
                                ..._payments.map((payment) {
                                  final p = payment as Map<String, dynamic>;
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(_formatMoney(p['valor'])),
                                    subtitle: Text(
                                      'Vencimento: ${_safeText(p['vencimento'])}',
                                    ),
                                    trailing: Text(_safeText(p['status'])),
                                  );
                                }),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _sectionTitle('Chamados'),
                              if (_tickets.isEmpty)
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text('Nenhum chamado encontrado.'),
                                )
                              else
                                ..._tickets.map((ticket) {
                                  final t = ticket as Map<String, dynamic>;
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(_safeText(t['tipo'])),
                                    subtitle: Text(_safeText(t['mensagem'])),
                                    trailing: Text(_safeText(t['status'])),
                                  );
                                }),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}