import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
//import 'package:sqflite/sqflite.dart';
//import 'package:path/path.dart' as p;

// Importar directamente las clases necesarias
import 'package:finanse_tracker/Servicios/gestor_finanzas.dart';
import 'package:finanse_tracker/Modelos/transaccion.dart';
import 'package:finanse_tracker/Modelos/categoria.dart';
import 'package:finanse_tracker/Servicios/database_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar sqflite para testing
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('GestorFinanzas Tests', () {
    late GestorFinanzas gestorFinanzas;
    late DatabaseHelper dbHelper;
    late Database testDatabase;
    late List<Transaccion> transaccionesPrueba;

    setUp(() async {
      // Crear una base de datos en memoria para testing
      final databasePath = inMemoryDatabasePath;
      testDatabase = await openDatabase(
        databasePath,
        version: 1,
        onCreate: (db, version) async {
          // Crear las tablas necesarias
          await db.execute('''
            CREATE TABLE categorias(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nombre TEXT NOT NULL,
              tipo TEXT NOT NULL CHECK(tipo IN ('ingreso', 'egreso')),
              icono TEXT NOT NULL DEFAULT '📝'
            )
          ''');

          await db.execute('''
            CREATE TABLE transacciones(
              id TEXT PRIMARY KEY,
              monto REAL NOT NULL,
              categoria_id INTEGER NOT NULL,
              tipo TEXT NOT NULL CHECK(tipo IN ('ingreso', 'egreso')),
              fecha INTEGER NOT NULL,
              descripcion TEXT,
              FOREIGN KEY (categoria_id) REFERENCES categorias (id)
            )
          ''');

          // Insertar categorías de prueba
          await db.insert('categorias', {
            'id': 1,
            'nombre': 'Salario',
            'tipo': 'ingreso',
            'icono': '💰'
          });
          await db.insert('categorias', {
            'id': 2,
            'nombre': 'Alimentación',
            'tipo': 'egreso',
            'icono': '🍔'
          });
          await db.insert('categorias', {
            'id': 3,
            'nombre': 'Transporte',
            'tipo': 'egreso',
            'icono': '🚗'
          });
        },
      );

      // Configurar DatabaseHelper con la base de datos de prueba
      dbHelper = DatabaseHelper();
      dbHelper.setTestDatabase(testDatabase);
      
      gestorFinanzas = GestorFinanzas();
      
      // Datos de prueba
      transaccionesPrueba = [
        Transaccion(
          id: '1',
          monto: 1000.0,
          categoria: Categoria(nombre: 'Salario', tipo: 'ingreso', icono: '💰'),
          tipo: 'ingreso',
          fecha: DateTime(2023, 12, 1),
          descripcion: 'Salario mensual',
        ),
        Transaccion(
          id: '2',
          monto: 500.0,
          categoria: Categoria(nombre: 'Alimentación', tipo: 'egreso', icono: '🍔'),
          tipo: 'egreso',
          fecha: DateTime(2023, 12, 2),
          descripcion: 'Compras del supermercado',
        ),
        Transaccion(
          id: '3',
          monto: 200.0,
          categoria: Categoria(nombre: 'Transporte', tipo: 'egreso', icono: '🚗'),
          tipo: 'egreso',
          fecha: DateTime(2023, 12, 3),
          descripcion: 'Gasolina',
        ),
      ];

      // Insertar transacciones de prueba en la base de datos
      for (var transaccion in transaccionesPrueba) {
        await testDatabase.insert('transacciones', {
          'id': transaccion.id,
          'monto': transaccion.monto,
          'categoria_id': transaccion.categoria.nombre == 'Salario' ? 1 : 
                         transaccion.categoria.nombre == 'Alimentación' ? 2 : 3,
          'tipo': transaccion.tipo,
          'fecha': transaccion.fecha.millisecondsSinceEpoch,
          'descripcion': transaccion.descripcion,
        });
      }
    });

    tearDown(() async {
      // Limpiar la base de datos después de cada test
      await testDatabase.delete('transacciones');
      gestorFinanzas.transacciones.clear();
    });

    /*group('Cargar Transacciones Tests', () {
      test('debería cargar transacciones exitosamente', () async {
        // Act
        await gestorFinanzas.cargarTransacciones();

        // Assert
        expect(gestorFinanzas.transacciones.length, equals(3));
        expect(gestorFinanzas.transacciones.any((t) => t.id == '1'), isTrue);
        expect(gestorFinanzas.transacciones.any((t) => t.monto == 1000.0), isTrue);
      });

      test('debería cargar transacciones por año correctamente', () async {
        // Act
        await gestorFinanzas.cargarTransaccionesPorAnio(2023);

        // Assert
        expect(gestorFinanzas.transacciones.length, equals(3));
        expect(gestorFinanzas.transacciones.every((t) => t.fecha.year == 2023), isTrue);
      });
    });

    group('Filtros y Consultas Tests', () {
      setUp(() async {
        await gestorFinanzas.cargarTransacciones();
      });

      test('obtenerPorTipo debería filtrar por tipo correctamente', () {
        // Act
        final ingresos = gestorFinanzas.obtenerPorTipo('ingreso');
        final egresos = gestorFinanzas.obtenerPorTipo('egreso');

        // Assert
        expect(ingresos.length, equals(1));
        expect(ingresos[0].tipo, equals('ingreso'));
        expect(egresos.length, equals(2));
        expect(egresos.every((t) => t.tipo == 'egreso'), isTrue);
      });

      test('filtrarPorCategoria debería filtrar por categoría correctamente', () {
        // Act
        final alimentacion = gestorFinanzas.filtrarPorCategoria('Alimentación');
        final salario = gestorFinanzas.filtrarPorCategoria('Salario');

        // Assert
        expect(alimentacion.length, equals(1));
        expect(alimentacion[0].categoria.nombre, equals('Alimentación'));
        expect(salario.length, equals(1));
        expect(salario[0].categoria.nombre, equals('Salario'));
      });

      test('calcularTotal debería calcular el total por tipo correctamente', () {
        // Act
        final totalIngresos = gestorFinanzas.calcularTotal('ingreso');
        final totalEgresos = gestorFinanzas.calcularTotal('egreso');

        // Assert
        expect(totalIngresos, equals(1000.0));
        expect(totalEgresos, equals(700.0));
      });

      test('desglosePorCategoria debería agrupar por categoría correctamente', () {
        // Act
        final desgloseIngresos = gestorFinanzas.desglosePorCategoria('ingreso');
        final desgloseEgresos = gestorFinanzas.desglosePorCategoria('egreso');

        // Assert
        expect(desgloseIngresos['Salario'], equals(1000.0));
        expect(desgloseEgresos['Alimentación'], equals(500.0));
        expect(desgloseEgresos['Transporte'], equals(200.0));
        expect(desgloseEgresos.length, equals(2));
      });
    });

    group('Filtros por Fecha Tests', () {
      setUp(() async {
        // Limpiar transacciones existentes
        await testDatabase.delete('transacciones');
        
        final ahora = DateTime.now();
        final transaccionesFecha = [
          {
            'id': 'hoy',
            'monto': 100.0,
            'categoria_id': 1,
            'tipo': 'ingreso',
            'fecha': ahora.millisecondsSinceEpoch,
            'descripcion': 'Hoy',
          },
          {
            'id': 'ayer',
            'monto': 200.0,
            'categoria_id': 2,
            'tipo': 'egreso',
            'fecha': ahora.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
            'descripcion': 'Ayer',
          },
          {
            'id': 'mes_pasado',
            'monto': 300.0,
            'categoria_id': 1,
            'tipo': 'ingreso',
            'fecha': DateTime(ahora.year, ahora.month - 1, ahora.day).millisecondsSinceEpoch,
            'descripcion': 'Mes pasado',
          },
        ];

        for (var transaccion in transaccionesFecha) {
          await testDatabase.insert('transacciones', transaccion);
        }

        await gestorFinanzas.cargarTransacciones();
      });

      test('obtenerTransaccionesFiltradas debería filtrar por día', () {
        // Act
        final transaccionesHoy = gestorFinanzas.obtenerTransaccionesFiltradas('día');

        // Assert
        expect(transaccionesHoy.length, equals(1));
        expect(transaccionesHoy[0].descripcion, equals('Hoy'));
      });

      test('obtenerTransaccionesFiltradas debería filtrar por mes', () {
        // Act
        final transaccionesMes = gestorFinanzas.obtenerTransaccionesFiltradas('mes');

        // Assert
        expect(transaccionesMes.length, equals(2)); // Hoy y ayer
        expect(transaccionesMes.any((t) => t.descripcion == 'Hoy'), isTrue);
        expect(transaccionesMes.any((t) => t.descripcion == 'Ayer'), isTrue);
      });

      test('obtenerTransaccionesFiltradas debería filtrar por año', () {
        // Act
        final transaccionesAnio = gestorFinanzas.obtenerTransaccionesFiltradas('año');

        // Assert
        expect(transaccionesAnio.length, equals(3));
      });

      test('obtenerTransaccionesFiltradas debería devolver todas con filtro desconocido', () {
        // Act
        final todasTransacciones = gestorFinanzas.obtenerTransaccionesFiltradas('filtro_inexistente');

        // Assert
        expect(todasTransacciones.length, equals(3));
      });
    });

    group('Operaciones CRUD Tests', () {
      late Transaccion nuevaTransaccion;

      setUp(() async {
        await gestorFinanzas.cargarTransacciones();
        nuevaTransaccion = Transaccion(
          id: 'nueva_transaccion',
          monto: 150.0,
          categoria: Categoria(nombre: 'Salario', tipo: 'ingreso', icono: '💰'),
          tipo: 'ingreso',
          fecha: DateTime.now(),
          descripcion: 'Transacción nueva',
        );
      });

      test('agregarTransaccion debería añadir una nueva transacción', () async {
        final cantidadAntes = gestorFinanzas.transacciones.length;

        // Act
        await gestorFinanzas.agregarTransaccion(nuevaTransaccion);
        await gestorFinanzas.cargarTransacciones();

        // Assert
        expect(gestorFinanzas.transacciones.length, equals(cantidadAntes + 1));
        expect(gestorFinanzas.transacciones.any((t) => t.id == 'nueva_transaccion'), isTrue);
      });

      test('editarTransaccion debería actualizar una transacción existente', () async {
        // Arrange
        final transaccionOriginal = gestorFinanzas.transacciones.first;
        final transaccionEditada = Transaccion(
          id: transaccionOriginal.id,
          monto: 9999.0,
          categoria: transaccionOriginal.categoria,
          tipo: transaccionOriginal.tipo,
          fecha: transaccionOriginal.fecha,
          descripcion: 'Editada',
        );

        // Act
        await gestorFinanzas.editarTransaccion(transaccionOriginal.id, transaccionEditada);
        await gestorFinanzas.cargarTransacciones();

        // Assert
        final transaccionActualizada = gestorFinanzas.transacciones
            .firstWhere((t) => t.id == transaccionOriginal.id);
        expect(transaccionActualizada.monto, equals(9999.0));
        expect(transaccionActualizada.descripcion, equals('Editada'));
      });

      test('eliminarTransaccion debería remover una transacción', () async {
        // Arrange
        final cantidadAntes = gestorFinanzas.transacciones.length;
        final idParaEliminar = gestorFinanzas.transacciones.first.id;

        // Act
        await gestorFinanzas.eliminarTransaccion(idParaEliminar);
        await gestorFinanzas.cargarTransacciones();

        // Assert
        expect(gestorFinanzas.transacciones.length, equals(cantidadAntes - 1));
        expect(gestorFinanzas.transacciones.any((t) => t.id == idParaEliminar), isFalse);
      });
    });*/

    group('Edge Cases Tests', () {
      test('calcularTotal debería devolver 0 para lista vacía', () {
        // Arrange
        gestorFinanzas.transacciones.clear();

        // Act
        final total = gestorFinanzas.calcularTotal('ingreso');

        // Assert
        expect(total, equals(0.0));
      });

      test('desglosePorCategoria debería devolver mapa vacío para lista vacía', () {
        // Arrange
        gestorFinanzas.transacciones.clear();

        // Act
        final desglose = gestorFinanzas.desglosePorCategoria('ingreso');

        // Assert
        expect(desglose, isEmpty);
      });

      test('filtrarPorCategoria debería devolver lista vacía para categoría inexistente', () async {
        // Arrange
        await gestorFinanzas.cargarTransacciones();

        // Act
        final resultado = gestorFinanzas.filtrarPorCategoria('Categoría Inexistente');

        // Assert
        expect(resultado, isEmpty);
      });

      test('obtenerPorTipo debería devolver lista vacía para tipo inexistente', () async {
        // Arrange
        await gestorFinanzas.cargarTransacciones();

        // Act
        final resultado = gestorFinanzas.obtenerPorTipo('tipo_inexistente');

        // Assert
        expect(resultado, isEmpty);
      });
    });

    group('Métodos de Utilidad Tests', () {
      test('guardarTransacciones debería ejecutarse sin errores', () async {
        // Act & Assert
        expect(() async => await gestorFinanzas.guardarTransacciones(), 
               returnsNormally);
      });
    });
  });
}