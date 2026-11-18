import 'entidades.dart';
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
  static const String msgFalha =
      'Não foi possível concluir. Verifique sua internet e tente de novo.';

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
        'Você precisa entrar na sua conta para se inscrever. Toque em Entrar.',
      );
    }
    try {
      final acao = await acoes.buscarPorId(acaoId);
      if (acao == null || acao.status != StatusAcao.aberta) {
        return const ResultadoOperacao(
          TipoResultado.acaoIndisponivel,
          'Esta ação não está mais aberta para inscrições. '
          'Toque em Ver outras ações.',
        );
      }

      final existente = await inscricoes.buscar(acaoId, usuarioId);
      if (existente != null && existente.status == StatusInscricao.ativa) {
        return const ResultadoOperacao(
          TipoResultado.jaRegistrada,
          'Participação já registrada. Você já está inscrito nesta ação.',
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
      return const ResultadoOperacao(TipoResultado.falha, msgFalha);
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
        'Você precisa entrar na sua conta para cancelar. Toque em Entrar.',
      );
    }
    try {
      final existente = await inscricoes.buscar(acaoId, usuarioId);
      if (existente == null || existente.status != StatusInscricao.ativa) {
        return const ResultadoOperacao(
          TipoResultado.inscricaoNaoEncontrada,
          'Não encontramos uma inscrição ativa sua nesta ação.',
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
        'Inscrição cancelada. Você pode se inscrever de novo quando quiser.',
      );
    } catch (_) {
      return const ResultadoOperacao(TipoResultado.falha, msgFalha);
    }
  }

  String _mensagemConfirmacao(Acao acao) {
    final d = acao.dataHora;
    final dia = _dias[d.weekday - 1];
    final data = '${_dois(d.day)}/${_dois(d.month)}/${d.year}';
    final hora = '${_dois(d.hour)}:${_dois(d.minute)}';
    return 'Inscrição confirmada! Você está inscrito no ${acao.titulo}, '
        '$dia, $data, às $hora.';
  }

  String _dois(int n) => n.toString().padLeft(2, '0');
}