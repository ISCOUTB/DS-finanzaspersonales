import 'package:flutter_test/flutter_test.dart';
import 'package:finanse_tracker/Modelos/transaccion.dart';
import 'package:finanse_tracker/Modelos/categoria.dart';
import 'package:finanse_tracker/Servicios/gestor_finanzas.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final gestor = GestorFinanzas();

  final categoriaIngreso = Categoria(nombre: 'Salario', tipo: 'ingreso', icono: '💰');
  final categoriaGasto = Categoria(nombre: 'Comida', tipo: 'egreso', icono: '🍔');

  final transIngreso = Transaccion(
    id: '1',
    tipo: 'ingreso',
    monto: 1000.0,
    fecha: DateTime.now(),
    categoria: categoriaIngreso,
    descripcion: 'Pago mensual',
  );

  final transGasto = Transaccion(
    id: '2',
    tipo: 'egreso',
    monto: 200.0,
    fecha: DateTime.now(),
    categoria: categoriaGasto,
    descripcion: 'Almuerzo',
  );

  setUp(() async {
    await gestor.cargarTransacciones();
    for (var t in List<Transaccion>.from(gestor.transacciones)) {
      await gestor.eliminarTransaccion(t.id);
    }
    gestor.transacciones.clear();
  });

  test('agregarTransaccion agrega una transacción', () async {
    await gestor.agregarTransaccion(transIngreso);
    await gestor.cargarTransacciones();
    expect(gestor.transacciones.any((t) => t.id == transIngreso.id), isTrue);
  });

  test('actualizarTransaccion actualiza una transacción', () async {
    await gestor.agregarTransaccion(transIngreso);
    final actualizada = Transaccion(
      id: '1',
      tipo: 'ingreso',
      monto: 1500.0,
      fecha: transIngreso.fecha,
      categoria: categoriaIngreso,
      descripcion: 'Pago actualizado',
    );
    await gestor.actualizarTransaccion(actualizada);
    await gestor.cargarTransacciones();
    final t = gestor.transacciones.firstWhere((t) => t.id == '1');
    expect(t.monto, 1500.0);
    expect(t.descripcion, 'Pago actualizado');
  });

  test('eliminarTransaccion elimina una transacción', () async {
    await gestor.agregarTransaccion(transIngreso);
    await gestor.eliminarTransaccion(transIngreso.id);
    await gestor.cargarTransacciones();
    expect(gestor.transacciones.any((t) => t.id == transIngreso.id), isFalse);
  });

  test('editarTransaccion edita y actualiza la lista interna', () async {
    await gestor.agregarTransaccion(transIngreso);
    final nueva = Transaccion(
      id: '1',
      tipo: 'ingreso',
      monto: 2000.0,
      fecha: transIngreso.fecha,
      categoria: categoriaIngreso,
      descripcion: 'Editada',
    );
    await gestor.editarTransaccion('1', nueva);
    await gestor.cargarTransacciones();
    final t = gestor.transacciones.firstWhere((t) => t.id == '1');
    expect(t.monto, 2000.0);
    expect(t.descripcion, 'Editada');
  });

  test('obtenerPorTipo filtra correctamente', () async {
    await gestor.agregarTransaccion(transIngreso);
    await gestor.agregarTransaccion(transGasto);
    await gestor.cargarTransacciones();
    final ingresos = gestor.obtenerPorTipo('ingreso');
    final egresos = gestor.obtenerPorTipo('egreso');
    expect(ingresos.every((t) => t.tipo == 'ingreso'), isTrue);
    expect(egresos.every((t) => t.tipo == 'egreso'), isTrue);
  });

  test('filtrarPorCategoria filtra correctamente', () async {
    await gestor.agregarTransaccion(transIngreso);
    await gestor.agregarTransaccion(transGasto);
    await gestor.cargarTransacciones();
    final filtradas = gestor.filtrarPorCategoria('Comida');
    expect(filtradas.length, 1);
    expect(filtradas.first.categoria.nombre, 'Comida');
  });

  test('calcularTotal suma correctamente por tipo', () async {
    await gestor.agregarTransaccion(transIngreso);
    await gestor.agregarTransaccion(transGasto);
    await gestor.cargarTransacciones();
    final totalIngresos = gestor.calcularTotal('ingreso');
    final totalEgresos = gestor.calcularTotal('egreso');
    expect(totalIngresos, greaterThan(0));
    expect(totalEgresos, greaterThan(0));
  });

  test('desglosePorCategoria retorna el desglose correcto', () async {
    await gestor.agregarTransaccion(transIngreso);
    await gestor.agregarTransaccion(transGasto);
    await gestor.cargarTransacciones();
    final desglose = gestor.desglosePorCategoria('ingreso');
    expect(desglose.containsKey('Salario'), isTrue);
    expect(desglose['Salario'], transIngreso.monto);
  });

  test('obtenerTransaccionesFiltradas retorna según filtro', () async {
    final now = DateTime.now();
    final oldTrans = Transaccion(
      id: '3',
      tipo: 'ingreso',
      monto: 500.0,
      fecha: now.subtract(const Duration(days: 400)),
      categoria: categoriaIngreso,
      descripcion: 'Antigua',
    );
    await gestor.agregarTransaccion(transIngreso);
    await gestor.agregarTransaccion(oldTrans);
    await gestor.cargarTransacciones();
    final ano = gestor.obtenerTransaccionesFiltradas('año');
    expect(ano.any((t) => t.id == transIngreso.id), isTrue);
    expect(ano.any((t) => t.id == oldTrans.id), isFalse);
  });

  test('cargarTransaccionesPorAnio carga solo las del año indicado', () async {
    final trans2023 = Transaccion(
      id: '2023-id',
      tipo: 'ingreso',
      monto: 100.0,
      fecha: DateTime(DateTime.now().year - 1, 6, 1),
      categoria: categoriaIngreso,
      descripcion: '2023',
    );
    final trans2024 = Transaccion(
      id: '2024-id',
      tipo: 'egreso',
      monto: 200.0,
      fecha: DateTime(DateTime.now().year, 7, 1),
      categoria: categoriaGasto,
      descripcion: '2024',
    );
    await gestor.agregarTransaccion(trans2023);
    await gestor.agregarTransaccion(trans2024);
    await gestor.cargarTransaccionesPorAnio(DateTime.now().year);
    expect(gestor.transacciones.length, 1);
    expect(gestor.transacciones.first.id, '2024-id');
  });
}