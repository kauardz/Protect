import 'package:flutter/material.dart';
import 'package:protect/core/routes/app_routes.dart';
import 'package:protect/main.dart';
import 'package:protect/services/session_service.dart';
import 'package:protect/services/supabase_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const Color protectYellow = ProtectApp.protectYellow;
  static const Color protectBlack = ProtectApp.protectBlack;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? _plan;
  Map<String, dynamic>? _payment;
  Map<String, dynamic>? _benefits;

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _logout() async {
    await SupabaseService.signOut();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  Future<void> _loadHomeData() async {
    final profileId = SessionService.currentProfileId;

    if (profileId == null) {
      setState(() {
        _error = 'Nenhum cliente logado.';
        _loading = false;
      });
      return;
    }

    try {
      final data = await SupabaseService.getHomeData(profileId);

      if (!mounted) return;

      setState(() {
        _plan = data['plan'] as Map<String, dynamic>?;
        _payment = data['payment'] as Map<String, dynamic>?;
        _benefits = data['benefits'] as Map<String, dynamic>?;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Erro ao carregar dados da home: $e';
        _loading = false;
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    await _loadHomeData();
  }

  bool _isPlanActive(String status) {
    return status.toLowerCase() == 'ativo';
  }

  @override
  Widget build(BuildContext context) {
    final currentNome = SessionService.currentNome ?? 'Cliente';

    final nomePlano =
        SupabaseService.safeText(_plan?['nome_plano'], fallback: 'Sem plano');
    final statusPlano =
        SupabaseService.safeText(_plan?['status'], fallback: 'Inativo');
    final vencimentoPlano = SupabaseService.formatDate(_plan?['vencimento']);
    final valorPlano = SupabaseService.formatMoney(_plan?['valor']);

    final proximoPagamentoValor =
        SupabaseService.formatMoney(_payment?['valor']);
    final proximoPagamentoData =
        SupabaseService.formatShortDate(_payment?['vencimento']);

    final peliculas = SupabaseService.safeInt(_benefits?['peliculas_restantes']);
    final trocas = SupabaseService.safeInt(_benefits?['trocas_restantes']);

    final beneficiosResumo = '$peliculas + $trocas';
    final planoAtivo = _isPlanActive(statusPlano);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text('Protect'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Sair',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _headerCard(currentNome),
              const SizedBox(height: 16),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                _errorCard(_error!)
              else ...[
                _planHighlightCard(
                  context,
                  nomePlano: nomePlano,
                  statusPlano: statusPlano,
                  vencimentoPlano: vencimentoPlano,
                  valorPlano: valorPlano,
                  planoAtivo: planoAtivo,
                ),
                const SizedBox(height: 16),
                _summaryRow(
                  context,
                  proximoPagamentoValor: proximoPagamentoValor,
                  proximoPagamentoData: proximoPagamentoData,
                  beneficiosResumo: beneficiosResumo,
                ),
              ],
              const SizedBox(height: 20),
              const Text(
                'Acesso rápido',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _quickActionsRow(context),
              const SizedBox(height: 20),
              const Text(
                'Serviços',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _menuCard(
                context: context,
                icon: Icons.phone_android,
                title: 'Meu Plano',
                subtitle: 'Status, vencimento e detalhes do plano',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.plan);
                },
              ),
              const SizedBox(height: 12),
              _menuCard(
                context: context,
                icon: Icons.payments_outlined,
                title: 'Pagamentos',
                subtitle: 'Pix, boleto, cartão e histórico',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.payments);
                },
              ),
              const SizedBox(height: 12),
              _menuCard(
                context: context,
                icon: Icons.verified_user_outlined,
                title: 'Benefícios',
                subtitle: 'Películas grátis e trocas disponíveis',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.benefits);
                },
              ),
              const SizedBox(height: 12),
              _menuCard(
                context: context,
                icon: Icons.campaign_outlined,
                title: 'Promoções e Campanhas',
                subtitle: 'Confira ofertas e campanhas ativas',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.campaigns);
                },
              ),
              const SizedBox(height: 12),
              _menuCard(
                context: context,
                icon: Icons.support_agent_outlined,
                title: 'Suporte',
                subtitle: 'Problemas, dúvidas, elogios e chamados',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.support);
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: HomePage.protectYellow,
        foregroundColor: Colors.black,
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.support);
        },
        icon: const Icon(Icons.chat_bubble_outline),
        label: const Text('Ajuda'),
      ),
    );
  }

  Widget _errorCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 40),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _headerCard(String currentNome) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: HomePage.protectYellow.withOpacity(0.22),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bem-vindo',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentNome,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Gerencie seu plano, pagamentos e benefícios.',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _planHighlightCard(
    BuildContext context, {
    required String nomePlano,
    required String statusPlano,
    required String vencimentoPlano,
    required String valorPlano,
    required bool planoAtivo,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HomePage.protectBlack,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium, color: HomePage.protectYellow),
              const SizedBox(width: 8),
              const Text(
                'Plano atual',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: planoAtivo
                      ? Colors.green.withOpacity(0.18)
                      : Colors.orange.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusPlano,
                  style: TextStyle(
                    color:
                        planoAtivo ? Colors.greenAccent : Colors.orangeAccent,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            nomePlano,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Acompanhe seu plano, benefícios e pagamentos de forma rápida.',
            style: TextStyle(
              color: Colors.white70,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _darkMetric(
                  label: 'Vencimento',
                  value: vencimentoPlano,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _darkMetric(
                  label: 'Valor mensal',
                  value: valorPlano,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: HomePage.protectYellow,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.plan);
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text(
                'Ver detalhes do plano',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _darkMetric({
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    BuildContext context, {
    required String proximoPagamentoValor,
    required String proximoPagamentoData,
    required String beneficiosResumo,
  }) {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            icon: Icons.payments_outlined,
            title: 'Próximo pagamento',
            value: proximoPagamentoValor,
            subtitle: 'Vence em $proximoPagamentoData',
            color: Colors.orange,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.payments);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _summaryCard(
            icon: Icons.shield_outlined,
            title: 'Benefícios',
            value: beneficiosResumo,
            subtitle: 'Películas e trocas',
            color: Colors.blue,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.benefits);
            },
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.14),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickActionsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _quickActionButton(
            icon: Icons.qr_code,
            label: 'QR benefício',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.benefits);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _quickActionButton(
            icon: Icons.copy,
            label: 'Copiar Pix',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.payments);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _quickActionButton(
            icon: Icons.history,
            label: 'Chamados',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.myTickets);
            },
          ),
        ),
      ],
    );
  }

  Widget _quickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.black87),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _menuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 6,
          ),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: HomePage.protectYellow.withOpacity(0.22),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.black),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(
              color: Colors.black54,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
          ),
        ),
      ),
    );
  }
}