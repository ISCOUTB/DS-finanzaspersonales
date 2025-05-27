import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finanse_tracker/Modelos/transaccion.dart';
import 'package:finanse_tracker/Modelos/categoria.dart';
import 'package:finanse_tracker/Servicios/database_helper.dart';

void main() {
  // Inicializar sqflite para pruebas con FFI
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final dbHelper = DatabaseHelper();

  final testCategoria = Categoria(
    nombre: 'TestCategoria',
    tipo: 'ingreso',
    icono: '💡',
  );

  final testTransaccion = Transaccion(
    id: 'test-id',
    tipo: 'ingreso',
    monto: 123.45,
    fecha: DateTime(2024, 5, 26, 12, 0),
    categoria: Categoria(
      nombre: 'TestCategoria',
      tipo: 'ingreso',
      icono: '💡',
    ),
    descripcion: 'Test transacción',
  );

  setUp(() async {
    await dbHelper.deleteAllTransacciones();
  });

  test('insertTransaccion y getTransacciones funcionan correctamente', () async {
    await dbHelper.insertTransaccion(testTransaccion);
    final transacciones = await dbHelper.getTransacciones();
    expect(transacciones, isNotEmpty);
    final t = transacciones.first;
    expect(t.id, testTransaccion.id);
    expect(t.tipo, testTransaccion.tipo);
    expect(t.monto, testTransaccion.monto);
    expect(t.fecha, testTransaccion.fecha);
    expect(t.categoria.nombre, testTransaccion.categoria.nombre);
    expect(t.descripcion, testTransaccion.descripcion);
  });

  test('updateTransaccion actualiza correctamente', () async {
    await dbHelper.insertTransaccion(testTransaccion);
    final updatedTransaccion = Transaccion(
      id: testTransaccion.id,
      tipo: 'egreso',
      monto: 200.0,
      fecha: DateTime(2024, 5, 27, 10, 0),
      categoria: Categoria(
        nombre: 'OtraCategoria',
        tipo: 'egreso',
        icono: '🛒',
      ),
      descripcion: 'Actualizada',
    );
    await dbHelper.updateTransaccion(updatedTransaccion);
    final transacciones = await dbHelper.getTransacciones();
    expect(transacciones.length, 1);
    final t = transacciones.first;
    expect(t.tipo, 'egreso');
    expect(t.monto, 200.0);
    expect(t.categoria.nombre, 'OtraCategoria');
    expect(t.descripcion, 'Actualizada');
  });

  test('deleteTransaccion elimina correctamente', () async {
    await dbHelper.insertTransaccion(testTransaccion);
    await dbHelper.deleteTransaccion(testTransaccion.id);
    final transacciones = await dbHelper.getTransacciones();
    expect(transacciones, isEmpty);
  });

  test('deleteAllTransacciones elimina todas las transacciones', () async {
    await dbHelper.insertTransaccion(testTransaccion);
    await dbHelper.deleteAllTransacciones();
    final transacciones = await dbHelper.getTransacciones();
    expect(transacciones, isEmpty);
  });

  test('getTransaccionesPorAnio retorna solo las del año indicado', () async {
    final trans2023 = Transaccion(
      id: '2023-id',
      tipo: 'ingreso',
      monto: 50.0,
      fecha: DateTime(2023, 6, 1),
      categoria: testCategoria,
      descripcion: '2023',
    );
    final trans2024 = Transaccion(
      id: '2024-id',
      tipo: 'egreso',
      monto: 75.0,
      fecha: DateTime(2024, 7, 1),
      categoria: testCategoria,
      descripcion: '2024',
    );
    await dbHelper.insertTransaccion(trans2023);
    await dbHelper.insertTransaccion(trans2024);

    final result2023 = await dbHelper.getTransaccionesPorAnio(2023);
    final result2024 = await dbHelper.getTransaccionesPorAnio(2024);

    expect(result2023.length, 1);
    expect(result2023.first.id, '2023-id');
    expect(result2024.length, 1);
    expect(result2024.first.id, '2024-id');
  });
}