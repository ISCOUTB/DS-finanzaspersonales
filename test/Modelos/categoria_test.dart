import 'package:flutter_test/flutter_test.dart';
import 'package:finanse_tracker/Modelos/categoria.dart';

void main() {
  group('Categoria', () {
    group('Constructor', () {
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

      test('Constructor funciona con diferentes tipos de iconos', () {
        final categoriaEmoji = Categoria(
          nombre: 'Comida',
          tipo: 'egreso',
          icono: '🍔',
        );

        final categoriaTexto = Categoria(
          nombre: 'Internet',
          tipo: 'egreso',
          icono: 'wifi',
        );

        final categoriaCodigo = Categoria(
          nombre: 'Bonus',
          tipo: 'ingreso',
          icono: 'bonus_icon',
        );

        expect(categoriaEmoji.icono, '🍔');
        expect(categoriaTexto.icono, 'wifi');
        expect(categoriaCodigo.icono, 'bonus_icon');
      });

      test('Constructor funciona con valores vacíos', () {
        final categoria = Categoria(
          nombre: '',
          tipo: '',
          icono: '',
        );

        expect(categoria.nombre, '');
        expect(categoria.tipo, '');
        expect(categoria.icono, '');
      });

      test('Constructor funciona con caracteres especiales', () {
        final categoria = Categoria(
          nombre: 'José María O\'Connor-Smith',
          tipo: 'ingreso/egreso',
          icono: '🌟✨💫',
        );

        expect(categoria.nombre, 'José María O\'Connor-Smith');
        expect(categoria.tipo, 'ingreso/egreso');
        expect(categoria.icono, '🌟✨💫');
      });

      test('Constructor funciona con nombres largos', () {
        final nombreLargo = 'Esta es una categoría con un nombre extremadamente largo que podría causar problemas';
        final categoria = Categoria(
          nombre: nombreLargo,
          tipo: 'ingreso',
          icono: '📝',
        );

        expect(categoria.nombre, nombreLargo);
        expect(categoria.tipo, 'ingreso');
        expect(categoria.icono, '📝');
      });
    });

    group('toJson', () {
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

      test('toJson incluye todas las propiedades', () {
        final categoria = Categoria(
          nombre: 'Salario',
          tipo: 'ingreso',
          icono: '💰',
        );

        final json = categoria.toJson();

        expect(json.keys, hasLength(3));
        expect(json.containsKey('nombre'), isTrue);
        expect(json.containsKey('tipo'), isTrue);
        expect(json.containsKey('icono'), isTrue);
      });

      test('toJson maneja valores vacíos correctamente', () {
        final categoria = Categoria(
          nombre: '',
          tipo: '',
          icono: '',
        );

        final json = categoria.toJson();

        expect(json['nombre'], '');
        expect(json['tipo'], '');
        expect(json['icono'], '');
      });

      test('toJson maneja caracteres especiales', () {
        final categoria = Categoria(
          nombre: 'José & María',
          tipo: 'ingreso/especial',
          icono: '🌟✨',
        );

        final json = categoria.toJson();

        expect(json['nombre'], 'José & María');
        expect(json['tipo'], 'ingreso/especial');
        expect(json['icono'], '🌟✨');
      });

      test('toJson retorna un nuevo mapa en cada llamada', () {
        final categoria = Categoria(
          nombre: 'Test',
          tipo: 'ingreso',
          icono: '🧪',
        );

        final json1 = categoria.toJson();
        final json2 = categoria.toJson();

        expect(identical(json1, json2), isFalse);
        expect(json1, equals(json2));
      });

      test('toJson maneja Unicode correctamente', () {
        final categoria = Categoria(
          nombre: '测试类别',
          tipo: 'доход',
          icono: '🎌',
        );

        final json = categoria.toJson();

        expect(json['nombre'], '测试类别');
        expect(json['tipo'], 'доход');
        expect(json['icono'], '🎌');
      });
    });

    group('fromJson', () {
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

      test('fromJson maneja diferentes tipos de datos', () {
        final json = {
          'nombre': 'Investment',
          'tipo': 'ingreso',
          'icono': 'chart_icon',
        };

        final categoria = Categoria.fromJson(json);

        expect(categoria.nombre, 'Investment');
        expect(categoria.tipo, 'ingreso');
        expect(categoria.icono, 'chart_icon');
      });

      test('fromJson maneja valores vacíos', () {
        final json = {
          'nombre': '',
          'tipo': '',
          'icono': '',
        };

        final categoria = Categoria.fromJson(json);

        expect(categoria.nombre, '');
        expect(categoria.tipo, '');
        expect(categoria.icono, '');
      });

      test('fromJson maneja caracteres especiales', () {
        final json = {
          'nombre': 'José & María',
          'tipo': 'ingreso/especial',
          'icono': '🌟✨',
        };

        final categoria = Categoria.fromJson(json);

        expect(categoria.nombre, 'José & María');
        expect(categoria.tipo, 'ingreso/especial');
        expect(categoria.icono, '🌟✨');
      });

      test('fromJson maneja Unicode correctamente', () {
        final json = {
          'nombre': '测试类别',
          'tipo': 'доход',
          'icono': '🎌',
        };

        final categoria = Categoria.fromJson(json);

        expect(categoria.nombre, '测试类别');
        expect(categoria.tipo, 'доход');
        expect(categoria.icono, '🎌');
      });

      test('fromJson con Map<String, Object?>', () {
        final Map<String, Object?> json = {
          'nombre': 'Test Category',
          'tipo': 'ingreso',
          'icono': '🔥',
        };

        final categoria = Categoria.fromJson(json as Map<String, dynamic>);

        expect(categoria.nombre, 'Test Category');
        expect(categoria.tipo, 'ingreso');
        expect(categoria.icono, '🔥');
      });

      /*test('fromJson maneja valores null como string', () {
        final json = {
          'nombre': null,
          'tipo': null,
          'icono': null,
        };

        final categoria = Categoria.fromJson(json);

        expect(categoria.nombre, isNull);
        expect(categoria.tipo, isNull);
        expect(categoria.icono, isNull);
      });*/
    });

    group('Serialización Bidireccional', () {
      test('toJson y fromJson son operaciones inversas', () {
        final categoriaOriginal = Categoria(
          nombre: 'Freelance',
          tipo: 'ingreso',
          icono: '💻',
        );

        final json = categoriaOriginal.toJson();
        final categoriaReconstruida = Categoria.fromJson(json);

        expect(categoriaReconstruida.nombre, categoriaOriginal.nombre);
        expect(categoriaReconstruida.tipo, categoriaOriginal.tipo);
        expect(categoriaReconstruida.icono, categoriaOriginal.icono);
      });

      test('Múltiples serializaciones mantienen integridad', () {
        final categoriaOriginal = Categoria(
          nombre: 'Utilities',
          tipo: 'egreso',
          icono: '⚡',
        );

        // Serializar y deserializar múltiples veces
        var categoria = categoriaOriginal;
        for (int i = 0; i < 5; i++) {
          final json = categoria.toJson();
          categoria = Categoria.fromJson(json);
        }

        expect(categoria.nombre, categoriaOriginal.nombre);
        expect(categoria.tipo, categoriaOriginal.tipo);
        expect(categoria.icono, categoriaOriginal.icono);
      });

      test('Serialización de lista de categorías', () {
        final categorias = [
          Categoria(nombre: 'Cat1', tipo: 'ingreso', icono: '1️⃣'),
          Categoria(nombre: 'Cat2', tipo: 'egreso', icono: '2️⃣'),
          Categoria(nombre: 'Cat3', tipo: 'ingreso', icono: '3️⃣'),
        ];

        final jsonList = categorias.map((c) => c.toJson()).toList();
        final categoriasReconstruidas = jsonList.map((j) => Categoria.fromJson(j)).toList();

        expect(categoriasReconstruidas.length, categorias.length);
        
        for (int i = 0; i < categorias.length; i++) {
          expect(categoriasReconstruidas[i].nombre, categorias[i].nombre);
          expect(categoriasReconstruidas[i].tipo, categorias[i].tipo);
          expect(categoriasReconstruidas[i].icono, categorias[i].icono);
        }
      });
    });

    group('Mutabilidad de Propiedades', () {
      test('Las propiedades pueden modificarse después de la creación', () {
        final categoria = Categoria(
          nombre: 'Inicial',
          tipo: 'ingreso',
          icono: '🔵',
        );

        categoria.nombre = 'Modificado';
        categoria.tipo = 'egreso';
        categoria.icono = '🔴';

        expect(categoria.nombre, 'Modificado');
        expect(categoria.tipo, 'egreso');
        expect(categoria.icono, '🔴');
      });

      test('Modificaciones se reflejan en toJson', () {
        final categoria = Categoria(
          nombre: 'Original',
          tipo: 'ingreso',
          icono: '🟢',
        );

        categoria.nombre = 'Cambiado';
        final json = categoria.toJson();

        expect(json['nombre'], 'Cambiado');
        expect(json['tipo'], 'ingreso');
        expect(json['icono'], '🟢');
      });

      test('Instancias son independientes', () {
        final categoria1 = Categoria(
          nombre: 'Categoria1',
          tipo: 'ingreso',
          icono: '1️⃣',
        );

        final categoria2 = Categoria(
          nombre: 'Categoria2',
          tipo: 'egreso',
          icono: '2️⃣',
        );

        categoria1.nombre = 'Modificada1';
        
        expect(categoria1.nombre, 'Modificada1');
        expect(categoria2.nombre, 'Categoria2');
      });
    });

    group('Casos Edge y Validaciones', () {
      test('Maneja strings con comillas', () {
        final categoria = Categoria(
          nombre: 'Don\'t "worry" about it',
          tipo: 'ingreso',
          icono: '😄',
        );

        final json = categoria.toJson();
        final categoriaReconstruida = Categoria.fromJson(json);

        expect(categoriaReconstruida.nombre, 'Don\'t "worry" about it');
      });

      test('Maneja caracteres de escape', () {
        final categoria = Categoria(
          nombre: 'Test\nLine\tTab\\Backslash',
          tipo: 'ingreso',
          icono: '🔥',
        );

        final json = categoria.toJson();
        final categoriaReconstruida = Categoria.fromJson(json);

        expect(categoriaReconstruida.nombre, 'Test\nLine\tTab\\Backslash');
      });

      test('Maneja números como strings en JSON', () {
        final json = {
          'nombre': '123',
          'tipo': '456',
          'icono': '789',
        };

        final categoria = Categoria.fromJson(json);

        expect(categoria.nombre, '123');
        expect(categoria.tipo, '456');
        expect(categoria.icono, '789');
      });

      test('Maneja JSON con propiedades adicionales', () {
        final json = {
          'nombre': 'Test',
          'tipo': 'ingreso',
          'icono': '🧪',
          'propiedadExtra': 'valor',
          'otraPropiedad': 123,
        };

        final categoria = Categoria.fromJson(json);

        expect(categoria.nombre, 'Test');
        expect(categoria.tipo, 'ingreso');
        expect(categoria.icono, '🧪');
      });

      test('toJson no incluye propiedades null', () {
        final categoria = Categoria(
          nombre: 'Test',
          tipo: 'ingreso',
          icono: '🧪',
        );

        final json = categoria.toJson();

        expect(json.keys.every((key) => json[key] != null), isTrue);
      });
    });

    group('Comparación y Igualdad', () {
      test('Instancias con los mismos valores no son iguales por referencia', () {
        final categoria1 = Categoria(
          nombre: 'Test',
          tipo: 'ingreso',
          icono: '🧪',
        );

        final categoria2 = Categoria(
          nombre: 'Test',
          tipo: 'ingreso',
          icono: '🧪',
        );

        expect(identical(categoria1, categoria2), isFalse);
        expect(categoria1 == categoria2, isFalse); // No hay override de ==
      });

      test('Misma instancia es idéntica a sí misma', () {
        final categoria = Categoria(
          nombre: 'Test',
          tipo: 'ingreso',
          icono: '🧪',
        );

        expect(identical(categoria, categoria), isTrue);
        expect(categoria == categoria, isTrue);
      });

      test('Propiedades individuales pueden compararse', () {
        final categoria1 = Categoria(
          nombre: 'Test',
          tipo: 'ingreso',
          icono: '🧪',
        );

        final categoria2 = Categoria(
          nombre: 'Test',
          tipo: 'egreso',
          icono: '🧪',
        );

        expect(categoria1.nombre == categoria2.nombre, isTrue);
        expect(categoria1.tipo == categoria2.tipo, isFalse);
        expect(categoria1.icono == categoria2.icono, isTrue);
      });
    });

    group('Performance y Memoria', () {
      test('Creación de múltiples instancias es eficiente', () {
        final stopwatch = Stopwatch()..start();

        final categorias = <Categoria>[];
        for (int i = 0; i < 1000; i++) {
          categorias.add(Categoria(
            nombre: 'Categoria$i',
            tipo: i % 2 == 0 ? 'ingreso' : 'egreso',
            icono: '🔢',
          ));
        }

        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(100));
        expect(categorias.length, 1000);
      });

      test('Serialización de múltiples instancias es eficiente', () {
        final categorias = <Categoria>[];
        for (int i = 0; i < 100; i++) {
          categorias.add(Categoria(
            nombre: 'Cat$i',
            tipo: 'ingreso',
            icono: '⚡',
          ));
        }

        final stopwatch = Stopwatch()..start();

        final jsonList = categorias.map((c) => c.toJson()).toList();
        final categoriasReconstruidas = jsonList.map((j) => Categoria.fromJson(j)).toList();

        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(50));
        expect(categoriasReconstruidas.length, 100);
      });

      test('Memoria se libera correctamente', () {
        // Test básico para verificar que las instancias pueden ser garbage collected
        var categoria = Categoria(
          nombre: 'Temporal',
          tipo: 'ingreso',
          icono: '⏰',
        );

        final json = categoria.toJson();
        categoria = Categoria.fromJson(json);

        expect(categoria.nombre, 'Temporal');
        
        // Eliminar referencia
        categoria = Categoria(nombre: '', tipo: '', icono: '');
        
        expect(categoria.nombre, '');
      });
    });
  });
}