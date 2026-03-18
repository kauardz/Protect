import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../widgets/admin_shell.dart';
import 'admin_client_details_page.dart';

class AdminClientsPage extends StatefulWidget {
  const AdminClientsPage({super.key});

  @override
  State<AdminClientsPage> createState() => _AdminClientsPageState();
}

class _AdminClientsPageState extends State<AdminClientsPage> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _clients = [];
  List<Map<String, dynamic>> _filteredClients = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadClients();
    _searchController.addListener(_filterClients);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadClients() async {
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('id, nome, cpf, telefone, created_at')
          .order('created_at', ascending: false);

      final parsed = (data as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();

      if (!mounted) return;

      setState(() {
        _clients = parsed;
        _filteredClients = parsed;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Erro ao carregar clientes: $e';
        _loading = false;
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    await _loadClients();
  }

  void _filterClients() {
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      _filteredClients = _clients.where((client) {
        final nome = _safeText(client['nome']).toLowerCase();
        final cpf = _safeText(client['cpf']).toLowerCase();
        return nome.contains(query) || cpf.contains(query);
      }).toList();
    });
  }

  String _safeText(dynamic value, {String fallback = 'Não informado'}) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  Widget _buildDesktopTable() {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 56,
          columns: const [
            DataColumn(label: Text('Nome')),
            DataColumn(label: Text('CPF')),
            DataColumn(label: Text('Telefone')),
            DataColumn(label: Text('Ação')),
          ],
          rows: _filteredClients.map((client) {
            final profileId = client['id']?.toString() ?? '';

            return DataRow(
              cells: [
                DataCell(Text(_safeText(client['nome']))),
                DataCell(Text(_safeText(client['cpf']))),
                DataCell(Text(_safeText(client['telefone']))),
                DataCell(
                  TextButton(
                    onPressed: profileId.isEmpty
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdminClientDetailsPage(
                                  profileId: profileId,
                                ),
                              ),
                            );
                          },
                    child: const Text('Abrir'),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMobileList() {
    return Column(
      children: _filteredClients.map((client) {
        final profileId = client['id']?.toString() ?? '';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text(
              _safeText(client['nome']),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              'CPF: ${_safeText(client['cpf'])}\nTelefone: ${_safeText(client['telefone'])}',
            ),
            isThreeLine: true,
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: profileId.isEmpty
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminClientDetailsPage(
                          profileId: profileId,
                        ),
                      ),
                    );
                  },
          ),
        );
      }).toList(),
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
          child: Text(
            _error!,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar por nome ou CPF',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_filteredClients.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Nenhum cliente encontrado.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else if (isDesktop)
                _buildDesktopTable()
              else
                _buildMobileList(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      selectedIndex: 1,
      title: 'Clientes',
      child: _buildBody(),
    );
  }
}