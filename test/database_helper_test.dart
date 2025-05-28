import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../lib/Servicios/database_helper.dart';
import '../lib/Modelos/transaccion.dart';
import '../lib/Modelos/categoria.dart';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('insertar, obtener y eliminar transacción', () async {
    final dbHelper = DatabaseHelper();
    final trans = Transaccion(
      id: 'test-id',
      tipo: 'ingreso',
      monto: 123.45,
      fecha: DateTime(2025, 5, 28),
      descripcion: 'Test transacción',
      categoria: Categoria(nombre: 'TestCat', tipo: 'ingreso', icono: '💰'),
    );
    await dbHelper.insertTransaccion(trans);
    final transList = await dbHelper.getTransacciones();
    expect(transList.any((t) => t.id == 'test-id'), isTrue);
    await dbHelper.deleteTransaccion('test-id');
    final afterDelete = await dbHelper.getTransacciones();
    expect(afterDelete.any((t) => t.id == 'test-id'), isFalse);
  });

  test('actualizar transacción', () async {
    final dbHelper = DatabaseHelper();
    final trans = Transaccion(
      id: 'update-id',
      tipo: 'egreso',
      monto: 50.0,
      fecha: DateTime(2025, 5, 28),
      descripcion: 'Original',
      categoria: Categoria(nombre: 'Cat', tipo: 'egreso', icono: '🍔'),
    );
    await dbHelper.insertTransaccion(trans);
    final updated = Transaccion(
      id: 'update-id',
      tipo: 'egreso',
      monto: 75.0,
      fecha: DateTime(2025, 5, 29),
      descripcion: 'Actualizado',
      categoria: Categoria(nombre: 'Cat', tipo: 'egreso', icono: '🍔'),
    );
    await dbHelper.updateTransaccion(updated);
    final list = await dbHelper.getTransacciones();
    final found = list.firstWhere((t) => t.id == 'update-id');
    expect(found.monto, 75.0);
    expect(found.descripcion, 'Actualizado');
    await dbHelper.deleteTransaccion('update-id');
  });

  test('eliminar todas las transacciones', () async {
    final dbHelper = DatabaseHelper();
    await dbHelper.insertTransaccion(Transaccion(
      id: 'delall-1',
      tipo: 'ingreso',
      monto: 10.0,
      fecha: DateTime.now(),
      descripcion: 'A',
      categoria: Categoria(nombre: 'A', tipo: 'ingreso', icono: 'A'),
    ));
    await dbHelper.insertTransaccion(Transaccion(
      id: 'delall-2',
      tipo: 'egreso',
      monto: 20.0,
      fecha: DateTime.now(),
      descripcion: 'B',
      categoria: Categoria(nombre: 'B', tipo: 'egreso', icono: 'B'),
    ));
    await dbHelper.deleteAllTransacciones();
    final list = await dbHelper.getTransacciones();
    expect(list, isEmpty);
  });

  test('getTransaccionesPorAnio solo devuelve del año correcto', () async {
    final dbHelper = DatabaseHelper();
    await dbHelper.insertTransaccion(Transaccion(
      id: 'anio-2024',
      tipo: 'ingreso',
      monto: 1.0,
      fecha: DateTime(2024, 1, 1),
      descripcion: '2024',
      categoria: Categoria(nombre: 'A', tipo: 'ingreso', icono: 'A'),
    ));
    await dbHelper.insertTransaccion(Transaccion(
      id: 'anio-2025',
      tipo: 'egreso',
      monto: 2.0,
      fecha: DateTime(2025, 1, 1),
      descripcion: '2025',
      categoria: Categoria(nombre: 'B', tipo: 'egreso', icono: 'B'),
    ));
    final list2024 = await dbHelper.getTransaccionesPorAnio(2024);
    expect(list2024.any((t) => t.id == 'anio-2024'), isTrue);
    expect(list2024.any((t) => t.id == 'anio-2025'), isFalse);
    final list2025 = await dbHelper.getTransaccionesPorAnio(2025);
    expect(list2025.any((t) => t.id == 'anio-2025'), isTrue);
    expect(list2025.any((t) => t.id == 'anio-2024'), isFalse);
    await dbHelper.deleteTransaccion('anio-2024');
    await dbHelper.deleteTransaccion('anio-2025');
  });
}
