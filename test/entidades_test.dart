import 'package:flutter_test/flutter_test.dart';
import 'package:app_moradores_campo_comprido/domain/entidades.dart';

void main() {
  group('Unitário: entidades', () {
    test('id composto junta ação e usuário', () {
      expect(Inscricao.idComposto('a1', 'u1'), 'a1_u1');
    });

    test('o id da inscrição usa o id composto', () {
      final inscricao = Inscricao(
        acaoId: 'a1',
        usuarioId: 'u1',
        dataInscricao: DateTime(2026, 11, 18),
      );
      expect(inscricao.id, 'a1_u1');
    });

    test('inscrição nova nasce ativa', () {
      final inscricao = Inscricao(
        acaoId: 'a1',
        usuarioId: 'u1',
        dataInscricao: DateTime(2026, 11, 18),
      );
      expect(inscricao.status, StatusInscricao.ativa);
    });

    test('ação nova nasce aberta', () {
      final acao = Acao(
        id: 'a1',
        titulo: 'Mutirão',
        descricao: 'Limpeza',
        dataHora: DateTime(2026, 11, 21),
        local: 'Praça',
      );
      expect(acao.status, StatusAcao.aberta);
    });

    test('usuário novo nasce com perfil morador', () {
      const usuario = Usuario(id: 'u1', nome: 'Ana', email: 'ana@exemplo.com');
      expect(usuario.perfil, Perfil.morador);
    });
  });
}