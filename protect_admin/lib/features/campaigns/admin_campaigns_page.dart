import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../widgets/admin_shell.dart';

class AdminCampaignsPage extends StatefulWidget {
  const AdminCampaignsPage({super.key});

  @override
  State<AdminCampaignsPage> createState() => _AdminCampaignsPageState();
}

class _AdminCampaignsPageState extends State<AdminCampaignsPage> {
  List<dynamic> _campaigns = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCampaigns();
  }

  Future<void> _loadCampaigns() async {
    try {
      final data = await Supabase.instance.client
          .from('campaigns')
          .select()
          .order('created_at', ascending: false);

      if (!mounted) return;

      setState(() {
        _campaigns = data;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Erro ao carregar campanhas: $e';
        _loading = false;
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    await _loadCampaigns();
  }

  String _safeText(dynamic value, {String fallback = 'Não informado'}) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  Future<void> _createCampaign() async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final statusController = TextEditingController(text: 'Ativa');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nova campanha'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Descrição'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: statusController,
                  decoration: const InputDecoration(labelText: 'Status'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (result != true) return;

    try {
      await Supabase.instance.client.from('campaigns').insert({
        'titulo': titleController.text.trim(),
        'descricao': descController.text.trim(),
        'status': statusController.text.trim(),
        'ativa': true,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Campanha criada com sucesso.')),
      );
      await _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar campanha: $e')),
      );
    }
  }

  Future<void> _toggleCampaign(Map<String, dynamic> campaign) async {
    try {
      await Supabase.instance.client
          .from('campaigns')
          .update({'ativa': !(campaign['ativa'] as bool)})
          .eq('id', campaign['id']);

      if (!mounted) return;
      await _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar campanha: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      selectedIndex: 3,
      title: 'Campanhas',
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(_error!, textAlign: TextAlign.center),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton.icon(
                        onPressed: _createCampaign,
                        icon: const Icon(Icons.add),
                        label: const Text('Nova campanha'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ..._campaigns.map((campaign) {
                      final c = campaign as Map<String, dynamic>;
                      final active = c['ativa'] == true;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: active
                                ? Colors.green.withOpacity(0.12)
                                : Colors.red.withOpacity(0.12),
                            child: Icon(
                              Icons.campaign_outlined,
                              color: active ? Colors.green : Colors.red,
                            ),
                          ),
                          title: Text(
                            _safeText(c['titulo']),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(_safeText(c['descricao'])),
                          ),
                          trailing: Switch(
                            value: active,
                            onChanged: (_) => _toggleCampaign(c),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
    );
  }
}