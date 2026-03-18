import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../widgets/admin_shell.dart';
import '../../../widgets/premium_stat_card.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  bool _loading = true;
  String? _error;

  int _totalClients = 0;
  int _openTickets = 0;
  int _activeCampaigns = 0;
  int _pendingPayments = 0;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    try {
      final clients = await Supabase.instance.client
          .from('profiles')
          .select('id');

      final tickets = await Supabase.instance.client
          .from('support_tickets')
          .select('id')
          .eq('status', 'aberto');

      final campaigns = await Supabase.instance.client
          .from('campaigns')
          .select('id')
          .eq('ativa', true);

      final payments = await Supabase.instance.client
          .from('payments')
          .select('id')
          .eq('status', 'Pendente');

      if (!mounted) return;

      setState(() {
        _totalClients = (clients as List).length;
        _openTickets = (tickets as List).length;
        _activeCampaigns = (campaigns as List).length;
        _pendingPayments = (payments as List).length;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Erro ao carregar dashboard: $e';
        _loading = false;
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    await _loadMetrics();
  }

  Widget _grid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 4;
        if (constraints.maxWidth < 1300) crossAxisCount = 2;
        if (constraints.maxWidth < 700) crossAxisCount = 1;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.6,
          children: [
            PremiumStatCard(
              title: 'Clientes',
              value: _totalClients.toString(),
              icon: Icons.people_outline,
              footer: 'Total cadastrado no sistema',
            ),
            PremiumStatCard(
              title: 'Chamados abertos',
              value: _openTickets.toString(),
              icon: Icons.support_agent_outlined,
              footer: 'Demandas que precisam de atenção',
            ),
            PremiumStatCard(
              title: 'Campanhas ativas',
              value: _activeCampaigns.toString(),
              icon: Icons.campaign_outlined,
              footer: 'Campanhas visíveis aos clientes',
            ),
            PremiumStatCard(
              title: 'Pagamentos pendentes',
              value: _pendingPayments.toString(),
              icon: Icons.payments_outlined,
              footer: 'Cobranças ainda não quitadas',
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      selectedIndex: 0,
      title: 'Dashboard',
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(_error!, textAlign: TextAlign.center),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      _grid(),
                      const SizedBox(height: 24),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Visão geral',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Esse painel foi desenhado para acompanhar a operação da Protect com mais clareza. '
                                'Use o menu lateral para navegar entre clientes, chamados e campanhas. '
                                'A partir daqui você consegue concentrar todo o acompanhamento administrativo em um só lugar.',
                                style: TextStyle(
                                  color: Colors.black87,
                                  height: 1.5,
                                ),
                              ),
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