import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../domain/entidades.dart';
import '../domain/inscricao_service.dart';
import 'app_estado.dart';
import 'componentes.dart';
import 'formatacao.dart';

/// Detalhes da ação (RF05), com inscrição (RF06) e cancelamento (RF07).
class TelaDetalhesAcao extends StatefulWidget {
  const TelaDetalhesAcao({super.key, required this.acao});

  final Acao acao;

  @override
  State<TelaDetalhesAcao> createState() => _TelaDetalhesAcaoState();
}

class _TelaDetalhesAcaoState extends State<TelaDetalhesAcao> {
  bool? _inscrito; // null enquanto carrega
  bool _processando = false;
  ResultadoOperacao? _resultado;

  @override
  void initState() {
    super.initState();
    _carregarSituacao();
  }

  Future<void> _carregarSituacao() async {
    final estado = context.read<AppEstado>();
    final inscrito = await estado.inscricaoService.temInscricaoAtiva(
      usuarioId: estado.usuarioId,
      acaoId: widget.acao.id,
    );
    if (!mounted) return;
    setState(() => _inscrito = inscrito);
  }

  Future<void> _inscrever() async {
    final estado = context.read<AppEstado>();
    setState(() => _processando = true);
    final resultado = await estado.inscricaoService.inscrever(
      usuarioId: estado.usuarioId,
      acaoId: widget.acao.id,
    );
    if (!mounted) return;
    setState(() {
      _processando = false;
      _resultado = resultado;
      if (resultado.sucesso || resultado.tipo == TipoResultado.jaRegistrada) {
        _inscrito = true;
      }
    });
  }

  Future<void> _cancelar() async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (contextoDialogo) => AlertDialog(
        title: const Text('Cancelar sua inscrição?'),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(minimumSize: const Size(140, 56)),
            onPressed: () => Navigator.of(contextoDialogo).pop(false),
            child: const Text('Voltar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(140, 56)),
            onPressed: () => Navigator.of(contextoDialogo).pop(true),
            child: const Text('Sim, cancelar'),
          ),
        ],
      ),
    );
    if (confirmou != true || !mounted) return;

    final estado = context.read<AppEstado>();
    setState(() => _processando = true);
    final resultado = await estado.inscricaoService.cancelar(
      usuarioId: estado.usuarioId,
      acaoId: widget.acao.id,
    );
    if (!mounted) return;
    setState(() {
      _processando = false;
      _resultado = resultado;
      if (resultado.tipo == TipoResultado.cancelada ||
          resultado.tipo == TipoResultado.inscricaoNaoEncontrada) {
        _inscrito = false;
      }
    });
  }

  List<Widget> _areaDeAcao(BuildContext context) {
    if (widget.acao.status != StatusAcao.aberta) {
      return const [Text('Esta ação não está aberta para inscrições.')];
    }
    if (_inscrito == null) {
      return const [
        Center(
          child: CircularProgressIndicator(
            semanticsLabel: 'Verificando sua inscrição',
          ),
        ),
      ];
    }

    final itens = <Widget>[];
    if (_inscrito == false) {
      itens.add(SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: _processando ? null : _inscrever,
          child: const Text('Inscrever-se'),
        ),
      ));
    } else {
      itens.add(const LinhaInformacao(
        icone: Icons.check_circle,
        texto: 'Você está inscrito nesta ação.',
      ));
      itens.add(const SizedBox(height: 12));
      itens.add(SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: _processando ? null : _cancelar,
          child: const Text('Cancelar inscrição'),
        ),
      ));
    }

    final resultado = _resultado;
    if (resultado != null) {
      itens.add(const SizedBox(height: 16));
      itens.add(_CaixaResultado(resultado: resultado));
      itens.add(const SizedBox(height: 12));
      itens.add(SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Ver outras ações'),
        ),
      ));
    }
    return itens;
  }

  @override
  Widget build(BuildContext context) {
    final acao = widget.acao;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Voltar',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Detalhes da ação'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(acao.titulo, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              SeloStatus(status: acao.status),
              const SizedBox(height: 16),
              _Dado(rotulo: 'Data', valor: formatarData(acao.dataHora)),
              _Dado(rotulo: 'Horário', valor: formatarHora(acao.dataHora)),
              _Dado(rotulo: 'Local', valor: acao.local),
              _Dado(rotulo: 'Descrição', valor: acao.descricao),
              const SizedBox(height: 16),
              ..._areaDeAcao(context),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dado extends StatelessWidget {
  const _Dado({required this.rotulo, required this.valor});

  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(rotulo, style: Theme.of(context).textTheme.labelLarge),
          Text(valor),
        ],
      ),
    );
  }
}

/// Resultado da operação: texto + ícone + cor, e lido pelo leitor de tela.
class _CaixaResultado extends StatelessWidget {
  const _CaixaResultado({required this.resultado});

  final ResultadoOperacao resultado;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final (icone, fundo, frente) = switch (resultado.tipo) {
      TipoResultado.confirmada ||
      TipoResultado.reativada ||
      TipoResultado.cancelada =>
        (Icons.check_circle, cores.primaryContainer, cores.onPrimaryContainer),
      TipoResultado.jaRegistrada => (
          Icons.info,
          cores.secondaryContainer,
          cores.onSecondaryContainer,
        ),
      _ => (Icons.error, cores.errorContainer, cores.onErrorContainer),
    };

    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: fundo,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icone, color: frente),
            const SizedBox(width: 12),
            Expanded(
              child: Text(resultado.mensagem, style: TextStyle(color: frente)),
            ),
          ],
        ),
      ),
    );
  }
}