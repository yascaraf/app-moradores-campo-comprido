import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_moradores_campo_comprido/domain/entidades.dart';
import 'package:app_moradores_campo_comprido/domain/inscricao_service.dart';
import 'package:app_moradores_campo_comprido/domain/repositorios.dart';

// "Bancos de mentira" criados pelo mocktail: não acessam o Firebase.
class AcaoRepoMock extends Mock implements AcaoRepositorio {}

class InscricaoRepoMock extends Mock implements InscricaoRepositorio {}

class InscricaoFake extends Fake implements Inscricao {}

void main() {
  late AcaoRepoMock acoes;
  late InscricaoRepoMock inscricoes;
  late InscricaoService service;

  final acaoAberta = Acao(
    id: 'a1',
    titulo: 'Mutirão de limpeza',
    descricao: 'Limpeza da praça',
    dataHora: DateTime(2026, 11, 21, 9, 30), // sábado
    local: 'Praça central',
  );

  Inscricao inscricaoComStatus(StatusInscricao status) => Inscricao(
        acaoId: 'a1',
        usuarioId: 'u1',
        dataInscricao: DateTime(2026, 11, 17),
        status: status,
      );

  setUpAll(() {
    registerFallbackValue(InscricaoFake());
  });

  setUp(() {
    acoes = AcaoRepoMock();
    inscricoes = InscricaoRepoMock();
    service = InscricaoService(
      acoes: acoes,
      inscricoes: inscricoes,
      agora: () => DateTime(2026, 11, 18, 10),
    );
    when(() => inscricoes.salvar(any())).thenAnswer((_) async {});
  });

  group('inscrever', () {
    test('sem login orienta a entrar e não grava nada', () async {
      final r = await service.inscrever(usuarioId: null, acaoId: 'a1');
      expect(r.tipo, TipoResultado.semLogin);
      verifyNever(() => inscricoes.salvar(any()));
    });

    test('ação inexistente é recusada', () async {
      when(() => acoes.buscarPorId('a1')).thenAnswer((_) async => null);
      final r = await service.inscrever(usuarioId: 'u1', acaoId: 'a1');
      expect(r.tipo, TipoResultado.acaoIndisponivel);
      verifyNever(() => inscricoes.salvar(any()));
    });

    test('ação encerrada é recusada', () async {
      when(() => acoes.buscarPorId('a1')).thenAnswer((_) async => Acao(
            id: 'a1',
            titulo: 'Mutirão',
            descricao: 'x',
            dataHora: DateTime(2026, 11, 21),
            local: 'y',
            status: StatusAcao.encerrada,
          ));
      final r = await service.inscrever(usuarioId: 'u1', acaoId: 'a1');
      expect(r.tipo, TipoResultado.acaoIndisponivel);
      verifyNever(() => inscricoes.salvar(any()));
    });

    test('nova inscrição é gravada e confirmada com a mensagem padrão',
        () async {
      when(() => acoes.buscarPorId('a1')).thenAnswer((_) async => acaoAberta);
      when(() => inscricoes.buscar('a1', 'u1')).thenAnswer((_) async => null);

      final r = await service.inscrever(usuarioId: 'u1', acaoId: 'a1');

      expect(r.tipo, TipoResultado.confirmada);
      expect(
        r.mensagem,
        'Inscrição confirmada! Você está inscrito no Mutirão de limpeza, '
        'sábado, 21/11/2026, às 09:30.',
      );
      verify(() => inscricoes.salvar(any())).called(1);
    });

    test('segunda tentativa informa que já está registrada, sem duplicar',
        () async {
      when(() => acoes.buscarPorId('a1')).thenAnswer((_) async => acaoAberta);
      when(() => inscricoes.buscar('a1', 'u1'))
          .thenAnswer((_) async => inscricaoComStatus(StatusInscricao.ativa));

      final r = await service.inscrever(usuarioId: 'u1', acaoId: 'a1');

      expect(r.tipo, TipoResultado.jaRegistrada);
      expect(r.mensagem,
          'Participação já registrada. Você já está inscrito nesta ação.');
      verifyNever(() => inscricoes.salvar(any()));
    });

    test('inscrição cancelada é reativada', () async {
      when(() => acoes.buscarPorId('a1')).thenAnswer((_) async => acaoAberta);
      when(() => inscricoes.buscar('a1', 'u1')).thenAnswer(
          (_) async => inscricaoComStatus(StatusInscricao.cancelada));

      final r = await service.inscrever(usuarioId: 'u1', acaoId: 'a1');

      expect(r.tipo, TipoResultado.reativada);
      final gravada =
          verify(() => inscricoes.salvar(captureAny())).captured.single
              as Inscricao;
      expect(gravada.status, StatusInscricao.ativa);
    });

    test('falha técnica mostra mensagem sem detalhe técnico', () async {
      when(() => acoes.buscarPorId('a1')).thenThrow(Exception('erro interno'));

      final r = await service.inscrever(usuarioId: 'u1', acaoId: 'a1');

      expect(r.tipo, TipoResultado.falha);
      expect(r.mensagem, InscricaoService.msgFalha);
      expect(r.mensagem, isNot(contains('erro interno')));
    });
  });

  group('cancelar', () {
    test('inscrição ativa vira cancelada, sem apagar', () async {
      when(() => inscricoes.buscar('a1', 'u1'))
          .thenAnswer((_) async => inscricaoComStatus(StatusInscricao.ativa));

      final r = await service.cancelar(usuarioId: 'u1', acaoId: 'a1');

      expect(r.tipo, TipoResultado.cancelada);
      final gravada =
          verify(() => inscricoes.salvar(captureAny())).captured.single
              as Inscricao;
      expect(gravada.status, StatusInscricao.cancelada);
      expect(gravada.usuarioId, 'u1');
    });

    test('sem inscrição ativa não grava nada', () async {
      when(() => inscricoes.buscar('a1', 'u1')).thenAnswer((_) async => null);

      final r = await service.cancelar(usuarioId: 'u1', acaoId: 'a1');

      expect(r.tipo, TipoResultado.inscricaoNaoEncontrada);
      verifyNever(() => inscricoes.salvar(any()));
    });

    test('só mexe na inscrição do próprio usuário', () async {
      when(() => inscricoes.buscar('a1', 'u2')).thenAnswer((_) async => null);

      await service.cancelar(usuarioId: 'u2', acaoId: 'a1');

      verify(() => inscricoes.buscar('a1', 'u2')).called(1);
      verifyNever(() => inscricoes.buscar('a1', 'u1'));
    });
  });
}