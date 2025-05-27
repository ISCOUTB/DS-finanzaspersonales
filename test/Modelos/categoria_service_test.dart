import 'package:flutter_test/flutter_test.dart';
import 'package:finanse_tracker/Modelos/categoria.dart';
import 'package:finanse_tracker/Modelos/categoria_service.dart';

void main() {
  group('CategoriaService', () {
    test('getCategoriasIngresos retorna lista de categorías de ingresos', () {
      final categorias = CategoriaService.getCategoriasIngresos();
      expect(categorias, isA<List<Categoria>>());
      expect(categorias.isNotEmpty, true);
      for (final cat in categorias) {
        expect(cat, isA<Categoria>());
      }
    });

    test('getCategoriasGastos retorna lista de categorías de gastos', () {
      final categorias = CategoriaService.getCategoriasGastos();
      expect(categorias, isA<List<Categoria>>());
      expect(categorias.isNotEmpty, true);
      for (final cat in categorias) {
        expect(cat, isA<Categoria>());
      }
    });

    test('Las categorías de ingresos y gastos no son iguales', () {
      final ingresos = CategoriaService.getCategoriasIngresos();
      final gastos = CategoriaService.getCategoriasGastos();
      expect(ingresos, isNot(equals(gastos)));
    });
  });
}