import 'package:flutter/material.dart';
import 'package:protect/main.dart';
import 'package:protect/services/supabase_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  String _onlyNumbers(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  String? _validateNome(String? value) {
    final nome = value?.trim() ?? '';

    if (nome.isEmpty) {
      return 'Informe seu nome.';
    }

    if (nome.length < 3) {
      return 'Informe um nome válido.';
    }

    return null;
  }

  String? _validateCpf(String? value) {
    final cpf = _onlyNumbers(value ?? '');

    if (cpf.isEmpty) {
      return 'Informe seu CPF.';
    }

    if (cpf.length != 11) {
      return 'O CPF deve conter 11 dígitos.';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Informe seu email.';
    }

    if (!_isValidEmail(email)) {
      return 'Informe um email válido.';
    }

    return null;
  }

  String? _validateSenha(String? value) {
    final senha = value?.trim() ?? '';

    if (senha.isEmpty) {
      return 'Informe sua senha.';
    }

    if (senha.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    }

    return null;
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final nome = _nomeController.text.trim();
    final cpf = _onlyNumbers(_cpfController.text.trim());
    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();

    setState(() {
      _loading = true;
    });

    try {
      await SupabaseService.register(
        nome: nome,
        cpf: cpf,
        email: email,
        senha: senha,
      );

      if (!mounted) return;

      _showMessage('Conta criada com sucesso. Faça login para continuar.');
      Navigator.pop(context);
    } catch (e) {
      final errorText = e.toString().toLowerCase();
      String message = 'Erro ao criar conta.';

      if (errorText.contains('user already registered') ||
          errorText.contains('user_already_exists') ||
          errorText.contains('already registered')) {
        message = 'Este email já está cadastrado.';
      } else if (errorText.contains('over_email_send_rate_limit') ||
          errorText.contains('email rate limit exceeded') ||
          errorText.contains('security purposes')) {
        message =
            'Muitas tentativas seguidas. Aguarde alguns segundos e tente novamente.';
      } else if (errorText.contains('row-level security policy') ||
          errorText.contains('42501')) {
        message =
            'O cadastro foi bloqueado pela política do banco. Verifique as policies da tabela profiles.';
      } else if (errorText.contains('duplicate key') ||
          errorText.contains('profiles_cpf_key')) {
        message = 'Este CPF já está cadastrado.';
      } else if (errorText.contains('signup is disabled')) {
        message = 'O cadastro está desativado no Supabase.';
      } else if (errorText.contains('invalid email')) {
        message = 'O email informado é inválido.';
      } else {
        message = 'Erro ao criar conta: $e';
      }

      _showMessage(message);
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    IconData? icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon) : null,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text('Criar conta'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 430),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 90,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Crie sua conta',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Cadastre-se para acessar seu plano, pagamentos e benefícios.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nomeController,
                    textInputAction: TextInputAction.next,
                    decoration: _inputDecoration(
                      label: 'Nome completo',
                      icon: Icons.person_outline,
                    ),
                    validator: _validateNome,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cpfController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: _inputDecoration(
                      label: 'CPF',
                      icon: Icons.badge_outlined,
                    ),
                    validator: _validateCpf,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: _inputDecoration(
                      label: 'Email',
                      icon: Icons.email_outlined,
                    ),
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _senhaController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    decoration: _inputDecoration(
                      label: 'Senha',
                      icon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                    validator: _validateSenha,
                    onFieldSubmitted: (_) {
                      if (!_loading) {
                        _register();
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ProtectApp.protectYellow,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _loading ? null : _register,
                      child: _loading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Criar conta',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () {
                            Navigator.pop(context);
                          },
                    child: const Text('Já tenho conta'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}