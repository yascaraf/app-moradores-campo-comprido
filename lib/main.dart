import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'data/repositorios_em_memoria.dart';
import 'domain/acao_service.dart';
import 'domain/inscricao_service.dart';
import 'presentation/app_estado.dart';
import 'presentation/tela_lista_acoes.dart';

/// Monta o app com dados fictícios em memória. Quando o Firebase for
/// integrado, só esta função muda: entram os repositórios do Firestore.
AppEstado criarEstadoDeDemonstracao() {
  final acoes = AcaoRepositorioEmMemoria.comDadosDeDemonstracao();
  final inscricoes = InscricaoRepositorioEmMemoria();
  return AppEstado(
    acaoService: AcaoService(acoes: acoes),
    inscricaoService: InscricaoService(acoes: acoes, inscricoes: inscricoes),
    usuarioId: 'usuario-demonstracao',
  );
}

void main() {
  runApp(MoradoresApp(estado: criarEstadoDeDemonstracao()));
}

class MoradoresApp extends StatelessWidget {
  const MoradoresApp({super.key, required this.estado});

  final AppEstado estado;

  @override
  Widget build(BuildContext context) {
    return Provider<AppEstado>.value(
      value: estado,
      child: MaterialApp(
        title: 'Campo Comprido',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B5E20)),
          useMaterial3: true,
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(minimumSize: const Size(48, 56)),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(minimumSize: const Size(48, 56)),
          ),
        ),
        home: const TelaListaAcoes(),
      ),
    );
  }
}