import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/auth/admin_login_page.dart';
import '../features/campaigns/admin_campaigns_page.dart';
import '../features/clients/admin_clients_page.dart';
import '../features/dashboard/admin_dashboard_page.dart';
import '../features/tickets/admin_tickets_page.dart';

class AdminShell extends StatelessWidget {
  final int selectedIndex;
  final String title;
  final Widget child;

  const AdminShell({
    super.key,
    required this.selectedIndex,
    required this.title,
    required this.child,
  });

  Future<void> _logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AdminLoginPage()),
      (route) => false,
    );
  }

  void _goTo(BuildContext context, int index) {
    if (index == selectedIndex) return;

    Widget page;
    switch (index) {
      case 0:
        page = const AdminDashboardPage();
        break;
      case 1:
        page = const AdminClientsPage();
        break;
      case 2:
        page = const AdminTicketsPage();
        break;
      case 3:
        page = const AdminCampaignsPage();
        break;
      default:
        page = const AdminDashboardPage();
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  Widget _menuItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
  }) {
    final selected = index == selectedIndex;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _goTo(context, index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF2C300).withOpacity(0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: selected
              ? Border.all(
                  color: const Color(0xFFF2C300),
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.black87,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    final email = Supabase.instance.client.auth.currentUser?.email ?? 'Admin';

    return Container(
      width: 270,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 18),
      child: Column(
        children: [
          Row(
            children: const [
              CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFFF2C300),
                child: Icon(
                  Icons.admin_panel_settings_outlined,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Protect Admin',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          _menuItem(
            context,
            index: 0,
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
          ),
          const SizedBox(height: 10),
          _menuItem(
            context,
            index: 1,
            icon: Icons.people_outline,
            label: 'Clientes',
          ),
          const SizedBox(height: 10),
          _menuItem(
            context,
            index: 2,
            icon: Icons.support_agent_outlined,
            label: 'Chamados',
          ),
          const SizedBox(height: 10),
          _menuItem(
            context,
            index: 3,
            icon: Icons.campaign_outlined,
            label: 'Campanhas',
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Logado como',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  email,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              label: const Text('Sair'),
            ),
          ),
        ],
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: _buildSidebar(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1000;

        return Scaffold(
          drawer: isDesktop ? null : _buildDrawer(context),
          body: Row(
            children: [
              if (isDesktop) _buildSidebar(context),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 76,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      color: Colors.white,
                      child: Row(
                        children: [
                          if (!isDesktop)
                            Builder(
                              builder: (context) {
                                return IconButton(
                                  onPressed: () {
                                    Scaffold.of(context).openDrawer();
                                  },
                                  icon: const Icon(Icons.menu),
                                );
                              },
                            ),
                          if (!isDesktop) const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(child: child),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}