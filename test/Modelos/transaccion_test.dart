import 'package:flutter_test/flutter_test.dart';
import 'package:finanse_tracker/Modelos/transaccion.dart';
import 'package:finanse_tracker/Modelos/categoria.dart';

void main() {
  group('Transaccion', () {
    final categoria = Categoria(
      nombre: 'Salario',
      tipo: 'ingreso',
      icono: '💰',
    );

    test('Constructor asigna correctamente los valores', () {
      final transaccion = Transaccion(
        id: '1',
        tipo: 'ingreso',
        monto: 1000.0,
        fecha: DateTime(2024, 5, 26),
        categoria: categoria,
        descripcion: 'Pago mensual',
      );

      expect(transaccion.id, '1');
      expect(transaccion.tipo, 'ingreso');
      expect(transaccion.monto, 1000.0);
      expect(transaccion.fecha, DateTime(2024, 5, 26));
      expect(transaccion.categoria, categoria);
      expect(transaccion.descripcion, 'Pago mensual');
    });

    test('toJson retorna un mapa válido', () {
      final transaccion = Transaccion(
        id: '2',
        tipo: 'egreso',
        monto: 250.5,
        fecha: DateTime(2024, 5, 20, 10, 30),
        categoria: categoria,
        descripcion: 'Compra',
      );

      final json = transaccion.toJson();

      expect(json, isA<Map<String, dynamic>>());
      expect(json['id'], '2');
      expect(json['tipo'], 'egreso');
      expect(json['monto'], 250.5);
      expect(json['fecha'], DateTime(2024, 5, 20, 10, 30).toIso8601String());
      expect(json['categoria'], categoria.toJson());
      expect(json['descripcion'], 'Compra');
    });

    test('fromJson crea una instancia válida', () {
      final json = {
        'id': '3',
        'tipo': 'ingreso',
        'monto': 500.0,
        'fecha': '2024-05-25T12:00:00.000',
        'categoria': {
          'nombre': 'Premio',
          'tipo': 'ingreso',
          'icono': '🏆',
        },
        'descripcion': 'Premio recibido',
      };

      final transaccion = Transaccion.fromJson(json);

      expect(transaccion.id, '3');
      expect(transaccion.tipo, 'ingreso');
      expect(transaccion.monto, 500.0);
      expect(transaccion.fecha, DateTime.parse('2024-05-25T12:00:00.000'));
      expect(transaccion.categoria.nombre, 'Premio');
      expect(transaccion.categoria.tipo, 'ingreso');
      expect(transaccion.categoria.icono, '🏆');
      expect(transaccion.descripcion, 'Premio recibido');
    });

    test('toMap retorna un mapa válido', () {
      final transaccion = Transaccion(
        id: '4',
        tipo: 'egreso',
        monto: 75.0,
        fecha: DateTime(2024, 5, 10),
        categoria: categoria,
        descripcion: 'Transporte',
      );

      final map = transaccion.toMap();

      expect(map, isA<Map<String, dynamic>>());
      expect(map['id'], '4');
      expect(map['tipo'], 'egreso');
      expect(map['monto'], 75.0);
      expect(map['descripcion'], 'Transporte');
      expect(map['fecha'], DateTime(2024, 5, 10).toIso8601String());
      expect(map['categoria'], categoria);
    });
  });
}