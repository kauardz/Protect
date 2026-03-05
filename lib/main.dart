import 'package:flutter/material.dart';

void main() {
  runApp(const ProtectApp());
}

class ProtectApp extends StatelessWidget {
  const ProtectApp({super.key});

  static const Color protectYellow = Color(0xFFF2C300);
  static const Color protectBlack = Color(0xFF000000);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Protect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(242, 195, 0, 1),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F6F6),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromRGBO(242, 195, 0, 1),
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: false,
        ),
        // Flutter 3.41+ usa CardThemeData
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const Color protectYellow = ProtectApp.protectYellow;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar branco e minimalista (combina com a home)
      appBar: AppBar(
        title: const Text('Protect'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ===== Topo branco (logo aparece bem) =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.black.withOpacity(0.08)),
                ),
              ),
              child: Column(
                children: [
                  // Logo maior e responsiva
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

            // ===== Conteúdo =====
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _menuCard(
                    context: context,
                    icon: Icons.phone_android,
                    title: 'Meu Plano',
                    subtitle: 'Status e vencimento do plano',
                    onTap: () => _snack(context, 'Abrir: Meu Plano'),
                  ),
                  const SizedBox(height: 12),
                  _menuCard(
                    context: context,
                    icon: Icons.payments_outlined,
                    title: 'Pagamentos',
                    subtitle: 'Boletos, Pix e cartão',
                    onTap: () => _snack(context, 'Abrir: Pagamentos'),
                  ),
                  const SizedBox(height: 12),
                  _menuCard(
                    context: context,
                    icon: Icons.verified_user_outlined,
                    title: 'Benefícios',
                    subtitle: 'Películas grátis e trocas disponíveis',
                    onTap: () => _snack(context, 'Abrir: Benefícios'),
                  ),
                  const SizedBox(height: 12),
                  _menuCard(
                    context: context,
                    icon: Icons.campaign_outlined,
                    title: 'Promoções e Campanhas',
                    subtitle: 'Veja se você está participando',
                    onTap: () => _snack(context, 'Abrir: Promoções e Campanhas'),
                  ),
                  const SizedBox(height: 12),
                  _menuCard(
                    context: context,
                    icon: Icons.support_agent_outlined,
                    title: 'Suporte',
                    subtitle: 'Problemas, dúvidas ou elogios',
                    onTap: () => _snack(context, 'Abrir: Suporte'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Botão de ação rápida (opcional)
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: protectYellow,
        foregroundColor: Colors.black,
        onPressed: () => _snack(context, 'Ação rápida: Ajuda'),
        icon: const Icon(Icons.chat_bubble_outline),
        label: const Text('Ajuda'),
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
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ),
    );
  }

  static void _snack(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        duration: const Duration(milliseconds: 900),
      ),
    );
  }
}