import 'package:flutter/material.dart';
import 'package:protect/main.dart';
import 'package:protect/core/routes/app_routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const Color protectYellow = ProtectApp.protectYellow;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Protect'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

            // ===== TOPO COM LOGO =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.black.withOpacity(0.08),
                  ),
                ),
              ),
              child: Column(
                children: [
                  LayoutBuilder(
                    builder: (context, c) {
                      final double h = c.maxWidth < 420 ? 78.0 : 96.0;

                      return Image.asset(
                        'assets/images/logo.png',
                        height: h,
                        fit: BoxFit.contain,
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Clube de benefícios • 4 camadas de proteção',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ===== MENU =====
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  _menuCard(
                    context: context,
                    icon: Icons.phone_android,
                    title: 'Meu Plano',
                    subtitle: 'Status e vencimento do plano',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.plan);
                    },
                  ),

                  const SizedBox(height: 12),

                  _menuCard(
                    context: context,
                    icon: Icons.payments_outlined,
                    title: 'Pagamentos',
                    subtitle: 'Boletos, Pix e cartão',
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
                    subtitle: 'Veja se você está participando',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.campaigns);
                    },
                  ),

                  const SizedBox(height: 12),

                  _menuCard(
                    context: context,
                    icon: Icons.support_agent_outlined,
                    title: 'Suporte',
                    subtitle: 'Problemas, dúvidas ou elogios',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.support);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ===== BOTÃO DE AJUDA =====
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: protectYellow,
        foregroundColor: Colors.black,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Suporte Protect em breve'),
            ),
          );
        },
        icon: const Icon(Icons.chat_bubble_outline),
        label: const Text('Ajuda'),
      ),
    );
  }

  // ===== CARD DO MENU =====
  static Widget _menuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Card(
        child: ListTile(
          leading: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: protectYellow.withOpacity(0.22),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.black),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(color: Colors.black54),
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