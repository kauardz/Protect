import 'package:flutter/material.dart';
import 'package:protect/services/session_service.dart';
import 'package:protect/services/supabase_service.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final TextEditingController _messageController = TextEditingController();

  String _selectedType = 'Problema';
  bool _loading = false;

  final List<String> _types = [
    'Problema',
    'Dúvida',
    'Elogio',
    'Sugestão',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendTicket() async {
    final profileId = SessionService.currentProfileId;
    final message = _messageController.text.trim();

    if (profileId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cliente não identificado.'),
        ),
      );
      return;
    }

    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite uma mensagem para continuar.'),
        ),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      await SupabaseService.client.from('support_tickets').insert({
        'profile_id': profileId,
        'tipo': _selectedType,
        'mensagem': message,
        'status': 'aberto',
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chamado enviado com sucesso.'),
        ),
      );

      setState(() {
        _selectedType = 'Problema';
        _messageController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao enviar chamado: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentNome = SessionService.currentNome ?? 'Cliente';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suporte'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fale com a Protect, $currentNome',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Envie um problema, dúvida, elogio ou sugestão para nosso atendimento.',
              style: TextStyle(
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Tipo de atendimento',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _types.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: _loading
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          _selectedType = value;
                        });
                      }
                    },
            ),

            const SizedBox(height: 20),

            const Text(
              'Mensagem',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _messageController,
              maxLines: 6,
              enabled: !_loading,
              decoration: InputDecoration(
                hintText: 'Descreva seu atendimento aqui...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _sendTicket,
                icon: _loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  _loading ? 'Enviando...' : 'Enviar chamado',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Card(
              child: ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Atendimento Protect'),
                subtitle: const Text(
                  'Seu chamado será salvo no sistema e poderá ser acompanhado pela equipe.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}