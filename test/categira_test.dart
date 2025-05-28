import 'package:flutter_test/flutter_test.dart';
import '../lib/Modelos/categoria.dart';

void main() {
  test('Categoria toJson y fromJson funcionan correctamente', () {
    final cat = Categoria(
      nombre: 'TestCat',
      tipo: 'egreso',
      icono: '🍔',
      presupuestoMensual: 500.0,
    );
    final json = cat.toJson();
    expect(json['nombre'], 'TestCat');
    expect(json['tipo'], 'egreso');
    expect(json['icono'], '🍔');
    expect(json['presupuestoMensual'], 500.0);

    final cat2 = Categoria.fromJson(json);
    expect(cat2.nombre, 'TestCat');
    expect(cat2.tipo, 'egreso');
    expect(cat2.icono, '🍔');
    expect(cat2.presupuestoMensual, 500.0);
  });

  test('Categoria fromJson maneja presupuestoMensual nulo', () {
    final json = {
      'nombre': 'SinPresupuesto',
      'tipo': 'ingreso',
      'icono': '💰',
    };
    final cat = Categoria.fromJson(json);
    expect(cat.nombre, 'SinPresupuesto');
    expect(cat.tipo, 'ingreso');
    expect(cat.icono, '💰');
    expect(cat.presupuestoMensual, isNull);
  });
}
