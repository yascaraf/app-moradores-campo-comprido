/// Perfis possíveis de um usuário. O nome do valor é o mesmo salvo no Firestore.
enum Perfil { morador, representante }

/// Situação de uma ação comunitária.
enum StatusAcao { aberta, encerrada, cancelada }

/// Situação de uma inscrição. Cancelar não apaga: muda para "cancelada".
enum StatusInscricao { ativa, cancelada }

class Usuario {
  final String id; // igual ao uid do Firebase Authentication
  final String nome;
  final String email;
  final Perfil perfil;

  const Usuario({
    required this.id,
    required this.nome,
    required this.email,
    this.perfil = Perfil.morador, // perfil padrão
  });
}

class Acao {
  final String id;
  final String titulo;
  final String descricao;
  final DateTime dataHora;
  final String local;
  final StatusAcao status;

  const Acao({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.dataHora,
    required this.local,
    this.status = StatusAcao.aberta, // status inicial
  });
}

class Inscricao {
  final String acaoId;
  final String usuarioId;
  final DateTime dataInscricao;
  final StatusInscricao status;

  const Inscricao({
    required this.acaoId,
    required this.usuarioId,
    required this.dataInscricao,
    this.status = StatusInscricao.ativa, // padrão
  });

  /// Id composto (acao_id + usuario_id): impede inscrição duplicada.
  String get id => idComposto(acaoId, usuarioId);

  static String idComposto(String acaoId, String usuarioId) =>
      '${acaoId}_$usuarioId';
}