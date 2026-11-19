import 'package:material_ui/material_ui.dart';

import '../domain/entidades.dart';

/// Mostra a situação da ação sempre com texto + ícone + cor,
/// nunca só com cor (RNF04).
class SeloStatus extends StatelessWidget {
  const SeloStatus({super.key, required this.status});

  final StatusAcao status;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final (texto, icone, fundo, frente) = switch (status) {
      StatusAcao.aberta => (
          'Aberta',
          Icons.check_circle,
          cores.primaryContainer,
          cores.onPrimaryContainer,
        ),
      StatusAcao.encerrada => (
          'Encerrada',
          Icons.lock,
          cores.surfaceContainerHighest,
          cores.onSurface,
        ),
      StatusAcao.cancelada => (
          'Cancelada',
          Icons.cancel,
          cores.errorContainer,
          cores.onErrorContainer,
        ),
    };

    return Semantics(
      label: 'Situação: $texto',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: fundo,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 20, color: frente),
            const SizedBox(width: 6),
            Text(
              texto,
              style: TextStyle(color: frente, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

/// Uma linha com ícone e texto. O texto quebra de linha se for longo.
class LinhaInformacao extends StatelessWidget {
  const LinhaInformacao({super.key, required this.icone, required this.texto});

  final IconData icone;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(child: Icon(icone, size: 20)),
        const SizedBox(width: 8),
        Expanded(child: Text(texto)),
      ],
    );
  }
}