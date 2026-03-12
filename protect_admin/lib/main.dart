import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/admin_login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://twdmdfcwvopjrmwvxvey.supabase.co',
    anonKey: 'sb_publishable_wxTdPk_Qx9I8_H5IC1lBig_p7zyq8hQ',
  );

  runApp(const ProtectAdmin());
}

class ProtectAdmin extends StatelessWidget {
  const ProtectAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AdminLoginPage(),
    );
  }
}