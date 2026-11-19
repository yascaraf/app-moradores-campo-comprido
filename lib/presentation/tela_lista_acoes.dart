import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../domain/entidades.dart';
import '../domain/mensagens.dart';
import 'app_estado.dart';
import 'componentes.dart';
import 'formatacao.dart';
import 'tela_detalhes_acao.dart';

/// Lista de ações abertas (RF04).
class TelaListaAcoes extends StatefulWidget {
  const TelaListaAcoes({super.key});

  @override
  State<TelaListaAcoes> createState() => _TelaListaAcoesState();
}

class _TelaListaAcoesState extends State<TelaListaAcoes> {
  late Future<List<Acao>> _acoes;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  void _carregar() {
    _acoes = context.read<AppEstado>().acaoService.listarAbertas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ações da associação')),
      body: FutureBuilder<List<Acao>>(
        future: _acoes,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(semanticsLabel: 'Carregando ações'),
            );
          }
          if (snapshot.hasError) {
            return _MensagemDeErro(onTentarDeNovo: () => setState(_carregar));
          }
          final acoes = snapshot.data ?? <Acao>[];
          if (acoes.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Não há ações abertas no momento. Volte mais tarde.'),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: acoes.length + 1,
            separatorBuilder: (context, indice) => const SizedBox(height: 12),
            itemBuilder: (context, indice) {
              if (indice == 0) {
                return Text(
                  'Dados fictícios de demonstração.',
                  style: Theme.of(context).textTheme.bodySmall,
                );
              }
              return _CartaoAcao(acao: acoes[indice - 1]);
            },
          );
        },
      ),
    );
  }
}

class _CartaoAcao extends StatelessWidget {
  const _CartaoAcao({required this.acao});

  final Acao acao;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => TelaDetalhesAcao(acao: acao),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(acao.titulo, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              SeloStatus(status: acao.status),
              const SizedBox(height: 12),
              LinhaInformacao(
                icone: Icons.event,
                texto:
                    '${formatarData(acao.dataHora)} às ${formatarHora(acao.dataHora)}',
              ),
              const SizedBox(height: 4),
              LinhaInformacao(icone: Icons.place, texto: acao.local),
            ],
          ),
        ),
      ),
    );
  }
}

class _MensagemDeErro extends StatelessWidget {
  const _MensagemDeErro({required this.onTentarDeNovo});

  final VoidCallback onTentarDeNovo;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            const Text(Mensagens.falhaTecnica, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onTentarDeNovo,
              child: const Text('Tentar de novo'),
            ),
          ],
        ),
      ),
    );
  }
}