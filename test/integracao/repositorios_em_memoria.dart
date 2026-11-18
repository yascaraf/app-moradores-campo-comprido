import 'package:app_moradores_campo_comprido/domain/entidades.dart';
import 'package:app_moradores_campo_comprido/domain/repositorios.dart';

/// Banco de ações guardado na memória, só para testes.
class AcaoRepositorioEmMemoria implements AcaoRepositorio {
  final Map<String, Acao> _acoes = {};

  void adicionar(Acao acao) => _acoes[acao.id] = acao;

  @override
  Future<Acao?> buscarPorId(String id) async => _acoes[id];
}

/// Banco de inscrições na memória. Usa o id composto como chave,
/// igual ao que faremos no Firestore.
class InscricaoRepositorioEmMemoria implements InscricaoRepositorio {
  final Map<String, Inscricao> _inscricoes = {};

  int get total => _inscricoes.length;

  @override
  Future<Inscricao?> buscar(String acaoId, String usuarioId) async =>
      _inscricoes[Inscricao.idComposto(acaoId, usuarioId)];

  @override
  Future<void> salvar(Inscricao inscricao) async {
    _inscricoes[inscricao.id] = inscricao;
  }
}