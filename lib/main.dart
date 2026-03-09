import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/routes/app_routes.dart';

import 'features/auth/login_page.dart';
import 'features/home/home_page.dart';
import 'features/payments/payments_page.dart';
import 'features/benefits/benefits_page.dart';
import 'features/support/support_page.dart';
import 'features/plan/plan_page.dart';
import 'features/campaigns/campaigns_page.dart';
import 'features/splash/splash_page.dart';
import 'features/test/test_supabase_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://twdmdfcwvopjrmwvxvey.supabase.co',
    anonKey: 'sb_publishable_wxTdPk_Qx9I8_H5IC1lBig_p7zyq8hQ',
  );

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
          seedColor: protectYellow,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F6F6),
        appBarTheme: const AppBarTheme(
          backgroundColor: protectYellow,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashPage(),
        AppRoutes.login: (context) => const LoginPage(),
        AppRoutes.home: (context) => const HomePage(),
        AppRoutes.payments: (context) => const PaymentsPage(),
        AppRoutes.benefits: (context) => const BenefitsPage(),
        AppRoutes.support: (context) => const SupportPage(),
        AppRoutes.plan: (context) => const PlanPage(),
        AppRoutes.campaigns: (context) => const CampaignsPage(),
        AppRoutes.testSupabase: (context) => const TestSupabasePage(),
      },
    );
  }
}