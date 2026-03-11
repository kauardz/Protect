import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:protect_admin/features/auth/admin_login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://twdmdfcwvopjrmwvxvey.supabase.co',
    anonKey: 'SEU_ANON_KEY',
  );

  runApp(const ProtectAdmin());
}

class ProtectAdmin extends StatelessWidget {
  const ProtectAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Protect Admin',
      debugShowCheckedModeBanner: false,
      home: const AdminLoginPage(),
    );
  }
}