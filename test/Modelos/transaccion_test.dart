import 'package:flutter_test/flutter_test.dart';
import 'package:finanse_tracker/Modelos/transaccion.dart';
import 'package:finanse_tracker/Modelos/categoria.dart';

void main() {
  group('Transaccion', () {
    late Categoria categoriaIngreso;
    late Categoria categoriaEgreso;

    setUp(() {
      categoriaIngreso = Categoria(
        nombre: 'Salario',
        tipo: 'ingreso',
        icono: '💰',
      );
      
      categoriaEgreso = Categoria(
        nombre: 'Alimentación',
        tipo: 'egreso',
        icono: '🍔',
      );
    });

    group('Constructor', () {
      test('Constructor asigna correctamente los valores con descripción', () {
        final transaccion = Transaccion(
          id: '1',
          tipo: 'ingreso',
          monto: 1000.0,
          fecha: DateTime(2024, 5, 26),
          categoria: categoriaIngreso,
          descripcion: 'Pago mensual',
        );

        expect(transaccion.id, '1');
        expect(transaccion.tipo, 'ingreso');
        expect(transaccion.monto, 1000.0);
        expect(transaccion.fecha, DateTime(2024, 5, 26));
        expect(transaccion.categoria, categoriaIngreso);
        expect(transaccion.descripcion, 'Pago mensual');
      });

      test('Constructor funciona sin descripción (nullable)', () {
        final transaccion = Transaccion(
          id: '2',
          tipo: 'egreso',
          monto: 50.0,
          fecha: DateTime(2024, 3, 15),
          categoria: categoriaEgreso,
        );

        expect(transaccion.id, '2');
        expect(transaccion.tipo, 'egreso');
        expect(transaccion.monto, 50.0);
        expect(transaccion.fecha, DateTime(2024, 3, 15));
        expect(transaccion.categoria, categoriaEgreso);
        expect(transaccion.descripcion, isNull);
      });

      test('Constructor funciona con descripción null explícita', () {
        final transaccion = Transaccion(
          id: '3',
          tipo: 'ingreso',
          monto: 200.0,
          fecha: DateTime(2024, 1, 1),
          categoria: categoriaIngreso,
          descripcion: null,
        );

        expect(transaccion.id, '3');
        expect(transaccion.descripcion, isNull);
      });

      test('Constructor funciona con monto decimal', () {
        final transaccion = Transaccion(
          id: '4',
          tipo: 'egreso',
          monto: 15.99,
          fecha: DateTime(2024, 2, 14),
          categoria: categoriaEgreso,
          descripcion: 'Café',
        );

        expect(transaccion.monto, 15.99);
        expect(transaccion.monto, isA<double>());
      });

      test('Constructor funciona con fecha y hora específica', () {
        final fechaEspecifica = DateTime(2024, 6, 15, 14, 30, 45);
        final transaccion = Transaccion(
          id: '5',
          tipo: 'ingreso',
          monto: 100.0,
          fecha: fechaEspecifica,
          categoria: categoriaIngreso,
          descripcion: 'Consultoría',
        );

        expect(transaccion.fecha, fechaEspecifica);
        expect(transaccion.fecha.hour, 14);
        expect(transaccion.fecha.minute, 30);
        expect(transaccion.fecha.second, 45);
      });

      test('Constructor funciona con monto cero', () {
        final transaccion = Transaccion(
          id: '6',
          tipo: 'egreso',
          monto: 0.0,
          fecha: DateTime.now(),
          categoria: categoriaEgreso,
          descripcion: 'Transacción gratuita',
        );

        expect(transaccion.monto, 0.0);
      });

      test('Constructor funciona con valores extremos', () {
        final transaccion = Transaccion(
          id: 'ID_MUY_LARGO_123456789',
          tipo: 'ingreso',
          monto: 999999.99,
          fecha: DateTime(2024, 12, 31, 23, 59, 59),
          categoria: categoriaIngreso,
          descripcion: 'Descripción extremadamente larga que podría causar problemas en algunos sistemas de base de datos o interfaces de usuario',
        );

        expect(transaccion.id, 'ID_MUY_LARGO_123456789');
        expect(transaccion.monto, 999999.99);
        expect(transaccion.descripcion?.length, greaterThan(100));
      });
    });

    group('toJson', () {
      test('toJson retorna un mapa válido con descripción', () {
        final transaccion = Transaccion(
          id: '2',
          tipo: 'egreso',
          monto: 250.5,
          fecha: DateTime(2024, 5, 20, 10, 30),
          categoria: categoriaEgreso,
          descripcion: 'Compra',
        );

        final json = transaccion.toJson();

        expect(json, isA<Map<String, dynamic>>());
        expect(json['id'], '2');
        expect(json['tipo'], 'egreso');
        expect(json['monto'], 250.5);
        expect(json['fecha'], DateTime(2024, 5, 20, 10, 30).toIso8601String());
        expect(json['categoria'], categoriaEgreso.toJson());
        expect(json['descripcion'], 'Compra');
      });

      test('toJson incluye todas las propiedades', () {
        final transaccion = Transaccion(
          id: 'test',
          tipo: 'ingreso',
          monto: 100.0,
          fecha: DateTime.now(),
          categoria: categoriaIngreso,
          descripcion: 'Test',
        );

        final json = transaccion.toJson();

        expect(json.keys, hasLength(6));
        expect(json.containsKey('id'), isTrue);
        expect(json.containsKey('tipo'), isTrue);
        expect(json.containsKey('monto'), isTrue);
        expect(json.containsKey('fecha'), isTrue);
        expect(json.containsKey('categoria'), isTrue);
        expect(json.containsKey('descripcion'), isTrue);
      });

      test('toJson maneja descripción null', () {
        final transaccion = Transaccion(
          id: '3',
          tipo: 'ingreso',
          monto: 500.0,
          fecha: DateTime(2024, 3, 10),
          categoria: categoriaIngreso,
        );

        final json = transaccion.toJson();

        expect(json['descripcion'], isNull);
        expect(json.containsKey('descripcion'), isTrue);
      });

      test('toJson serializa correctamente la fecha con ISO8601', () {
        final fecha = DateTime(2024, 6, 15, 14, 30, 45, 123);
        final transaccion = Transaccion(
          id: '4',
          tipo: 'egreso',
          monto: 75.0,
          fecha: fecha,
          categoria: categoriaEgreso,
          descripcion: 'Test fecha',
        );

        final json = transaccion.toJson();

        expect(json['fecha'], fecha.toIso8601String());
        expect(json['fecha'], contains('2024-06-15T14:30:45'));
      });

      test('toJson serializa correctamente la categoría', () {
        final transaccion = Transaccion(
          id: '5',
          tipo: 'ingreso',
          monto: 1000.0,
          fecha: DateTime.now(),
          categoria: categoriaIngreso,
          descripcion: 'Test categoría',
        );

        final json = transaccion.toJson();
        final categoriaJson = json['categoria'] as Map<String, dynamic>;

        expect(categoriaJson['nombre'], 'Salario');
        expect(categoriaJson['tipo'], 'ingreso');
        expect(categoriaJson['icono'], '💰');
      });

      test('toJson con caracteres especiales', () {
        final transaccion = Transaccion(
          id: 'ID_José',
          tipo: 'ingreso',
          monto: 100.0,
          fecha: DateTime.now(),
          categoria: categoriaIngreso,
          descripcion: 'Descripción con acentós y "comillas"',
        );

        final json = transaccion.toJson();

        expect(json['id'], 'ID_José');
        expect(json['descripcion'], 'Descripción con acentós y "comillas"');
      });

      test('toJson retorna nuevo mapa en cada llamada', () {
        final transaccion = Transaccion(
          id: '6',
          tipo: 'egreso',
          monto: 25.0,
          fecha: DateTime.now(),
          categoria: categoriaEgreso,
          descripcion: 'Test independencia',
        );

        final json1 = transaccion.toJson();
        final json2 = transaccion.toJson();

        expect(identical(json1, json2), isFalse);
        expect(json1, equals(json2));
      });
    });

    group('toMap', () {
      test('toMap retorna un mapa válido', () {
        final transaccion = Transaccion(
          id: '4',
          tipo: 'egreso',
          monto: 75.0,
          fecha: DateTime(2024, 5, 10),
          categoria: categoriaEgreso,
          descripcion: 'Transporte',
        );

        final map = transaccion.toMap();

        expect(map, isA<Map<String, dynamic>>());
        expect(map['id'], '4');
        expect(map['tipo'], 'egreso');
        expect(map['monto'], 75.0);
        expect(map['descripcion'], 'Transporte');
        expect(map['fecha'], DateTime(2024, 5, 10).toIso8601String());
        expect(map['categoria'], categoriaEgreso);
      });

      test('toMap incluye todas las propiedades', () {
        final transaccion = Transaccion(
          id: 'test',
          tipo: 'ingreso',
          monto: 100.0,
          fecha: DateTime.now(),
          categoria: categoriaIngreso,
          descripcion: 'Test',
        );

        final map = transaccion.toMap();

        expect(map.keys, hasLength(6));
        expect(map.containsKey('id'), isTrue);
        expect(map.containsKey('tipo'), isTrue);
        expect(map.containsKey('monto'), isTrue);
        expect(map.containsKey('fecha'), isTrue);
        expect(map.containsKey('categoria'), isTrue);
        expect(map.containsKey('descripcion'), isTrue);
      });

      test('toMap preserva el objeto Categoria (no serializado)', () {
        final transaccion = Transaccion(
          id: '5',
          tipo: 'ingreso',
          monto: 200.0,
          fecha: DateTime.now(),
          categoria: categoriaIngreso,
          descripcion: 'Test categoria objeto',
        );

        final map = transaccion.toMap();

        expect(map['categoria'], isA<Categoria>());
        expect(map['categoria'], same(categoriaIngreso));
        expect(map['categoria'].nombre, 'Salario');
      });

      test('toMap maneja descripción null', () {
        final transaccion = Transaccion(
          id: '6',
          tipo: 'egreso',
          monto: 50.0,
          fecha: DateTime.now(),
          categoria: categoriaEgreso,
        );

        final map = transaccion.toMap();

        expect(map['descripcion'], isNull);
        expect(map.containsKey('descripcion'), isTrue);
      });

      test('Diferencia entre toMap y toJson para categoria', () {
        final transaccion = Transaccion(
          id: '7',
          tipo: 'ingreso',
          monto: 150.0,
          fecha: DateTime.now(),
          categoria: categoriaIngreso,
          descripcion: 'Test diferencia',
        );

        final map = transaccion.toMap();
        final json = transaccion.toJson();

        // toMap preserva el objeto Categoria
        expect(map['categoria'], isA<Categoria>());
        
        // toJson serializa la categoria a Map
        expect(json['categoria'], isA<Map<String, dynamic>>());
      });
    });

    group('fromJson', () {
      test('fromJson crea una instancia válida con descripción', () {
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

      test('fromJson maneja descripción null', () {
        final json = {
          'id': '4',
          'tipo': 'egreso',
          'monto': 25.0,
          'fecha': '2024-06-01T09:00:00.000',
          'categoria': {
            'nombre': 'Café',
            'tipo': 'egreso',
            'icono': '☕',
          },
          'descripcion': null,
        };

        final transaccion = Transaccion.fromJson(json);

        expect(transaccion.descripcion, isNull);
      });

      test('fromJson maneja descripción ausente', () {
        final json = {
          'id': '5',
          'tipo': 'ingreso',
          'monto': 100.0,
          'fecha': '2024-06-01T10:00:00.000',
          'categoria': {
            'nombre': 'Freelance',
            'tipo': 'ingreso',
            'icono': '💻',
          },
          // Sin descripción
        };

        final transaccion = Transaccion.fromJson(json);

        expect(transaccion.descripcion, isNull);
      });

      test('fromJson parsea correctamente diferentes formatos de fecha', () {
        final formatosFecha = [
          '2024-06-15T14:30:45.123Z',
          '2024-06-15T14:30:45.123',
          '2024-06-15T14:30:45',
          '2024-06-15T14:30:00.000',
        ];

        for (final fechaStr in formatosFecha) {
          final json = {
            'id': 'test',
            'tipo': 'ingreso',
            'monto': 100.0,
            'fecha': fechaStr,
            'categoria': {
              'nombre': 'Test',
              'tipo': 'ingreso',
              'icono': '🧪',
            },
            'descripcion': 'Test fecha',
          };

          final transaccion = Transaccion.fromJson(json);

          expect(transaccion.fecha, isA<DateTime>());
          expect(transaccion.fecha.year, 2024);
          expect(transaccion.fecha.month, 6);
          expect(transaccion.fecha.day, 15);
        }
      });

      /*test('fromJson maneja montos como int y double', () {
        final jsonInt = {
          'id': '6',
          'tipo': 'egreso',
          'monto': 50, // int
          'fecha': '2024-06-01T12:00:00.000',
          'categoria': {
            'nombre': 'Test',
            'tipo': 'egreso',
            'icono': '🧪',
          },
          'descripcion': 'Test monto int',
        };

        final jsonDouble = {
          'id': '7',
          'tipo': 'egreso',
          'monto': 50.5, // double
          'fecha': '2024-06-01T12:00:00.000',
          'categoria': {
            'nombre': 'Test',
            'tipo': 'egreso',
            'icono': '🧪',
          },
          'descripcion': 'Test monto double',
        };

        final transaccionInt = Transaccion.fromJson(jsonInt);
        final transaccionDouble = Transaccion.fromJson(jsonDouble);

        expect(transaccionInt.monto, 50.0);
        expect(transaccionInt.monto, isA<double>());
        expect(transaccionDouble.monto, 50.5);
        expect(transaccionDouble.monto, isA<double>());
      });*/

      test('fromJson con caracteres especiales en strings', () {
        final json = {
          'id': 'ID_José_Ñoño',
          'tipo': 'ingreso',
          'monto': 100.0,
          'fecha': '2024-06-01T12:00:00.000',
          'categoria': {
            'nombre': 'Categoría Especial',
            'tipo': 'ingreso',
            'icono': '🌟',
          },
          'descripcion': 'Descripción con acentós, ñoño y "comillas"',
        };

        final transaccion = Transaccion.fromJson(json);

        expect(transaccion.id, 'ID_José_Ñoño');
        expect(transaccion.descripcion, 'Descripción con acentós, ñoño y "comillas"');
        expect(transaccion.categoria.nombre, 'Categoría Especial');
      });

      test('fromJson maneja monto cero', () {
        final json = {
          'id': '8',
          'tipo': 'egreso',
          'monto': 0.0,
          'fecha': '2024-06-01T12:00:00.000',
          'categoria': {
            'nombre': 'Gratis',
            'tipo': 'egreso',
            'icono': '🆓',
          },
          'descripcion': 'Transacción gratuita',
        };

        final transaccion = Transaccion.fromJson(json);

        expect(transaccion.monto, 0.0);
      });

      test('fromJson con monto muy grande', () {
        final json = {
          'id': '9',
          'tipo': 'ingreso',
          'monto': 999999999.99,
          'fecha': '2024-06-01T12:00:00.000',
          'categoria': {
            'nombre': 'Lotería',
            'tipo': 'ingreso',
            'icono': '🎰',
          },
          'descripcion': 'Premio grande',
        };

        final transaccion = Transaccion.fromJson(json);

        expect(transaccion.monto, 999999999.99);
      });
    });

    group('Serialización Bidireccional', () {
      test('toJson y fromJson son operaciones inversas con descripción', () {
        final transaccionOriginal = Transaccion(
          id: 'test_1',
          tipo: 'ingreso',
          monto: 1500.75,
          fecha: DateTime(2024, 6, 15, 14, 30, 45),
          categoria: categoriaIngreso,
          descripcion: 'Consultoría especializada',
        );

        final json = transaccionOriginal.toJson();
        final transaccionReconstruida = Transaccion.fromJson(json);

        expect(transaccionReconstruida.id, transaccionOriginal.id);
        expect(transaccionReconstruida.tipo, transaccionOriginal.tipo);
        expect(transaccionReconstruida.monto, transaccionOriginal.monto);
        expect(transaccionReconstruida.fecha, transaccionOriginal.fecha);
        expect(transaccionReconstruida.descripcion, transaccionOriginal.descripcion);
        expect(transaccionReconstruida.categoria.nombre, transaccionOriginal.categoria.nombre);
        expect(transaccionReconstruida.categoria.tipo, transaccionOriginal.categoria.tipo);
        expect(transaccionReconstruida.categoria.icono, transaccionOriginal.categoria.icono);
      });

      test('toJson y fromJson son operaciones inversas sin descripción', () {
        final transaccionOriginal = Transaccion(
          id: 'test_2',
          tipo: 'egreso',
          monto: 45.0,
          fecha: DateTime(2024, 3, 20),
          categoria: categoriaEgreso,
        );

        final json = transaccionOriginal.toJson();
        final transaccionReconstruida = Transaccion.fromJson(json);

        expect(transaccionReconstruida.id, transaccionOriginal.id);
        expect(transaccionReconstruida.tipo, transaccionOriginal.tipo);
        expect(transaccionReconstruida.monto, transaccionOriginal.monto);
        expect(transaccionReconstruida.fecha, transaccionOriginal.fecha);
        expect(transaccionReconstruida.descripcion, isNull);
        expect(transaccionOriginal.descripcion, isNull);
      });

      test('Múltiples serializaciones mantienen integridad', () {
        final transaccionOriginal = Transaccion(
          id: 'test_3',
          tipo: 'ingreso',
          monto: 250.0,
          fecha: DateTime(2024, 4, 10, 9, 0),
          categoria: categoriaIngreso,
          descripcion: 'Pago por proyecto',
        );

        var transaccion = transaccionOriginal;
        for (int i = 0; i < 5; i++) {
          final json = transaccion.toJson();
          transaccion = Transaccion.fromJson(json);
        }

        expect(transaccion.id, transaccionOriginal.id);
        expect(transaccion.tipo, transaccionOriginal.tipo);
        expect(transaccion.monto, transaccionOriginal.monto);
        expect(transaccion.fecha, transaccionOriginal.fecha);
        expect(transaccion.descripcion, transaccionOriginal.descripcion);
      });

      test('Serialización de lista de transacciones', () {
        final transacciones = [
          Transaccion(
            id: '1',
            tipo: 'ingreso',
            monto: 100.0,
            fecha: DateTime(2024, 1, 1),
            categoria: categoriaIngreso,
            descripcion: 'Trans 1',
          ),
          Transaccion(
            id: '2',
            tipo: 'egreso',
            monto: 50.0,
            fecha: DateTime(2024, 1, 2),
            categoria: categoriaEgreso,
          ),
          Transaccion(
            id: '3',
            tipo: 'ingreso',
            monto: 75.0,
            fecha: DateTime(2024, 1, 3),
            categoria: categoriaIngreso,
            descripcion: 'Trans 3',
          ),
        ];

        final jsonList = transacciones.map((t) => t.toJson()).toList();
        final transaccionesReconstruidas = jsonList.map((j) => Transaccion.fromJson(j)).toList();

        expect(transaccionesReconstruidas.length, transacciones.length);
        
        for (int i = 0; i < transacciones.length; i++) {
          expect(transaccionesReconstruidas[i].id, transacciones[i].id);
          expect(transaccionesReconstruidas[i].tipo, transacciones[i].tipo);
          expect(transaccionesReconstruidas[i].monto, transacciones[i].monto);
          expect(transaccionesReconstruidas[i].fecha, transacciones[i].fecha);
          expect(transaccionesReconstruidas[i].descripcion, transacciones[i].descripcion);
        }
      });
    });

    group('Mutabilidad de Propiedades', () {
      test('Las propiedades pueden modificarse después de la creación', () {
        final transaccion = Transaccion(
          id: 'mutable_1',
          tipo: 'ingreso',
          monto: 100.0,
          fecha: DateTime(2024, 1, 1),
          categoria: categoriaIngreso,
          descripcion: 'Original',
        );

        transaccion.id = 'mutable_1_modificado';
        transaccion.tipo = 'egreso';
        transaccion.monto = 200.0;
        transaccion.fecha = DateTime(2024, 2, 2);
        transaccion.categoria = categoriaEgreso;
        transaccion.descripcion = 'Modificado';

        expect(transaccion.id, 'mutable_1_modificado');
        expect(transaccion.tipo, 'egreso');
        expect(transaccion.monto, 200.0);
        expect(transaccion.fecha, DateTime(2024, 2, 2));
        expect(transaccion.categoria, categoriaEgreso);
        expect(transaccion.descripcion, 'Modificado');
      });

      test('Modificar descripción a null', () {
        final transaccion = Transaccion(
          id: 'mutable_2',
          tipo: 'ingreso',
          monto: 100.0,
          fecha: DateTime.now(),
          categoria: categoriaIngreso,
          descripcion: 'Con descripción',
        );

        transaccion.descripcion = null;

        expect(transaccion.descripcion, isNull);
      });

      test('Modificaciones se reflejan en toJson', () {
        final transaccion = Transaccion(
          id: 'mutable_3',
          tipo: 'ingreso',
          monto: 100.0,
          fecha: DateTime(2024, 1, 1),
          categoria: categoriaIngreso,
          descripcion: 'Original',
        );

        transaccion.monto = 150.0;
        transaccion.descripcion = 'Modificado';
        
        final json = transaccion.toJson();

        expect(json['monto'], 150.0);
        expect(json['descripcion'], 'Modificado');
      });

      test('Instancias son independientes', () {
        final transaccion1 = Transaccion(
          id: '1',
          tipo: 'ingreso',
          monto: 100.0,
          fecha: DateTime.now(),
          categoria: categoriaIngreso,
          descripcion: 'Trans 1',
        );

        final transaccion2 = Transaccion(
          id: '2',
          tipo: 'egreso',
          monto: 50.0,
          fecha: DateTime.now(),
          categoria: categoriaEgreso,
          descripcion: 'Trans 2',
        );

        transaccion1.monto = 200.0;

        expect(transaccion1.monto, 200.0);
        expect(transaccion2.monto, 50.0);
      });
    });

    group('Casos Edge y Validaciones', () {
      test('Maneja strings con comillas en JSON', () {
        final json = {
          'id': 'test_comillas',
          'tipo': 'ingreso',
          'monto': 100.0,
          'fecha': '2024-06-01T12:00:00.000',
          'categoria': {
            'nombre': 'Don\'t "worry" about it',
            'tipo': 'ingreso',
            'icono': '😄',
          },
          'descripcion': 'Pago por "consultoría" especializada',
        };

        final transaccion = Transaccion.fromJson(json);

        expect(transaccion.categoria.nombre, 'Don\'t "worry" about it');
        expect(transaccion.descripcion, 'Pago por "consultoría" especializada');
      });

      test('Maneja caracteres de escape', () {
        final transaccion = Transaccion(
          id: 'test_escape',
          tipo: 'ingreso',
          monto: 100.0,
          fecha: DateTime.now(),
          categoria: categoriaIngreso,
          descripcion: 'Línea 1\nLínea 2\tTab\\Backslash',
        );

        final json = transaccion.toJson();
        final transaccionReconstruida = Transaccion.fromJson(json);

        expect(transaccionReconstruida.descripcion, 'Línea 1\nLínea 2\tTab\\Backslash');
      });

      test('Maneja fechas en diferentes zonas horarias', () {
        final fechaUTC = DateTime.utc(2024, 6, 15, 12, 0, 0);
        final transaccion = Transaccion(
          id: 'test_utc',
          tipo: 'ingreso',
          monto: 100.0,
          fecha: fechaUTC,
          categoria: categoriaIngreso,
          descripcion: 'Test UTC',
        );

        final json = transaccion.toJson();
        final transaccionReconstruida = Transaccion.fromJson(json);

        expect(transaccionReconstruida.fecha.isUtc, fechaUTC.isUtc);
        expect(transaccionReconstruida.fecha.millisecondsSinceEpoch, 
               fechaUTC.millisecondsSinceEpoch);
      });

      test('toMap y toJson con categoria modificada después de creación', () {
        final categoria = Categoria(
          nombre: 'Original',
          tipo: 'ingreso',
          icono: '🔵',
        );

        final transaccion = Transaccion(
          id: 'test_categoria_mod',
          tipo: 'ingreso',
          monto: 100.0,
          fecha: DateTime.now(),
          categoria: categoria,
          descripcion: 'Test',
        );

        // Modificar la categoría después de crear la transacción
        categoria.nombre = 'Modificado';
        categoria.icono = '🔴';

        final map = transaccion.toMap();
        final json = transaccion.toJson();

        // toMap preserva la referencia del objeto
        expect(map['categoria'].nombre, 'Modificado');
        expect(map['categoria'].icono, '🔴');

        // toJson serializa el estado actual
        expect(json['categoria']['nombre'], 'Modificado');
        expect(json['categoria']['icono'], '🔴');
      });

      test('fromJson con propiedades adicionales ignora las extra', () {
        final json = {
          'id': 'test_extra',
          'tipo': 'ingreso',
          'monto': 100.0,
          'fecha': '2024-06-01T12:00:00.000',
          'categoria': {
            'nombre': 'Test',
            'tipo': 'ingreso',
            'icono': '🧪',
            'propiedadExtra': 'valor',
          },
          'descripcion': 'Test',
          'propiedadNoExistente': 'valor',
          'otraPropiedad': 123,
        };

        final transaccion = Transaccion.fromJson(json);

        expect(transaccion.id, 'test_extra');
        expect(transaccion.tipo, 'ingreso');
        expect(transaccion.monto, 100.0);
        expect(transaccion.descripcion, 'Test');
      });
    });

    group('Performance y Memoria', () {
      test('Creación de múltiples transacciones es eficiente', () {
        final stopwatch = Stopwatch()..start();

        final transacciones = <Transaccion>[];
        for (int i = 0; i < 1000; i++) {
          transacciones.add(Transaccion(
            id: 'perf_$i',
            tipo: i % 2 == 0 ? 'ingreso' : 'egreso',
            monto: i * 10.0,
            fecha: DateTime(2024, 1, 1).add(Duration(days: i)),
            categoria: i % 2 == 0 ? categoriaIngreso : categoriaEgreso,
            descripcion: 'Transacción $i',
          ));
        }

        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(200));
        expect(transacciones.length, 1000);
      });

      test('Serialización masiva es eficiente', () {
        final transacciones = <Transaccion>[];
        for (int i = 0; i < 100; i++) {
          transacciones.add(Transaccion(
            id: 'serial_$i',
            tipo: 'ingreso',
            monto: i * 5.0,
            fecha: DateTime.now(),
            categoria: categoriaIngreso,
            descripcion: 'Test $i',
          ));
        }

        final stopwatch = Stopwatch()..start();

        final jsonList = transacciones.map((t) => t.toJson()).toList();
        final transaccionesReconstruidas = jsonList.map((j) => Transaccion.fromJson(j)).toList();

        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(100));
        expect(transaccionesReconstruidas.length, 100);
      });

      test('Memoria se maneja correctamente', () {
        var transaccion = Transaccion(
          id: 'memory_test',
          tipo: 'ingreso',
          monto: 100.0,
          fecha: DateTime.now(),
          categoria: categoriaIngreso,
          descripcion: 'Test memoria',
        );

        final json = transaccion.toJson();
        transaccion = Transaccion.fromJson(json);

        expect(transaccion.id, 'memory_test');
        
        // Limpiar referencia
        transaccion = Transaccion(
          id: '',
          tipo: '',
          monto: 0.0,
          fecha: DateTime.now(),
          categoria: Categoria(nombre: '', tipo: '', icono: ''),
        );
        
        expect(transaccion.id, '');
      });
    });
  });
}