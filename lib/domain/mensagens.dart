/// Textos padrão mostrados ao usuário (seção 10 da documentação).
/// Ficam todos aqui para que mudar um texto seja mudar um único lugar.
class Mensagens {
  Mensagens._(); // impede criar objetos desta classe: ela só guarda textos

  static const String falhaTecnica =
      'Não foi possível concluir. Verifique sua internet e tente de novo.';

  static const String participacaoDuplicada =
      'Participação já registrada. Você já está inscrito nesta ação.';

  static const String inscricaoCancelada =
      'Inscrição cancelada. Você pode se inscrever de novo quando quiser.';

  static const String semLoginInscrever =
      'Você precisa entrar na sua conta para se inscrever. Toque em Entrar.';

  static const String semLoginCancelar =
      'Você precisa entrar na sua conta para cancelar. Toque em Entrar.';

  static const String acaoIndisponivel =
      'Esta ação não está mais aberta para inscrições. '
      'Toque em Ver outras ações.';

  static const String inscricaoNaoEncontrada =
      'Não encontramos uma inscrição ativa sua nesta ação.';

  static String inscricaoConfirmada({
    required String titulo,
    required String dia,
    required String data,
    required String hora,
  }) =>
      'Inscrição confirmada! Você está inscrito no $titulo, $dia, $data, às $hora.';
}