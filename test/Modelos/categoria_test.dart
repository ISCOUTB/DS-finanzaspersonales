import 'package:flutter_test/flutter_test.dart';
import 'package:finanse_tracker/Modelos/categoria.dart';

void main() {
  group('Categoria', () {
    test('Constructor asigna correctamente los valores', () {
      final categoria = Categoria(
        nombre: 'Salario',
        tipo: 'ingreso',
        icono: '💰',
      );

      expect(categoria.nombre, 'Salario');
      expect(categoria.tipo, 'ingreso');
      expect(categoria.icono, '💰');
    });

    test('toJson retorna un mapa válido', () {
      final categoria = Categoria(
        nombre: 'Comida',
        tipo: 'egreso',
        icono: '🍔',
      );

      final json = categoria.toJson();

      expect(json, isA<Map<String, dynamic>>());
      expect(json['nombre'], 'Comida');
      expect(json['tipo'], 'egreso');
      expect(json['icono'], '🍔');
    });

    test('fromJson crea una instancia válida', () {
      final json = {
        'nombre': 'Transporte',
        'tipo': 'egreso',
        'icono': '🚌',
      };

      final categoria = Categoria.fromJson(json);

      expect(categoria.nombre, 'Transporte');
      expect(categoria.tipo, 'egreso');
      expect(categoria.icono, '🚌');
    });
  });
}