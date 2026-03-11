import 'package:flutter/material.dart';
import 'package:protect/services/session_service.dart';
import 'package:protect/services/supabase_service.dart';

class BenefitsPage extends StatefulWidget {
  const BenefitsPage({super.key});

  @override
  State<BenefitsPage> createState() => _BenefitsPageState();
}

class _BenefitsPageState extends State<BenefitsPage> {
  Map<String, dynamic>? _benefit;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBenefits();
  }

  Future<void> _loadBenefits() async {
    final profileId = SessionService.currentProfileId;

    if (profileId == null) {
      setState(() {
        _error = 'Cliente não identificado.';
        _loading = false;
      });
      return;
    }

    try {
      final data = await SupabaseService.getBenefits(profileId);

      if (!mounted) return;

      setState(() {
        _benefit = data;
        _error = null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Erro ao carregar benefícios: $e';
        _loading = false;
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    await _loadBenefits();
  }

  Widget _benefitCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    String? badge,
  }) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle),
        ),
        trailing: badge != null
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildError() {
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

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline, size: 48, color: Colors.black54),
            const SizedBox(height: 12),
            const Text(
              'Nenhum benefício encontrado para este cliente.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
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

  Widget _buildContent() {
    final peliculasRestantes =
        SupabaseService.safeInt(_benefit!['peliculas_restantes']);
    final trocasRestantes =
        SupabaseService.safeInt(_benefit!['trocas_restantes']);
    final observacao = SupabaseService.safeText(
      _benefit!['observacao'],
      fallback: 'Seus benefícios estão vinculados ao seu plano atual.',
    );

    return RefreshIndicator(
      onRefresh: _refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _benefitCard(
              icon: Icons.shield_outlined,
              title: 'Películas gratuitas',
              subtitle:
                  'Você possui $peliculasRestantes película(s) disponível(is).',
              color: Colors.blue,
              badge: '$peliculasRestantes',
            ),
            const SizedBox(height: 12),
            _benefitCard(
              icon: Icons.autorenew,
              title: 'Troca de película',
              subtitle:
                  'Você possui $trocasRestantes troca(s) disponível(is).',
              color: Colors.green,
              badge: '$trocasRestantes',
            ),
            const SizedBox(height: 12),
            _benefitCard(
              icon: Icons.workspace_premium_outlined,
              title: 'Status do benefício',
              subtitle: observacao,
              color: Colors.orange,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('QR Code será implementado em breve.'),
                    ),
                  );
                },
                icon: const Icon(Icons.qr_code),
                label: const Text(
                  'Gerar QR Code para uso na loja',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildError();
    }

    if (_benefit == null) {
      return _buildEmpty();
    }

    return _buildContent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Benefícios'),
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