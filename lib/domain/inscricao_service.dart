import 'entidades.dart';
import 'mensagens.dart';
import 'repositorios.dart';

/// Tipos de resultado possíveis das operações de inscrição.
enum TipoResultado {
  confirmada,
  reativada,
  jaRegistrada,
  semLogin,
  acaoIndisponivel,
  inscricaoNaoEncontrada,
  cancelada,
  falha,
}

/// Resultado de uma operação, com a mensagem pronta para mostrar ao usuário.
class ResultadoOperacao {
  final TipoResultado tipo;
  final String mensagem;

  const ResultadoOperacao(this.tipo, this.mensagem);

  bool get sucesso =>
      tipo == TipoResultado.confirmada ||
      tipo == TipoResultado.reativada ||
      tipo == TipoResultado.cancelada;
}

/// Regras de negócio da inscrição (RF06) e do cancelamento (RF07).
/// Não conhece o Firebase: só fala com os contratos de repositorios.dart.
class InscricaoService {
  static const String msgFalha = Mensagens.falhaTecnica;

  static const List<String> _dias = [
    'segunda-feira',
    'terça-feira',
    'quarta-feira',
    'quinta-feira',
    'sexta-feira',
    'sábado',
    'domingo',
  ];

  final AcaoRepositorio acoes;
  final InscricaoRepositorio inscricoes;
  final DateTime Function() agora;

  InscricaoService({
    required this.acoes,
    required this.inscricoes,
    DateTime Function()? agora,
  }) : agora = agora ?? DateTime.now;

  /// Valida nesta ordem: usuário autenticado, ação existente e aberta,
  /// inscrição já existente.
  Future<ResultadoOperacao> inscrever({
    required String? usuarioId,
    required String acaoId,
  }) async {
    if (usuarioId == null || usuarioId.isEmpty) {
      return const ResultadoOperacao(
        TipoResultado.semLogin,
        Mensagens.semLoginInscrever,
      );
    }
    try {
      final acao = await acoes.buscarPorId(acaoId);
      if (acao == null || acao.status != StatusAcao.aberta) {
        return const ResultadoOperacao(
          TipoResultado.acaoIndisponivel,
          Mensagens.acaoIndisponivel,
        );
      }

      final existente = await inscricoes.buscar(acaoId, usuarioId);
      if (existente != null && existente.status == StatusInscricao.ativa) {
        return const ResultadoOperacao(
          TipoResultado.jaRegistrada,
          Mensagens.participacaoDuplicada,
        );
      }

      await inscricoes.salvar(Inscricao(
        acaoId: acaoId,
        usuarioId: usuarioId,
        dataInscricao: agora(),
        status: StatusInscricao.ativa,
      ));

      return ResultadoOperacao(
        existente == null ? TipoResultado.confirmada : TipoResultado.reativada,
        _mensagemConfirmacao(acao),
      );
    } catch (_) {
      return const ResultadoOperacao(
        TipoResultado.falha,
        Mensagens.falhaTecnica,
      );
    }
  }

  /// Cancela só a inscrição do próprio usuário: o id composto usa o
  /// usuarioId de quem está logado. Não apaga, muda o status para cancelada.
  Future<ResultadoOperacao> cancelar({
    required String? usuarioId,
    required String acaoId,
  }) async {
    if (usuarioId == null || usuarioId.isEmpty) {
      return const ResultadoOperacao(
        TipoResultado.semLogin,
        Mensagens.semLoginCancelar,
      );
    }
    try {
      final existente = await inscricoes.buscar(acaoId, usuarioId);
      if (existente == null || existente.status != StatusInscricao.ativa) {
        return const ResultadoOperacao(
          TipoResultado.inscricaoNaoEncontrada,
          Mensagens.inscricaoNaoEncontrada,
        );
      }

      await inscricoes.salvar(Inscricao(
        acaoId: existente.acaoId,
        usuarioId: existente.usuarioId,
        dataInscricao: existente.dataInscricao,
        status: StatusInscricao.cancelada,
      ));

      return const ResultadoOperacao(
        TipoResultado.cancelada,
        Mensagens.inscricaoCancelada,
      );
    } catch (_) {
      return const ResultadoOperacao(
        TipoResultado.falha,
        Mensagens.falhaTecnica,
      );
    }
  }

  /// Diz se o usuário já tem inscrição ativa na ação. A tela usa isso para
  /// escolher entre Inscrever-se e Cancelar inscrição.
  Future<bool> temInscricaoAtiva({
    required String? usuarioId,
    required String acaoId,
  }) async {
    if (usuarioId == null || usuarioId.isEmpty) return false;
    try {
      final existente = await inscricoes.buscar(acaoId, usuarioId);
      return existente != null && existente.status == StatusInscricao.ativa;
    } catch (_) {
      return false;
    }
  }

  String _mensagemConfirmacao(Acao acao) {
    final d = acao.dataHora;
    return Mensagens.inscricaoConfirmada(
      titulo: acao.titulo,
      dia: _dias[d.weekday - 1],
      data: '${_dois(d.day)}/${_dois(d.month)}/${d.year}',
      hora: '${_dois(d.hour)}:${_dois(d.minute)}',
    );
  }

  String _dois(int n) => n.toString().padLeft(2, '0');
}