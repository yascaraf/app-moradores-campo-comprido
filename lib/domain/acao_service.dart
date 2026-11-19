import 'entidades.dart';
import 'repositorios.dart';

/// Regras de negócio da lista de ações (RF04).
class AcaoService {
  final AcaoRepositorio acoes;

  AcaoService({required this.acoes});

  /// Só ações com status aberta, da data mais próxima para a mais distante.
  Future<List<Acao>> listarAbertas() async {
    final todas = await acoes.listar();
    final abertas =
        todas.where((acao) => acao.status == StatusAcao.aberta).toList();
    abertas.sort((a, b) => a.dataHora.compareTo(b.dataHora));
    return abertas;
  }
}