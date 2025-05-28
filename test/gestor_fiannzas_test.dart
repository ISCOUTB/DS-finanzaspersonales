import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../lib/Servicios/gestor_finanzas.dart';
import '../lib/Modelos/transaccion.dart';
import '../lib/Modelos/categoria.dart';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('agregar, cargar y eliminar transacción', () async {
    final gestor = GestorFinanzas();
    final trans = Transaccion(
      id: 'test-gestor',
      tipo: 'ingreso',
      monto: 100.0,
      fecha: DateTime(2025, 5, 28),
      descripcion: 'Test gestor',
      categoria: Categoria(nombre: 'TestCat', tipo: 'ingreso', icono: '💰'),
    );
    await gestor.agregarTransaccion(trans);
    await gestor.cargarTransacciones();
    expect(gestor.transacciones.any((t) => t.id == 'test-gestor'), isTrue);
    await gestor.eliminarTransaccion('test-gestor');
    await gestor.cargarTransacciones();
    expect(gestor.transacciones.any((t) => t.id == 'test-gestor'), isFalse);
  });

  test('actualizar y editar transacción', () async {
    final gestor = GestorFinanzas();
    final trans = Transaccion(
      id: 'edit-gestor',
      tipo: 'egreso',
      monto: 50.0,
      fecha: DateTime(2025, 5, 28),
      descripcion: 'Original',
      categoria: Categoria(nombre: 'Cat', tipo: 'egreso', icono: '🍔'),
    );
    await gestor.agregarTransaccion(trans);
    final updated = Transaccion(
      id: 'edit-gestor',
      tipo: 'egreso',
      monto: 75.0,
      fecha: DateTime(2025, 5, 29),
      descripcion: 'Actualizado',
      categoria: Categoria(nombre: 'Cat', tipo: 'egreso', icono: '🍔'),
    );
    await gestor.actualizarTransaccion(updated);
    await gestor.cargarTransacciones();
    final found = gestor.transacciones.firstWhere((t) => t.id == 'edit-gestor');
    expect(found.monto, 75.0);
    expect(found.descripcion, 'Actualizado');
    // Prueba editarTransaccion
    final editado = Transaccion(
      id: 'edit-gestor',
      tipo: 'egreso',
      monto: 99.0,
      fecha: DateTime(2025, 5, 30),
      descripcion: 'Editado',
      categoria: Categoria(nombre: 'Cat', tipo: 'egreso', icono: '🍔'),
    );
    await gestor.editarTransaccion('edit-gestor', editado);
    expect(gestor.transacciones.firstWhere((t) => t.id == 'edit-gestor').monto, 99.0);
    await gestor.eliminarTransaccion('edit-gestor');
  });

  test('obtenerPorTipo, filtrarPorCategoria, calcularTotal y desglosePorCategoria', () async {
    final gestor = GestorFinanzas();
    final t1 = Transaccion(
      id: 'tipo-1',
      tipo: 'ingreso',
      monto: 10.0,
      fecha: DateTime.now(),
      descripcion: 'A',
      categoria: Categoria(nombre: 'CatA', tipo: 'ingreso', icono: 'A'),
    );
    final t2 = Transaccion(
      id: 'tipo-2',
      tipo: 'egreso',
      monto: 20.0,
      fecha: DateTime.now(),
      descripcion: 'B',
      categoria: Categoria(nombre: 'CatB', tipo: 'egreso', icono: 'B'),
    );
    await gestor.agregarTransaccion(t1);
    await gestor.agregarTransaccion(t2);
    await gestor.cargarTransacciones();
    expect(gestor.obtenerPorTipo('ingreso').any((t) => t.id == 'tipo-1'), isTrue);
    expect(gestor.filtrarPorCategoria('CatA').any((t) => t.id == 'tipo-1'), isTrue);
    expect(gestor.calcularTotal('ingreso'), greaterThanOrEqualTo(10.0));
    expect(gestor.desglosePorCategoria('ingreso')['CatA'], greaterThanOrEqualTo(10.0));
    await gestor.eliminarTransaccion('tipo-1');
    await gestor.eliminarTransaccion('tipo-2');
  });

  test('obtenerTransaccionesFiltradas por día, semana, mes, año', () async {
    final gestor = GestorFinanzas();
    final now = DateTime.now();
    final t1 = Transaccion(
      id: 'filtro-dia',
      tipo: 'ingreso',
      monto: 1.0,
      fecha: now,
      descripcion: 'Hoy',
      categoria: Categoria(nombre: 'Cat', tipo: 'ingreso', icono: 'C'),
    );
    await gestor.agregarTransaccion(t1);
    await gestor.cargarTransacciones();
    expect(gestor.obtenerTransaccionesFiltradas('día').any((t) => t.id == 'filtro-dia'), isTrue);
    expect(gestor.obtenerTransaccionesFiltradas('semana').any((t) => t.id == 'filtro-dia'), isTrue);
    expect(gestor.obtenerTransaccionesFiltradas('mes').any((t) => t.id == 'filtro-dia'), isTrue);
    expect(gestor.obtenerTransaccionesFiltradas('año').any((t) => t.id == 'filtro-dia'), isTrue);
    await gestor.eliminarTransaccion('filtro-dia');
  });

  test('cargarTransaccionesPorAnio carga solo las del año indicado', () async {
    final gestor = GestorFinanzas();
    final t2024 = Transaccion(
      id: 'anio-2024',
      tipo: 'ingreso',
      monto: 1.0,
      fecha: DateTime(2024, 1, 1),
      descripcion: '2024',
      categoria: Categoria(nombre: 'A', tipo: 'ingreso', icono: 'A'),
    );
    final t2025 = Transaccion(
      id: 'anio-2025',
      tipo: 'egreso',
      monto: 2.0,
      fecha: DateTime(2025, 1, 1),
      descripcion: '2025',
      categoria: Categoria(nombre: 'B', tipo: 'egreso', icono: 'B'),
    );
    await gestor.agregarTransaccion(t2024);
    await gestor.agregarTransaccion(t2025);
    await gestor.cargarTransaccionesPorAnio(2024);
    expect(gestor.transacciones.any((t) => t.id == 'anio-2024'), isTrue);
    expect(gestor.transacciones.any((t) => t.id == 'anio-2025'), isFalse);
    await gestor.cargarTransaccionesPorAnio(2025);
    expect(gestor.transacciones.any((t) => t.id == 'anio-2025'), isTrue);
    expect(gestor.transacciones.any((t) => t.id == 'anio-2024'), isFalse);
    await gestor.eliminarTransaccion('anio-2024');
    await gestor.eliminarTransaccion('anio-2025');
  });
}
