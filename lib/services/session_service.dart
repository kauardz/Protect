class SessionService {
  static String? currentProfileId;
  static String? currentNome;
  static String? currentCpf;

  static void setUser({
    required String profileId,
    required String nome,
    required String cpf,
  }) {
    currentProfileId = profileId;
    currentNome = nome;
    currentCpf = cpf;
  }

  static void clear() {
    currentProfileId = null;
    currentNome = null;
    currentCpf = null;
  }
}