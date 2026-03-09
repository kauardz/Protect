import 'package:flutter/material.dart';
import 'package:protect/services/session_service.dart';
import 'package:protect/services/supabase_service.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  Map<String, dynamic>? _plan;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  Future<void> _loadPlan() async {
    final profileId = SessionService.currentProfileId;

    if (profileId == null) {
      setState(() {
        _error = 'Nenhum cliente logado.';
        _loading = false;
      });
      return;
    }

    try {
      final data = await SupabaseService.client
          .from('plans')
          .select()
          .eq('profile_id', profileId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      setState(() {
        _plan = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar plano: $e';
        _loading = false;
      });
    }
  }

  String _formatMoney(dynamic value) {
    if (value == null) return 'Não informado';

    return 'R\$ ${value.toString()}';
  }

  String _formatText(dynamic value, {String fallback = 'Não informado'}) {
    if (value == null || value.toString().trim().isEmpty) {
      return fallback;
    }
    return value.toString();
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

    if (_plan == null) {
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
                'Nenhum plano encontrado para este cliente.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadPlan,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    final nomePlano = _formatText(_plan!['nome_plano']);
    final status = _formatText(_plan!['status']);
    final valor = _formatMoney(_plan!['valor']);
    final vencimento = _formatText(_plan!['vencimento']);

    final bool ativo = status.toLowerCase() == 'ativo';

    return SingleChildScrollView(
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
                      Expanded(
                        child: Text(
                          nomePlano,
                          style: const TextStyle(
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
                          color: ativo
                              ? Colors.green.withOpacity(0.12)
                              : Colors.orange.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: ativo ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const _InfoRow(
                    label: 'Cliente',
                    valueFromSession: true,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: 'Plano',
                    value: nomePlano,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: 'Valor mensal',
                    value: valor,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: 'Status',
                    value: status,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: 'Vencimento',
                    value: vencimento,
                  ),
                  const SizedBox(height: 12),
                  const _InfoRow(
                    label: 'Forma de pagamento',
                    value: 'Boleto, Pix e Cartão',
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
                  subtitle: Text('Consulte na área de benefícios'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.autorenew),
                  title: Text('Troca de película'),
                  subtitle: Text('Disponível conforme regras do plano'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.support_agent_outlined),
                  title: Text('Suporte'),
                  subtitle: Text('Acompanhamento pelo aplicativo'),
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
                    content: Text('Função de renovação será implementada em breve.'),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Plano'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _loading = true;
                _error = null;
              });
              _loadPlan();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  final bool valueFromSession;

  const _InfoRow({
    required this.label,
    this.value,
    this.valueFromSession = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = valueFromSession
        ? (SessionService.currentNome ?? 'Não informado')
        : (value ?? 'Não informado');

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
            displayValue,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}