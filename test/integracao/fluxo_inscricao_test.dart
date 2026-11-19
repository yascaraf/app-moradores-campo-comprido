import 'package:flutter_test/flutter_test.dart';
import 'package:app_moradores_campo_comprido/data/repositorios_em_memoria.dart';
import 'package:app_moradores_campo_comprido/domain/entidades.dart';
import 'package:app_moradores_campo_comprido/domain/inscricao_service.dart';

void main() {
  late AcaoRepositorioEmMemoria acoes;
  late InscricaoRepositorioEmMemoria inscricoes;
  late InscricaoService service;

  final acaoAberta = Acao(
    id: 'a1',
    titulo: 'Mutirão de limpeza',
    descricao: 'Limpeza da praça',
    dataHora: DateTime(2026, 11, 21, 9, 30),
    local: 'Praça central',
  );

  setUp(() {
    acoes = AcaoRepositorioEmMemoria();
    inscricoes = InscricaoRepositorioEmMemoria();
    acoes.adicionar(acaoAberta);
    service = InscricaoService(
      acoes: acoes,
      inscricoes: inscricoes,
      agora: () => DateTime(2026, 11, 18, 10),
    );
  });

  group('Integração: fluxo de inscrição (serviço + repositórios)', () {
    test('inscrever, repetir, cancelar e reinscrever usa sempre o mesmo registro',
        () async {
      var r = await service.inscrever(usuarioId: 'u1', acaoId: 'a1');
      expect(r.tipo, TipoResultado.confirmada);
      expect(inscricoes.total, 1);

      r = await service.inscrever(usuarioId: 'u1', acaoId: 'a1');
      expect(r.tipo, TipoResultado.jaRegistrada);
      expect(inscricoes.total, 1); // não duplicou

      r = await service.cancelar(usuarioId: 'u1', acaoId: 'a1');
      expect(r.tipo, TipoResultado.cancelada);
      var guardada = await inscricoes.buscar('a1', 'u1');
      expect(guardada?.status, StatusInscricao.cancelada);
      expect(inscricoes.total, 1); // cancelar não apagou

      r = await service.inscrever(usuarioId: 'u1', acaoId: 'a1');
      expect(r.tipo, TipoResultado.reativada);
      guardada = await inscricoes.buscar('a1', 'u1');
      expect(guardada?.status, StatusInscricao.ativa);
      expect(inscricoes.total, 1); // reativou o mesmo documento
    });

    test('dois moradores na mesma ação não interferem um no outro', () async {
      await service.inscrever(usuarioId: 'u1', acaoId: 'a1');
      await service.inscrever(usuarioId: 'u2', acaoId: 'a1');
      expect(inscricoes.total, 2);

      await service.cancelar(usuarioId: 'u1', acaoId: 'a1');

      final doU1 = await inscricoes.buscar('a1', 'u1');
      final doU2 = await inscricoes.buscar('a1', 'u2');
      expect(doU1?.status, StatusInscricao.cancelada);
      expect(doU2?.status, StatusInscricao.ativa);
    });

    test('ação encerrada não recebe inscrição', () async {
      acoes.adicionar(Acao(
        id: 'a2',
        titulo: 'Feira antiga',
        descricao: 'Encerrada',
        dataHora: DateTime(2026, 11, 10),
        local: 'Salão',
        status: StatusAcao.encerrada,
      ));

      final r = await service.inscrever(usuarioId: 'u1', acaoId: 'a2');

      expect(r.tipo, TipoResultado.acaoIndisponivel);
      expect(inscricoes.total, 0);
    });

    test('sem login nada é gravado', () async {
      final r = await service.inscrever(usuarioId: null, acaoId: 'a1');

      expect(r.tipo, TipoResultado.semLogin);
      expect(inscricoes.total, 0);
    });
  });
}