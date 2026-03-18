import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../widgets/admin_shell.dart';

class AdminTicketsPage extends StatefulWidget {
  const AdminTicketsPage({super.key});

  @override
  State<AdminTicketsPage> createState() => _AdminTicketsPageState();
}

class _AdminTicketsPageState extends State<AdminTicketsPage> {
  List<dynamic> _tickets = [];
  bool _loading = true;
  String? _error;
  String _statusFilter = 'Todos';

  final List<String> _filters = [
    'Todos',
    'aberto',
    'em andamento',
    'resolvido',
  ];

  final List<String> _statusOptions = [
    'aberto',
    'em andamento',
    'resolvido',
  ];

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    try {
      final data = await Supabase.instance.client
          .from('support_tickets')
          .select('*, profiles(nome, cpf)')
          .order('created_at', ascending: false);

      if (!mounted) return;

      setState(() {
        _tickets = data;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Erro ao carregar chamados: $e';
        _loading = false;
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    await _loadTickets();
  }

  Future<void> _updateTicketStatus({
    required String ticketId,
    required String newStatus,
  }) async {
    try {
      await Supabase.instance.client
          .from('support_tickets')
          .update({'status': newStatus})
          .eq('id', ticketId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status atualizado para "$newStatus".'),
        ),
      );

      await _refresh();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar status: $e'),
        ),
      );
    }
  }

  String _safeText(dynamic value, {String fallback = 'Não informado'}) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  List<dynamic> get _filteredTickets {
    if (_statusFilter == 'Todos') return _tickets;

    return _tickets.where((ticket) {
      final map = ticket as Map<String, dynamic>;
      return _safeText(map['status']).toLowerCase() ==
          _statusFilter.toLowerCase();
    }).toList();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'aberto':
        return Colors.blue;
      case 'em andamento':
        return Colors.orange;
      case 'resolvido':
        return Colors.green;
      default:
        return Colors.black54;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'aberto':
        return Icons.mark_email_unread_outlined;
      case 'em andamento':
        return Icons.schedule;
      case 'resolvido':
        return Icons.check_circle_outline;
      default:
        return Icons.info_outline;
    }
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _statusColor(status).withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _statusColor(status),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _statusDropdown({
    required String ticketId,
    required String currentStatus,
  }) {
    return DropdownButton<String>(
      value: _statusOptions.contains(currentStatus.toLowerCase())
          ? currentStatus.toLowerCase()
          : 'aberto',
      underline: const SizedBox(),
      items: _statusOptions.map((status) {
        return DropdownMenuItem<String>(
          value: status,
          child: Text(status),
        );
      }).toList(),
      onChanged: (value) {
        if (value == null || value == currentStatus.toLowerCase()) return;

        _updateTicketStatus(
          ticketId: ticketId,
          newStatus: value,
        );
      },
    );
  }

  Widget _buildDesktopTable() {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 56,
          dataRowMinHeight: 86,
          dataRowMaxHeight: 110,
          columns: const [
            DataColumn(label: Text('Cliente')),
            DataColumn(label: Text('CPF')),
            DataColumn(label: Text('Tipo')),
            DataColumn(label: Text('Mensagem')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Alterar')),
          ],
          rows: _filteredTickets.map((ticket) {
            final t = ticket as Map<String, dynamic>;
            final profile = t['profiles'] as Map<String, dynamic>?;
            final status = _safeText(t['status'], fallback: 'aberto');
            final ticketId = _safeText(t['id'], fallback: '');

            return DataRow(
              cells: [
                DataCell(Text(_safeText(profile?['nome']))),
                DataCell(Text(_safeText(profile?['cpf']))),
                DataCell(Text(_safeText(t['tipo']))),
                DataCell(
                  SizedBox(
                    width: 320,
                    child: Text(
                      _safeText(t['mensagem']),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(_statusBadge(status)),
                DataCell(
                  ticketId.isEmpty
                      ? const Text('-')
                      : _statusDropdown(
                          ticketId: ticketId,
                          currentStatus: status,
                        ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMobileCards() {
    return Column(
      children: _filteredTickets.map((ticket) {
        final t = ticket as Map<String, dynamic>;
        final profile = t['profiles'] as Map<String, dynamic>?;
        final status = _safeText(t['status'], fallback: 'aberto');
        final ticketId = _safeText(t['id'], fallback: '');

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: _statusColor(status).withOpacity(0.12),
                      child: Icon(
                        _statusIcon(status),
                        color: _statusColor(status),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_safeText(t['tipo'])} • ${_safeText(profile?['nome'])}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'CPF: ${_safeText(profile?['cpf'])}',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _statusBadge(status),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(_safeText(t['mensagem'])),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text(
                      'Alterar status:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ticketId.isEmpty
                          ? const Text('-')
                          : _statusDropdown(
                              ticketId: ticketId,
                              currentStatus: status,
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              SizedBox(
                width: 260,
                child: DropdownButtonFormField<String>(
                  value: _statusFilter,
                  decoration: InputDecoration(
                    labelText: 'Filtrar por status',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  items: _filters.map((filter) {
                    return DropdownMenuItem(
                      value: filter,
                      child: Text(filter),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _statusFilter = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              if (_filteredTickets.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Nenhum chamado encontrado para esse filtro.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else if (isDesktop)
                _buildDesktopTable()
              else
                _buildMobileCards(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      selectedIndex: 2,
      title: 'Chamados',
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : _buildContent(),
    );
  }
}