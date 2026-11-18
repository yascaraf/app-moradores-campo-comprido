import 'package:flutter_test/flutter_test.dart';
import 'package:app_moradores_campo_comprido/domain/validacoes.dart';

void main() {
  group('e-mail', () {
    test('aceita e-mail válido', () {
      expect(Validacoes.email('ana@exemplo.com'), isNull);
    });
    test('recusa vazio e formato inválido, com orientação', () {
      expect(Validacoes.email(''), contains('Preencha'));
      expect(Validacoes.email('ana@'), contains('inválido'));
    });
  });

  group('senha', () {
    test('recusa menos de 8 caracteres', () {
      expect(Validacoes.senha('1234567'), isNotNull);
    });
    test('aceita 8 caracteres ou mais', () {
      expect(Validacoes.senha('12345678'), isNull);
    });
  });

  group('texto livre', () {
    test('campo vazio indica qual campo falta', () {
      expect(Validacoes.textoLivre('  ', 'Título', 100), contains('Título'));
    });
    test('recusa texto acima do limite', () {
      final longo = 'a' * 101;
      expect(Validacoes.textoLivre(longo, 'Título', 100), isNotNull);
    });
    test("aceita aspas e ' OR '1'='1 como texto comum", () {
      expect(
          Validacoes.textoLivre(
              "Mutirão \"limpa\" ' OR '1'='1", 'Título', 100),
          isNull);
    });
    test('rejeita marcação de script', () {
      expect(Validacoes.textoLivre('<script>alert(1)</script>', 'Título', 100),
          isNotNull);
    });
  });

  group('data futura', () {
    final agora = DateTime(2026, 11, 17, 12);
    test('aceita data futura', () {
      expect(
          Validacoes.dataFutura(DateTime(2026, 11, 20), agora: agora), isNull);
    });
    test('recusa data passada ou ausente', () {
      expect(Validacoes.dataFutura(DateTime(2026, 11, 1), agora: agora),
          isNotNull);
      expect(Validacoes.dataFutura(null, agora: agora), isNotNull);
    });
  });
}