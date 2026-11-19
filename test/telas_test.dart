import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_moradores_campo_comprido/main.dart';

// Usa uma tela grande no teste, para a lista inteira caber sem rolagem.
void _usarTelaGrande(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Future<void> _abrirApp(WidgetTester tester) async {
  _usarTelaGrande(tester);
  await tester.pumpWidget(MoradoresApp(estado: criarEstadoDeDemonstracao()));
  await tester.pumpAndSettle();
}

void main() {
  group('Telas: lista de ações', () {
    testWidgets('mostra só ações abertas, da data mais próxima à mais distante',
        (tester) async {
      await _abrirApp(tester);

      expect(find.text('Mutirão de limpeza da praça'), findsOneWidget);
      expect(find.text('Campanha de agasalhos'), findsOneWidget);
      expect(find.text('Arrecadação de brinquedos para a creche'),
          findsOneWidget);
      expect(find.text('Feira de troca de livros'), findsNothing);
      expect(find.text('Aberta'), findsNWidgets(3));

      final y1 = tester.getTopLeft(find.text('Mutirão de limpeza da praça')).dy;
      final y2 = tester.getTopLeft(find.text('Campanha de agasalhos')).dy;
      final y3 = tester
          .getTopLeft(find.text('Arrecadação de brinquedos para a creche'))
          .dy;
      expect(y1 < y2 && y2 < y3, isTrue);
    });
  });

  group('Telas: detalhes, inscrição e cancelamento', () {
    testWidgets('inscrever mostra a confirmação e cancelar pede confirmação',
        (tester) async {
      await _abrirApp(tester);

      await tester.tap(find.text('Mutirão de limpeza da praça'));
      await tester.pumpAndSettle();
      expect(find.text('28/11/2026'), findsOneWidget);
      expect(find.text('09:00'), findsOneWidget);

      await tester.tap(find.text('Inscrever-se'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Inscrição confirmada!'), findsOneWidget);
      expect(find.text('Cancelar inscrição'), findsOneWidget);

      await tester.tap(find.text('Cancelar inscrição'));
      await tester.pumpAndSettle();
      expect(find.text('Cancelar sua inscrição?'), findsOneWidget);

      await tester.tap(find.text('Sim, cancelar'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Inscrição cancelada.'), findsOneWidget);
      expect(find.text('Inscrever-se'), findsOneWidget);
    });
  });

  group('Acessibilidade (RNF04)', () {
    testWidgets('lista cumpre alvo de toque, rótulo e contraste',
        (tester) async {
      final semantica = tester.ensureSemantics();
      await _abrirApp(tester);

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      semantica.dispose();
    });

    testWidgets('detalhes cumprem alvo de toque, rótulo e contraste',
        (tester) async {
      final semantica = tester.ensureSemantics();
      await _abrirApp(tester);
      await tester.tap(find.text('Mutirão de limpeza da praça'));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      semantica.dispose();
    });
  });
}