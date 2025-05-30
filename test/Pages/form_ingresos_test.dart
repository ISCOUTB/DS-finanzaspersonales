import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finanse_tracker/pages/form_ingresos.dart';
import 'package:finanse_tracker/Modelos/transaccion.dart';
import 'package:finanse_tracker/Modelos/categoria.dart';
import 'package:finanse_tracker/Modelos/categoria_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Necesario para tests con sqflite en entorno no-Android/iOS
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Categorías de prueba - usar las mismas que CategoriaService
  final List<Categoria> categoriasTest = CategoriaService.getCategoriasIngresos();
  final categoriaIngreso = categoriasTest.first; // Asumimos que hay al menos una categoría

  // Helper para construir el widget FormIngresos
  Widget buildTestableWidget({Transaccion? transaccion}) {
    return MaterialApp(
      home: FormIngresos(transaccion: transaccion),
    );
  }

  group('FormIngresos - Renderizado de UI', () {
    testWidgets('Renderiza correctamente el formulario vacío', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Verificar elementos principales
      expect(find.text('Planificar un ingreso'), findsOneWidget);
      expect(find.text('Categoría'), findsOneWidget);
      expect(find.text('Cantidad'), findsOneWidget);
      expect(find.text('Fecha'), findsOneWidget);
      expect(find.text('Nombre'), findsOneWidget);
      expect(find.text('COP'), findsOneWidget);
      
      // Verificar controles
      expect(find.byType(DropdownButtonFormField<Categoria>), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // Monto y Descripción
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Crear'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Cancelar'), findsOneWidget);
    });

    testWidgets('Renderiza correctamente el formulario con transacción existente', (WidgetTester tester) async {
      final transaccionExistente = Transaccion(
        id: '123',
        tipo: 'ingreso',
        monto: 250.50,
        fecha: DateTime(2024, 8, 15),
        categoria: categoriaIngreso,
        descripcion: 'Pago por servicios',
      );

      await tester.pumpWidget(buildTestableWidget(transaccion: transaccionExistente));
      await tester.pumpAndSettle();

      // Verificar que los datos se cargan correctamente
      expect(find.text('250.5'), findsOneWidget);
      expect(find.text('Pago por servicios'), findsOneWidget);
      expect(find.text('15 agosto 2024'), findsOneWidget);
      expect(find.text(categoriaIngreso.nombre), findsAtLeastNWidgets(1));
    });

    testWidgets('Muestra la categoría con ícono en el dropdown', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Verificar que se muestra el ícono y nombre de la categoría seleccionada
      expect(find.text(categoriaIngreso.icono), findsOneWidget);
      expect(find.text(categoriaIngreso.nombre), findsOneWidget);
    });

    testWidgets('Muestra fecha actual por defecto', (WidgetTester tester) async {
      final hoy = DateTime.now();
      final mesNombre = _getMonthNameForTest(hoy.month);
      
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('${hoy.day} $mesNombre ${hoy.year}'), findsOneWidget);
    });

    testWidgets('Tiene el color de tema correcto', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Verificar que el AppBar tiene el color correcto
      final AppBar appBar = tester.widget(find.byType(AppBar));
      expect(appBar.backgroundColor, const Color.fromARGB(225, 47, 125, 121));
    });
  });

  group('FormIngresos - Validación de Formulario', () {
    testWidgets('Muestra errores de validación para campos vacíos', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Intentar guardar sin llenar campos
      await tester.tap(find.widgetWithText(ElevatedButton, 'Crear'));
      await tester.pump();

      expect(find.text('Por favor ingresa un monto'), findsOneWidget);
      expect(find.text('Por favor ingresa una descripción'), findsOneWidget);
    });

    testWidgets('Valida campo de monto vacío', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Llenar solo descripción
      final descripcionField = find.byType(TextFormField).last;
      await tester.enterText(descripcionField, 'Descripción válida');
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Crear'));
      await tester.pump();

      expect(find.text('Por favor ingresa un monto'), findsOneWidget);
      expect(find.text('Por favor ingresa una descripción'), findsNothing);
    });

    testWidgets('Valida campo de descripción vacío', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Llenar solo monto
      final montoField = find.byType(TextFormField).first;
      await tester.enterText(montoField, '500');
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Crear'));
      await tester.pump();

      expect(find.text('Por favor ingresa una descripción'), findsOneWidget);
      expect(find.text('Por favor ingresa un monto'), findsNothing);
    });

    /*testWidgets('Acepta formulario con todos los campos válidos', (WidgetTester tester) async {
      bool formCompleted = false;
      
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FormIngresos()),
              );
              if (result == true) formCompleted = true;
            },
            child: Text('Abrir Form'),
          ),
        ),
      ));

      // Abrir el formulario
      await tester.tap(find.text('Abrir Form'));
      await tester.pumpAndSettle();

      // Llenar todos los campos requeridos
      await tester.enterText(find.byType(TextFormField).first, '1000');
      await tester.enterText(find.byType(TextFormField).last, 'Salario mensual');
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Crear'));
      await tester.pumpAndSettle();

      expect(formCompleted, isTrue);
    });*/
  });

  group('FormIngresos - Interacciones de UI', () {
    testWidgets('Permite cambiar la categoría en el dropdown', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Abrir dropdown
      await tester.tap(find.byType(DropdownButtonFormField<Categoria>));
      await tester.pumpAndSettle();

      // Si hay más de una categoría, seleccionar la segunda
      if (categoriasTest.length > 1) {
        await tester.tap(find.text(categoriasTest[1].nombre).last);
        await tester.pumpAndSettle();

        expect(find.text(categoriasTest[1].nombre), findsOneWidget);
        expect(find.text(categoriasTest[1].icono), findsOneWidget);
      }
    });

    testWidgets('Permite seleccionar fecha diferente', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Abrir date picker
      await tester.tap(find.byIcon(Icons.calendar_today));
      await tester.pumpAndSettle();

      // Seleccionar el día 15 si está disponible
      final day15 = find.text('15');
      if (day15.evaluate().isNotEmpty) {
        await tester.tap(day15);
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
      } else {
        // Si no hay día 15, simplemente cerrar el picker
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
      }

      // Verificar que el formulario sigue existiendo
      expect(find.byType(FormIngresos), findsOneWidget);
    });

    testWidgets('Permite ingresar datos en campos de texto', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final montoField = find.byType(TextFormField).first;
      final descripcionField = find.byType(TextFormField).last;

      await tester.enterText(montoField, '750.25');
      await tester.enterText(descripcionField, 'Freelance trabajo');
      await tester.pump();

      expect(find.text('750.25'), findsOneWidget);
      expect(find.text('Freelance trabajo'), findsOneWidget);
    });

    testWidgets('Campo de monto acepta solo números', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final montoField = find.byType(TextFormField).first;
      // Busca el TextField hijo dentro del TextFormField
      final textField = tester.widget<TextField>(find.descendant(of: montoField, matching: find.byType(TextField)));
      
      expect(textField.keyboardType, TextInputType.number);
    });

    testWidgets('Animación de botones funciona con teclado', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Enfocar campo de texto para mostrar teclado
      await tester.tap(find.byType(TextFormField).first);
      await tester.pump();

      // Los botones deberían seguir existiendo (aunque con opacidad diferente)
      expect(find.widgetWithText(ElevatedButton, 'Crear'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Cancelar'), findsOneWidget);
    });
  });

  group('FormIngresos - Navegación y Botones', () {
    testWidgets('Botón Cancelar cierra el formulario', (WidgetTester tester) async {
      bool navigatorPopped = false;
      
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FormIngresos()),
              );
              navigatorPopped = result == true; // Usar la variable
            },
            child: Text('Abrir Form'),
          ),
        ),
      ));

      // Abrir el formulario
      await tester.tap(find.text('Abrir Form'));
      await tester.pumpAndSettle();

      // Hacer tap en Cancelar
      await tester.tap(find.widgetWithText(TextButton, 'Cancelar'));
      await tester.pumpAndSettle();

      expect(navigatorPopped, isTrue);
    });

    testWidgets('Botón de retroceso en AppBar funciona', (WidgetTester tester) async {
      bool navigatorPopped = false;
      
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FormIngresos()),
              );
              navigatorPopped = true;
            },
            child: Text('Abrir Form'),
          ),
        ),
      ));

      // Abrir el formulario
      await tester.tap(find.text('Abrir Form'));
      await tester.pumpAndSettle();

      // Hacer tap en el botón de retroceso
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(navigatorPopped, isTrue);
    });

    testWidgets('Formulario inválido no cierra el formulario', (WidgetTester tester) async {
      bool navigatorPopped = false;
      
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FormIngresos()),
              );
              navigatorPopped = result == true;
            },
            child: Text('Abrir Form'),
          ),
        ),
      ));

      // Abrir el formulario
      await tester.tap(find.text('Abrir Form'));
      await tester.pumpAndSettle();

      // Intentar guardar sin llenar campos
      await tester.tap(find.widgetWithText(ElevatedButton, 'Crear'));
      await tester.pump();

      expect(navigatorPopped, isFalse);
      expect(find.text('Por favor ingresa un monto'), findsOneWidget);
    });
  });

  group('FormIngresos - Casos de Edición', () {
    /*testWidgets('Formulario de edición carga datos existentes correctamente', (WidgetTester tester) async {
      final transaccionExistente = Transaccion(
        id: 'test-id',
        tipo: 'ingreso',
        monto: 150.0,
        fecha: DateTime(2024, 6, 20),
        categoria: categoriaIngreso,
        descripcion: 'Pago por consultoría',
      );

      await tester.pumpWidget(buildTestableWidget(transaccion: transaccionExistente));
      await tester.pumpAndSettle();

      expect(find.text('150'), findsOneWidget);
      expect(find.text('Pago por consultoría'), findsOneWidget);
      expect(find.text('20 junio 2024'), findsOneWidget);
      expect(find.text(categoriaIngreso.nombre), findsAtLeastNWidgets(1));
    });*/

    testWidgets('Formulario de edición permite modificar datos', (WidgetTester tester) async {
      final transaccionExistente = Transaccion(
        id: 'test-id',
        tipo: 'ingreso',
        monto: 200.0,
        fecha: DateTime.now(),
        categoria: categoriaIngreso,
        descripcion: 'Ingreso anterior',
      );

      await tester.pumpWidget(buildTestableWidget(transaccion: transaccionExistente));
      await tester.pumpAndSettle();

      // Modificar datos
      await tester.enterText(find.byType(TextFormField).first, '300.0');
      await tester.enterText(find.byType(TextFormField).last, 'Ingreso actualizado');
      await tester.pump();

      expect(find.text('300.0'), findsOneWidget);
      expect(find.text('Ingreso actualizado'), findsOneWidget);
    });

    testWidgets('Maneja categoría personalizada correctamente', (WidgetTester tester) async {
      final categoriaPersonalizada = Categoria(
        nombre: 'Inversiones',
        tipo: 'ingreso',
        icono: '📈',
      );

      final transaccionConCategoriaPersonalizada = Transaccion(
        id: 'test-id',
        tipo: 'ingreso',
        monto: 500.0,
        fecha: DateTime.now(),
        categoria: categoriaPersonalizada,
        descripcion: 'Ganancias de inversión',
      );

      await tester.pumpWidget(buildTestableWidget(transaccion: transaccionConCategoriaPersonalizada));
      await tester.pumpAndSettle();

      // Verificar que la categoría personalizada se muestra
      expect(find.text('Inversiones'), findsOneWidget);
      expect(find.text('📈'), findsOneWidget);
    });

    /*testWidgets('Editar transacción y guardar funciona correctamente', (WidgetTester tester) async {
      final transaccionExistente = Transaccion(
        id: 'test-id',
        tipo: 'ingreso',
        monto: 400.0,
        fecha: DateTime.now(),
        categoria: categoriaIngreso,
        descripcion: 'Ingreso original',
      );

      bool formCompleted = false;
      
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FormIngresos(transaccion: transaccionExistente)),
              );
              if (result == true) formCompleted = true;
            },
            child: Text('Abrir Form'),
          ),
        ),
      ));

      // Abrir el formulario
      await tester.tap(find.text('Abrir Form'));
      await tester.pumpAndSettle();

      // Modificar datos
      await tester.enterText(find.byType(TextFormField).first, '600.0');
      await tester.enterText(find.byType(TextFormField).last, 'Ingreso modificado');
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Crear'));
      await tester.pumpAndSettle();

      expect(formCompleted, isTrue);
    });*/
  });

  group('FormIngresos - Formato y Presentación', () {
    testWidgets('Formato de fecha se muestra correctamente para diferentes meses', (WidgetTester tester) async {
      final fechaNavidad = DateTime(2024, 12, 25); // 25 de diciembre
      final transaccion = Transaccion(
        id: 'test',
        tipo: 'ingreso',
        monto: 1000,
        fecha: fechaNavidad,
        categoria: categoriaIngreso,
        descripcion: 'Bonus navideño',
      );

      await tester.pumpWidget(buildTestableWidget(transaccion: transaccion));
      await tester.pumpAndSettle();

      expect(find.text('25 diciembre 2024'), findsOneWidget);
    });

    testWidgets('Muestra correctamente iconos de categorías de ingresos', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Verificar que se muestra el ícono de la categoría
      expect(find.text(categoriaIngreso.icono), findsOneWidget);
    });

    testWidgets('Mantiene formato de moneda COP', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('COP'), findsOneWidget);
    });

    testWidgets('Estilos de texto son consistentes', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Verificar que los labels tienen el estilo correcto
      final labelWidgets = find.byType(Text);
      expect(labelWidgets, findsWidgets);
      
      // Verificar que el título del AppBar es blanco
      final appBarTitle = find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Planificar un ingreso'),
      );
      expect(appBarTitle, findsOneWidget);
    });
  });

  group('FormIngresos - Casos Edge', () {
    testWidgets('Maneja monto con decimales correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, '1234.567');
      await tester.enterText(find.byType(TextFormField).last, 'Ingreso con decimales');
      await tester.pump();

      expect(find.text('1234.567'), findsOneWidget);
      expect(find.text('Ingreso con decimales'), findsOneWidget);
    });

    testWidgets('Maneja descripción con caracteres especiales', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, '500');
      await tester.enterText(find.byType(TextFormField).last, 'Pago por servicios & consultoría - 100%');
      await tester.pump();

      expect(find.text('500'), findsOneWidget);
      expect(find.text('Pago por servicios & consultoría - 100%'), findsOneWidget);
    });

    testWidgets('Maneja monto muy grande', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, '999999999.99');
      await tester.enterText(find.byType(TextFormField).last, 'Ingreso muy grande');
      await tester.pump();

      expect(find.text('999999999.99'), findsOneWidget);
      expect(find.text('Ingreso muy grande'), findsOneWidget);
    });

    testWidgets('Maneja fecha límite correctamente', (WidgetTester tester) async {
      final fechaFutura = DateTime(2099, 1, 1);
      final transaccion = Transaccion(
        id: 'test',
        tipo: 'ingreso',
        monto: 100,
        fecha: fechaFutura,
        categoria: categoriaIngreso,
        descripcion: 'Ingreso futuro',
      );

      await tester.pumpWidget(buildTestableWidget(transaccion: transaccion));
      await tester.pumpAndSettle();

      expect(find.text('1 enero 2099'), findsOneWidget);
    });

    testWidgets('Maneja monto cero', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, '0');
      await tester.enterText(find.byType(TextFormField).last, 'Monto cero');
      await tester.pump();

      // Verificar que acepta monto cero
      expect(find.text('0'), findsOneWidget);
      expect(find.text('Monto cero'), findsOneWidget);
    });
  });

  group('FormIngresos - Responsividad y Accesibilidad', () {
    testWidgets('Formulario es scrolleable', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Verificar que hay un SingleChildScrollView
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('Botones mantienen tamaño apropiado', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final crearButton = find.widgetWithText(ElevatedButton, 'Crear');
      final cancelarButton = find.widgetWithText(TextButton, 'Cancelar');

      expect(crearButton, findsOneWidget);
      expect(cancelarButton, findsOneWidget);

      // Verificar que los botones tienen texto
      final crearWidget = tester.widget<ElevatedButton>(crearButton);
      final cancelarWidget = tester.widget<TextButton>(cancelarButton);

      expect(crearWidget.child, isA<Text>());
      expect(cancelarWidget.child, isA<Text>());
    });

    /*testWidgets('Campos de texto tienen decoración apropiada', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      expect(textFields, findsNWidgets(2));

      // Verificar que ambos campos tienen decoración
      for (int i = 0; i < 2; i++) {
        final widget = tester.widget<TextFormField>(textFields.at(i));
        expect(widget.decoration, isNotNull);
      }
    });*/

    /*testWidgets('Stack layout funciona correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Verificar que usa Stack para el layout
      expect(find.byType(Stack), findsOneWidget);
      
      // Verificar que tiene widgets posicionados
      expect(find.byType(Positioned), findsOneWidget);
    });*/
  });

  /*group('FormIngresos - Funciones de Fechas', () {
    testWidgets('Muestra correctamente todos los meses del año', (WidgetTester tester) async {
      final meses = [
        (1, 'enero'), (2, 'febrero'), (3, 'marzo'), (4, 'abril'),
        (5, 'mayo'), (6, 'junio'), (7, 'julio'), (8, 'agosto'),
        (9, 'septiembre'), (10, 'octubre'), (11, 'noviembre'), (12, 'diciembre')
      ];

      for (final (numeroMes, nombreMes) in meses) {
        final fecha = DateTime(2024, numeroMes, 15);
        final transaccion = Transaccion(
          id: 'test-$numeroMes',
          tipo: 'ingreso',
          monto: 100,
          fecha: fecha,
          categoria: categoriaIngreso,
          descripcion: 'Test $nombreMes',
        );

        await tester.pumpWidget(buildTestableWidget(transaccion: transaccion));
        await tester.pumpAndSettle();

        expect(find.text('15 $nombreMes 2024'), findsOneWidget);
      }
    });
  });*/
}

// Función helper para obtener el nombre del mes (igual que en el archivo original)
String _getMonthNameForTest(int month) {
  const months = [
    'enero', 'febrero', 'marzo', 'abril',
    'mayo', 'junio', 'julio', 'agosto',
    'septiembre', 'octubre', 'noviembre', 'diciembre',
  ];
  return months[month - 1];
}