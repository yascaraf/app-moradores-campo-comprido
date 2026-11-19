import '../domain/acao_service.dart';
import '../domain/inscricao_service.dart';

/// Reúne o que as telas precisam. É entregue às telas pelo provider.
class AppEstado {
  const AppEstado({
    required this.acaoService,
    required this.inscricaoService,
    required this.usuarioId,
  });

  final AcaoService acaoService;
  final InscricaoService inscricaoService;

  /// Id do usuário logado. Null significa sem login.
  final String? usuarioId;
}