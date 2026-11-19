import 'package:flutter_test/flutter_test.dart';
import 'package:app_moradores_campo_comprido/data/repositorios_em_memoria.dart';
import 'package:app_moradores_campo_comprido/domain/entidades.dart';
import 'package:app_moradores_campo_comprido/domain/inscricao_service.dart';

void main() {
  late InscricaoService service;

  setUp(() {
    final acoes = AcaoRepositorioEmMemoria();
    acoes.adicionar(Acao(
      id: 'a1',
      titulo: 'Mutirão',
      descricao: 'Limpeza',
      dataHora: DateTime(2026, 12, 1, 9),
      local: 'Praça',
    ));
    service = InscricaoService(
      acoes: acoes,
      inscricoes: InscricaoRepositorioEmMemoria(),
    );
  });

  test('sem inscrição devolve false', () async {
    expect(
      await service.temInscricaoAtiva(usuarioId: 'u1', acaoId: 'a1'),
      isFalse,
    );
  });

  test('com inscrição ativa devolve true', () async {
    await service.inscrever(usuarioId: 'u1', acaoId: 'a1');
    expect(
      await service.temInscricaoAtiva(usuarioId: 'u1', acaoId: 'a1'),
      isTrue,
    );
  });

  test('depois de cancelar devolve false', () async {
    await service.inscrever(usuarioId: 'u1', acaoId: 'a1');
    await service.cancelar(usuarioId: 'u1', acaoId: 'a1');
    expect(
      await service.temInscricaoAtiva(usuarioId: 'u1', acaoId: 'a1'),
      isFalse,
    );
  });

  test('sem login devolve false', () async {
    expect(
      await service.temInscricaoAtiva(usuarioId: null, acaoId: 'a1'),
      isFalse,
    );
  });
}
