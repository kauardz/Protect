import 'package:flutter/material.dart';
import 'package:protect/services/supabase_service.dart';

class TestSupabasePage extends StatefulWidget {
  const TestSupabasePage({super.key});

  @override
  State<TestSupabasePage> createState() => _TestSupabasePageState();
}

class _TestSupabasePageState extends State<TestSupabasePage> {
  String result = 'Nenhum teste executado ainda.';

  Future<void> insertProfile() async {
    try {
      await SupabaseService.client.from('profiles').insert({
        'nome': 'Cliente Teste',
        'cpf': '00000000000',
        'telefone': '(91) 99999-9999',
      });

      setState(() {
        result = 'Cliente inserido com sucesso.';
      });
    } catch (e) {
      setState(() {
        result = 'Erro ao inserir: $e';
      });
    }
  }

  Future<void> loadProfiles() async {
    try {
      final data = await SupabaseService.client
          .from('profiles')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        result = data.toString();
      });
    } catch (e) {
      setState(() {
        result = 'Erro ao buscar: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teste Supabase'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: insertProfile,
                child: const Text('Inserir cliente teste'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loadProfiles,
                child: const Text('Buscar clientes'),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(result),
              ),
            ),
          ],
        ),
      ),
    );
  }
}