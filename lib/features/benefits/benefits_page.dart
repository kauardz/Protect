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
      final data = await SupabaseService.client
          .from('benefits')
          .select()
          .eq('profile_id', profileId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      setState(() {
        _benefit = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar benefícios: $e';
        _loading = false;
      });
    }
  }

  String _safeText(dynamic value, {String fallback = 'Não informado'}) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  int _safeInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
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
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(subtitle),
        trailing: badge != null
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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

    if (_benefit == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.info_outline,
                size: 48,
                color: Colors.black54,
              ),
              const SizedBox(height: 12),
              const Text(
                'Nenhum benefício encontrado para este cliente.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadBenefits,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    final peliculasRestantes = _safeInt(_benefit!['peliculas_restantes']);
    final trocasRestantes = _safeInt(_benefit!['trocas_restantes']);
    final observacao = _safeText(
      _benefit!['observacao'],
      fallback: 'Seus benefícios estão vinculados ao seu plano atual.',
    );

    return SingleChildScrollView(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Benefícios'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _loading = true;
                _error = null;
              });
              _loadBenefits();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
}