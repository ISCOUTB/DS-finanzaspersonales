import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:finanse_tracker/Servicios/gestor_finanzas.dart';
import 'package:finanse_tracker/Modelos/transaccion.dart';
import 'package:finanse_tracker/Modelos/categoria.dart';
import 'package:finanse_tracker/Servicios/database_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('GestorFinanzas Tests', () {
    late GestorFinanzas gestorFinanzas;
    late DatabaseHelper dbHelper;
    late Database testDatabase;
    late List<Transaccion> transaccionesPrueba;

    setUp(() async {
      final databasePath = inMemoryDatabasePath;
      testDatabase = await openDatabase(
        databasePath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE transacciones(
              id TEXT PRIMARY KEY,
              tipo TEXT,
              monto REAL,
              fecha TEXT,
              descripcion TEXT,
              categoria_nombre TEXT,
              categoria_tipo TEXT,
              categoria_icono TEXT
            )
          ''');
        },
      );

      dbHelper = DatabaseHelper();
      dbHelper.setTestDatabase(testDatabase);
      gestorFinanzas = GestorFinanzas();

      transaccionesPrueba = [
        Transaccion(
          id: '1',
          tipo: 'ingreso',
          monto: 1000.0,
          fecha: DateTime(2023, 12, 1),
          descripcion: 'Salario mensual',
          categoria: Categoria(nombre: 'Salario', tipo: 'ingreso', icono: '💰'),
        ),
        Transaccion(
          id: '2',
          tipo: 'egreso',
          monto: 500.0,
          fecha: DateTime(2023, 12, 2),
          descripcion: 'Compras del supermercado',
          categoria: Categoria(
            nombre: 'Alimentación',
            tipo: 'egreso',
            icono: '🍔',
          ),
        ),
        Transaccion(
          id: '3',
          tipo: 'egreso',
          monto: 200.0,
          fecha: DateTime(2023, 12, 3),
          descripcion: 'Gasolina',
          categoria: Categoria(
            nombre: 'Transporte',
            tipo: 'egreso',
            icono: '🚗',
          ),
        ),
      ];

      for (var transaccion in transaccionesPrueba) {
        await testDatabase.insert('transacciones', {
          'id': transaccion.id,
          'tipo': transaccion.tipo,
          'monto': transaccion.monto,
          'fecha': transaccion.fecha.toIso8601String(),
          'descripcion': transaccion.descripcion,
          'categoria_nombre': transaccion.categoria.nombre,
          'categoria_tipo': transaccion.categoria.tipo,
          'categoria_icono': transaccion.categoria.icono,
        });
      }
    });

    tearDown(() async {
      await testDatabase.close();
      dbHelper.clearTestDatabase();
      gestorFinanzas.transacciones.clear();
    });

    group('Cargar Transacciones Tests', () {
      test('debería cargar transacciones exitosamente', () async {
        await gestorFinanzas.cargarTransacciones();
        expect(gestorFinanzas.transacciones.length, 3);
        expect(gestorFinanzas.transacciones.any((t) => t.id == '1'), isTrue);
      });

      test('cargarTransacciones maneja errores', () async {
        await testDatabase.close(); // Forzar error
        await gestorFinanzas.cargarTransacciones();
        expect(gestorFinanzas.transacciones, isEmpty);
      });

      test('debería cargar transacciones por año correctamente', () async {
        await gestorFinanzas.cargarTransaccionesPorAnio(2023);
        expect(gestorFinanzas.transacciones.length, 3);
        expect(
          gestorFinanzas.transacciones.every((t) => t.fecha.year == 2023),
          isTrue,
        );
      });

      test('cargarTransaccionesPorAnio maneja errores', () async {
        await testDatabase.close(); // Forzar error
        await gestorFinanzas.cargarTransaccionesPorAnio(2023);
        expect(gestorFinanzas.transacciones, isEmpty);
      });
    });

    group('Filtros y Consultas Tests', () {
      setUp(() async {
        await gestorFinanzas.cargarTransacciones();
      });

      test('obtenerPorTipo debería filtrar por tipo correctamente', () {
        final ingresos = gestorFinanzas.obtenerPorTipo('ingreso');
        final egresos = gestorFinanzas.obtenerPorTipo('egreso');
        expect(ingresos.length, 1);
        expect(egresos.length, 2);
      });

      test(
        'filtrarPorCategoria debería filtrar por categoría correctamente',
        () {
          final alimentacion = gestorFinanzas.filtrarPorCategoria(
            'Alimentación',
          );
          final salario = gestorFinanzas.filtrarPorCategoria('Salario');
          expect(alimentacion.length, 1);
          expect(salario.length, 1);
        },
      );

      test(
        'calcularTotal debería calcular el total por tipo correctamente',
        () {
          final totalIngresos = gestorFinanzas.calcularTotal('ingreso');
          final totalEgresos = gestorFinanzas.calcularTotal('egreso');
          expect(totalIngresos, 1000.0);
          expect(totalEgresos, 700.0);
        },
      );

      test(
        'desglosePorCategoria debería agrupar por categoría correctamente',
        () {
          final desgloseIngresos = gestorFinanzas.desglosePorCategoria(
            'ingreso',
          );
          final desgloseEgresos = gestorFinanzas.desglosePorCategoria('egreso');
          expect(desgloseIngresos['Salario'], 1000.0);
          expect(desgloseEgresos['Alimentación'], 500.0);
          expect(desgloseEgresos['Transporte'], 200.0);
        },
      );
    });

    group('Filtros por Fecha Tests', () {
      setUp(() async {
        final ahora = DateTime.now();
        await testDatabase.insert('transacciones', {
          'id': 'hoy',
          'tipo': 'ingreso',
          'monto': 100.0,
          'fecha': ahora.toIso8601String(),
          'descripcion': 'Hoy',
          'categoria_nombre': 'Test',
          'categoria_tipo': 'ingreso',
          'categoria_icono': '💡',
        });

        await gestorFinanzas.cargarTransacciones();
      });

      test('obtenerTransaccionesFiltradas debería filtrar por día', () {
        final transaccionesHoy = gestorFinanzas.obtenerTransaccionesFiltradas(
          'día',
        );
        expect(transaccionesHoy.length, 1);
      });

      test('obtenerTransaccionesFiltradas debería filtrar por mes', () {
        final transaccionesMes = gestorFinanzas.obtenerTransaccionesFiltradas(
          'mes',
        );
        expect(transaccionesMes.length, greaterThanOrEqualTo(1));
      });

      test('obtenerTransaccionesFiltradas debería filtrar por año', () {
        final transaccionesAnio = gestorFinanzas.obtenerTransaccionesFiltradas(
          'año',
        );
        expect(transaccionesAnio.length, greaterThanOrEqualTo(1));
      });

      test(
        'obtenerTransaccionesFiltradas debería devolver todas con filtro desconocido',
        () {
          final todas = gestorFinanzas.obtenerTransaccionesFiltradas(
            'filtro_inexistente',
          );
          expect(todas.length, gestorFinanzas.transacciones.length);
        },
      );
    });

    group('Operaciones CRUD Tests', () {
      late Transaccion nuevaTransaccion;

      setUp(() async {
        await gestorFinanzas.cargarTransacciones();
        nuevaTransaccion = Transaccion(
          id: 'nueva',
          tipo: 'ingreso',
          monto: 150.0,
          fecha: DateTime.now(),
          descripcion: 'Nueva',
          categoria: Categoria(nombre: 'Test', tipo: 'ingreso', icono: '💡'),
        );
      });

      test('agregarTransaccion debería añadir nueva transacción', () async {
        final cantidadInicial = gestorFinanzas.transacciones.length;
        await gestorFinanzas.agregarTransaccion(nuevaTransaccion);
        await gestorFinanzas.cargarTransacciones();
        expect(gestorFinanzas.transacciones.length, cantidadInicial + 1);
      });

      test('actualizarTransaccion debería actualizar existente', () async {
        final transaccionOriginal = gestorFinanzas.transacciones.first;
        final actualizada = Transaccion(
          id: transaccionOriginal.id,
          tipo: 'egreso',
          monto: 999.0,
          fecha: DateTime.now(),
          descripcion: 'Actualizada',
          categoria: Categoria(
            nombre: 'Actualizada',
            tipo: 'egreso',
            icono: '🔄',
          ),
        );

        await gestorFinanzas.actualizarTransaccion(actualizada);
        await gestorFinanzas.cargarTransacciones();
        final t = gestorFinanzas.transacciones.firstWhere(
          (t) => t.id == transaccionOriginal.id,
        );
        expect(t.tipo, 'egreso');
        expect(t.monto, 999.0);
      });

      test('editarTransaccion debería actualizar localmente', () async {
        final transaccionOriginal = gestorFinanzas.transacciones.first;
        final actualizada = Transaccion(
          id: transaccionOriginal.id,
          tipo: 'egreso',
          monto: 999.0,
          fecha: DateTime.now(),
          descripcion: 'Actualizada',
          categoria: Categoria(
            nombre: 'Actualizada',
            tipo: 'egreso',
            icono: '🔄',
          ),
        );

        await gestorFinanzas.editarTransaccion(
          transaccionOriginal.id,
          actualizada,
        );
        final t = gestorFinanzas.transacciones.firstWhere(
          (t) => t.id == transaccionOriginal.id,
        );
        expect(t.tipo, 'egreso');
        expect(t.monto, 999.0);
      });

      test('eliminarTransaccion debería remover transacción', () async {
        final id = gestorFinanzas.transacciones.first.id;
        await gestorFinanzas.eliminarTransaccion(id);
        await gestorFinanzas.cargarTransacciones();
        expect(gestorFinanzas.transacciones.any((t) => t.id == id), isFalse);
      });
    });

    group('Edge Cases Tests', () {
      test('calcularTotal debería devolver 0 para lista vacía', () {
        gestorFinanzas.transacciones.clear();
        expect(gestorFinanzas.calcularTotal('ingreso'), 0.0);
      });

      test(
        'desglosePorCategoria debería devolver mapa vacío para lista vacía',
        () {
          gestorFinanzas.transacciones.clear();
          expect(gestorFinanzas.desglosePorCategoria('ingreso'), isEmpty);
        },
      );

      test(
        'filtrarPorCategoria debería devolver lista vacía para categoría inexistente',
        () async {
          await gestorFinanzas.cargarTransacciones();
          expect(gestorFinanzas.filtrarPorCategoria('Inexistente'), isEmpty);
        },
      );

      test(
        'obtenerPorTipo debería devolver lista vacía para tipo inexistente',
        () async {
          await gestorFinanzas.cargarTransacciones();
          expect(gestorFinanzas.obtenerPorTipo('inexistente'), isEmpty);
        },
      );
    });

    group('Métodos de Utilidad Tests', () {
      test('guardarTransacciones debería ejecutarse sin errores', () async {
        expect(
          () async => await gestorFinanzas.guardarTransacciones(),
          returnsNormally,
        );
      });
    });
  });
}
