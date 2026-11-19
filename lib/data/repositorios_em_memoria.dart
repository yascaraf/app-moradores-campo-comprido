import '../domain/entidades.dart';
import '../domain/repositorios.dart';

/// Ações guardadas na memória. Serve para demonstrar o app e para os testes,
/// até o Cloud Firestore ser integrado.
class AcaoRepositorioEmMemoria implements AcaoRepositorio {
  AcaoRepositorioEmMemoria();

  /// Dados fictícios de demonstração (inseridos fora de ordem de propósito,
  /// para provar que a lista ordena por data).
  factory AcaoRepositorioEmMemoria.comDadosDeDemonstracao() {
    final repositorio = AcaoRepositorioEmMemoria();
    repositorio.adicionar(Acao(
      id: 'a3',
      titulo: 'Arrecadação de brinquedos para a creche',
      descricao: 'Receberemos brinquedos novos ou em bom estado para as '
          'crianças da creche do bairro.',
      dataHora: DateTime(2026, 12, 12, 10, 0),
      local: 'Sede da associação',
    ));
    repositorio.adicionar(Acao(
      id: 'a4',
      titulo: 'Feira de troca de livros',
      descricao: 'Feira já realizada.',
      dataHora: DateTime(2026, 11, 10, 10, 0),
      local: 'Salão da associação',
      status: StatusAcao.encerrada,
    ));
    repositorio.adicionar(Acao(
      id: 'a1',
      titulo: 'Mutirão de limpeza da praça',
      descricao: 'Vamos limpar e organizar a praça do bairro. Leve luvas '
          'e disposição. Voluntários são bem-vindos.',
      dataHora: DateTime(2026, 11, 28, 9, 0),
      local: 'Praça central do bairro',
    ));
    repositorio.adicionar(Acao(
      id: 'a2',
      titulo: 'Campanha de agasalhos',
      descricao: 'Separação e entrega dos agasalhos arrecadados pelas '
          'famílias do bairro.',
      dataHora: DateTime(2026, 12, 5, 14, 0),
      local: 'Salão da associação',
    ));
    return repositorio;
  }

  final Map<String, Acao> _acoes = {};

  void adicionar(Acao acao) => _acoes[acao.id] = acao;

  @override
  Future<Acao?> buscarPorId(String id) async => _acoes[id];

  @override
  Future<List<Acao>> listar() async => _acoes.values.toList();
}

/// Inscrições na memória. Usa o id composto como chave,
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