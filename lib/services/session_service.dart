class SessionService {
  static String? currentProfileId;
  static String? currentNome;
  static String? currentCpf;
  static String? currentTelefone;
  static String? currentEmail;

  static void setUser({
    required String profileId,
    required String nome,
    required String cpf,
    String? telefone,
    String? email,
  }) {
    currentProfileId = profileId;
    currentNome = nome;
    currentCpf = cpf;
    currentTelefone = telefone;
    currentEmail = email;
  }

  static void clear() {
    currentProfileId = null;
    currentNome = null;
    currentCpf = null;
    currentTelefone = null;
    currentEmail = null;
  }
}