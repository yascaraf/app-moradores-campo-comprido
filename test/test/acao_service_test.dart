import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_moradores_campo_comprido/domain/acao_service.dart';
import 'package:app_moradores_campo_comprido/domain/entidades.dart';
import 'package:app_moradores_campo_comprido/domain/repositorios.dart';

class AcaoRepoMock extends Mock implements AcaoRepositorio {}

Acao _acao(String id, DateTime data,
        {StatusAcao status = StatusAcao.aberta}) =>
    Acao(
      id: id,
      titulo: 'Ação $id',
      descricao: 'Descrição',
      dataHora: data,
      local: 'Local',
      status: status,
    );

void main() {
  late AcaoRepoMock repositorio;
  late AcaoService service;

  setUp(() {
    repositorio = AcaoRepoMock();
    service = AcaoService(acoes: repositorio);
  });

  test('com 3 abertas e 1 encerrada, mostra as 3 da mais próxima à mais distante',
      () async {
    when(() => repositorio.listar()).thenAnswer((_) async => [
          _acao('c', DateTime(2026, 12, 12)),
          _acao('x', DateTime(2026, 11, 10), status: StatusAcao.encerrada),
          _acao('a', DateTime(2026, 11, 28)),
          _acao('b', DateTime(2026, 12, 5)),
        ]);

    final resultado = await service.listarAbertas();

    expect(resultado.map((acao) => acao.id).toList(), ['a', 'b', 'c']);
  });

  test('ação cancelada não aparece na lista', () async {
    when(() => repositorio.listar()).thenAnswer((_) async => [
          _acao('a', DateTime(2026, 11, 28)),
          _acao('z', DateTime(2026, 11, 29), status: StatusAcao.cancelada),
        ]);

    final resultado = await service.listarAbertas();

    expect(resultado.map((acao) => acao.id).toList(), ['a']);
  });

  test('sem ações devolve lista vazia', () async {
    when(() => repositorio.listar()).thenAnswer((_) async => []);

    expect(await service.listarAbertas(), isEmpty);
  });
}