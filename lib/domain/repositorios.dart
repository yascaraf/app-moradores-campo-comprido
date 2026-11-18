import 'entidades.dart';

/// Contrato para buscar ações. Quem implementa (na camada de dados)
/// decide como: Firestore, memória, etc.
abstract class AcaoRepositorio {
  /// Devolve a ação ou null se ela não existir.
  Future<Acao?> buscarPorId(String id);
}

/// Contrato para ler e gravar inscrições.
abstract class InscricaoRepositorio {
  /// Devolve a inscrição ou null se o morador nunca se inscreveu.
  Future<Inscricao?> buscar(String acaoId, String usuarioId);

  /// Cria a inscrição ou atualiza a existente (mesmo id composto).
  Future<void> salvar(Inscricao inscricao);
}