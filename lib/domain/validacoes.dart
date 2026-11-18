/// Regras de validação do app. Cada método devolve null quando está tudo certo
/// ou a mensagem de erro (problema + como corrigir) quando há falha.
class Validacoes {
  static const int maxTitulo = 100;
  static const int maxDescricao = 1000;
  static const int maxLocal = 150;
  static const int minSenha = 8;

  static final RegExp _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  static String? obrigatorio(String? valor, String rotulo) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Preencha o campo $rotulo.';
    }
    return null;
  }

  static String? email(String? valor) {
    final erro = obrigatorio(valor, 'E-mail');
    if (erro != null) return erro;
    if (!_emailRegex.hasMatch(valor!.trim())) {
      return 'E-mail inválido. Use um formato como nome@exemplo.com.';
    }
    return null;
  }

  static String? senha(String? valor) {
    if (valor == null || valor.isEmpty) return 'Preencha o campo Senha.';
    if (valor.length < minSenha) {
      return 'A senha precisa ter pelo menos $minSenha caracteres.';
    }
    return null;
  }

  /// Para título, descrição e local: obrigatório, com limite de tamanho
  /// e sem marcação HTML (< ou >).
  static String? textoLivre(String? valor, String rotulo, int max) {
    final erro = obrigatorio(valor, rotulo);
    if (erro != null) return erro;
    final texto = valor!.trim();
    if (texto.length > max) {
      return 'O campo $rotulo aceita até $max caracteres. Reduza o texto.';
    }
    if (texto.contains('<') || texto.contains('>')) {
      return 'O campo $rotulo não pode ter os símbolos < ou >. Remova-os.';
    }
    return null;
  }

  /// [agora] existe para os testes poderem fixar a hora atual.
  static String? dataFutura(DateTime? valor, {DateTime? agora}) {
    if (valor == null) return 'Escolha a data e a hora da ação.';
    if (!valor.isAfter(agora ?? DateTime.now())) {
      return 'A data e a hora precisam ser futuras. Escolha um horário depois de agora.';
    }
    return null;
  }
}