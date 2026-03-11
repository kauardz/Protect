import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:protect/services/session_service.dart';

class SupabaseService {
  static final client = Supabase.instance.client;

  // =========================
  // AUTH / SESSION
  // =========================

  static User? get currentUser => client.auth.currentUser;
  static Session? get currentSession => client.auth.currentSession;

  static Future<void> signOut() async {
    await client.auth.signOut();
    SessionService.clear();
  }

  static Future<Map<String, dynamic>?> getCurrentProfile() async {
    final user = currentUser;

    if (user == null) return null;

    final profile = await client
        .from('profiles')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();

    return profile;
  }

  static Future<bool> restoreSession() async {
    final profile = await getCurrentProfile();

    if (profile == null) {
      SessionService.clear();
      return false;
    }

    SessionService.setUser(
      profileId: profile['id'].toString(),
      nome: profile['nome']?.toString() ?? 'Cliente',
      cpf: profile['cpf']?.toString() ?? '',
    );

    return true;
  }

  static Future<void> login({
    required String email,
    required String password,
  }) async {
    final authResponse = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = authResponse.user;

    if (user == null) {
      throw Exception('Usuário não autenticado.');
    }

    final profile = await client
        .from('profiles')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();

    if (profile == null) {
      throw Exception('Perfil não encontrado para este usuário.');
    }

    SessionService.setUser(
      profileId: profile['id'].toString(),
      nome: profile['nome']?.toString() ?? 'Cliente',
      cpf: profile['cpf']?.toString() ?? '',
    );
  }

  static Future<void> register({
    required String nome,
    required String cpf,
    required String email,
    required String senha,
  }) async {
    final authResponse = await client.auth.signUp(
      email: email,
      password: senha,
    );

    final user = authResponse.user;

    if (user == null) {
      throw Exception('Não foi possível criar o usuário no Auth.');
    }

    await client.from('profiles').insert({
      'user_id': user.id,
      'nome': nome,
      'cpf': cpf,
      'telefone': null,
    });
  }

  // =========================
  // HOME
  // =========================

  static Future<Map<String, dynamic>?> getLatestPlan(String profileId) async {
    return await client
        .from('plans')
        .select()
        .eq('profile_id', profileId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
  }

  static Future<Map<String, dynamic>?> getNextPayment(String profileId) async {
    return await client
        .from('payments')
        .select()
        .eq('profile_id', profileId)
        .order('vencimento', ascending: true)
        .limit(1)
        .maybeSingle();
  }

  static Future<Map<String, dynamic>?> getLatestBenefits(String profileId) async {
    return await client
        .from('benefits')
        .select()
        .eq('profile_id', profileId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
  }

  static Future<Map<String, dynamic>> getHomeData(String profileId) async {
    final plan = await getLatestPlan(profileId);
    final payment = await getNextPayment(profileId);
    final benefits = await getLatestBenefits(profileId);

    return {
      'plan': plan,
      'payment': payment,
      'benefits': benefits,
    };
  }

  // =========================
  // PAYMENTS
  // =========================

  static Future<List<dynamic>> getPayments(String profileId) async {
    return await client
        .from('payments')
        .select()
        .eq('profile_id', profileId)
        .order('vencimento', ascending: true);
  }

  // =========================
  // BENEFITS
  // =========================

  static Future<Map<String, dynamic>?> getBenefits(String profileId) async {
    return await client
        .from('benefits')
        .select()
        .eq('profile_id', profileId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
  }

  // =========================
  // CAMPAIGNS
  // =========================

  static Future<List<dynamic>> getCampaigns() async {
    return await client
        .from('campaigns')
        .select()
        .eq('ativa', true)
        .order('created_at', ascending: false);
  }

  // =========================
  // SUPPORT
  // =========================

  static Future<void> createSupportTicket({
    required String profileId,
    required String tipo,
    required String mensagem,
  }) async {
    await client.from('support_tickets').insert({
      'profile_id': profileId,
      'tipo': tipo,
      'mensagem': mensagem,
      'status': 'aberto',
    });
  }

  static Future<List<dynamic>> getMyTickets(String profileId) async {
    return await client
        .from('support_tickets')
        .select()
        .eq('profile_id', profileId)
        .order('created_at', ascending: false);
  }

  // =========================
  // HELPERS
  // =========================

  static String formatMoney(dynamic value) {
    if (value == null) return 'R\$ 0,00';

    final number = double.tryParse(value.toString());
    if (number == null) return 'R\$ 0,00';

    return NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    ).format(number);
  }

  static String formatDate(dynamic value, {String fallback = 'Não informado'}) {
    if (value == null) return fallback;

    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) return value.toString();

    return DateFormat('dd/MM/yyyy').format(parsed);
  }

  static String formatDateTime(dynamic value,
      {String fallback = 'Não informado'}) {
    if (value == null) return fallback;

    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) return value.toString();

    return DateFormat('dd/MM/yyyy HH:mm').format(parsed);
  }

  static String formatShortDate(dynamic value, {String fallback = '--'}) {
    if (value == null) return fallback;

    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) return fallback;

    return DateFormat('dd/MM').format(parsed);
  }

  static String safeText(dynamic value, {String fallback = 'Não informado'}) {
    if (value == null) return fallback;

    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  static int safeInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}