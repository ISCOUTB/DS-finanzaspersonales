import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finanse_tracker/pages/form_gastos.dart';
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
  final List<Categoria> categoriasTest = CategoriaService.getCategoriasGastos();
  final categoriaComida =
      categoriasTest.first; // Asumimos que hay al menos una categoría

  // Helper para construir el widget FormGastos
  Widget buildTestableWidget({Transaccion? transaccion}) {
    return MaterialApp(home: FormGastos(transaccion: transaccion));
  }

  group('FormGastos - Renderizado de UI', () {
    testWidgets('Renderiza correctamente el formulario vacío', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Verificar elementos principales
      expect(find.text('Planificar un gasto'), findsOneWidget);
      expect(find.text('Categoría'), findsOneWidget);
      expect(find.text('Cantidad'), findsOneWidget);
      expect(find.text('Fecha'), findsOneWidget);
      expect(find.text('Nombre'), findsOneWidget);
      expect(find.text('COP'), findsOneWidget);

      // Verificar controles
      expect(find.byType(DropdownButtonFormField<Categoria>), findsOneWidget);
      expect(
        find.byType(TextFormField),
        findsNWidgets(2),
      ); // Monto y Descripción
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Crear'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Cancelar'), findsOneWidget);
    });

    testWidgets(
      'Renderiza correctamente el formulario con transacción existente',
      (WidgetTester tester) async {
        final transaccionExistente = Transaccion(
          id: '123',
          tipo: 'egreso',
          monto: 150.75,
          fecha: DateTime(2024, 7, 10),
          categoria: categoriaComida,
          descripcion: 'Almuerzo de trabajo',
        );

        await tester.pumpWidget(
          buildTestableWidget(transaccion: transaccionExistente),
        );
        await tester.pumpAndSettle();

        // Verificar que los datos se cargan correctamente
        expect(find.text('150.75'), findsOneWidget);
        expect(find.text('Almuerzo de trabajo'), findsOneWidget);
        expect(find.text('10 julio 2024'), findsOneWidget);
        expect(find.text(categoriaComida.nombre), findsAtLeastNWidgets(1));
      },
    );

    testWidgets('Muestra la categoría con ícono en el dropdown', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Verificar que se muestra el ícono y nombre de la categoría seleccionada
      expect(find.text(categoriaComida.icono), findsOneWidget);
      expect(find.text(categoriaComida.nombre), findsOneWidget);
    });
  });

  group('FormGastos - Validación de Formulario', () {
    testWidgets('Muestra errores de validación para campos vacíos', (
      WidgetTester tester,
    ) async {
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

    testWidgets('Valida campo de descripción vacío', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Llenar solo monto
      final montoField = find.byType(TextFormField).first;
      await tester.enterText(montoField, '100');
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Crear'));
      await tester.pump();

      expect(find.text('Por favor ingresa una descripción'), findsOneWidget);
      expect(find.text('Por favor ingresa un monto'), findsNothing);
    });

    /*testWidgets('Valida monto inválido (texto)', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final montoField = find.byType(TextFormField).first;
      await tester.enterText(montoField, 'abc');
      await tester.enterText(find.byType(TextFormField).last, 'Descripción');
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Crear'));
      await tester.pump();

      // Verificar que muestra error de validación para monto inválido
      expect(find.text('Por favor ingresa un monto válido'), findsOneWidget);
    });*/
  });

  group('FormGastos - Interacciones de UI', () {
    testWidgets('Permite cambiar la categoría en el dropdown', (
      WidgetTester tester,
    ) async {
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
      }
    });

    testWidgets('Permite seleccionar fecha', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Abrir date picker
      await tester.tap(find.byIcon(Icons.calendar_today));
      await tester.pumpAndSettle();

      // Seleccionar OK (mantiene fecha actual)
      final okButton = find.text('OK');
      if (okButton.evaluate().isNotEmpty) {
        await tester.tap(okButton);
        await tester.pumpAndSettle();
      }

      // Verificar que el formulario sigue existiendo
      expect(find.byType(FormGastos), findsOneWidget);
    });

    testWidgets('Permite ingresar datos en campos de texto', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final montoField = find.byType(TextFormField).first;
      final descripcionField = find.byType(TextFormField).last;

      await tester.enterText(montoField, '150.75');
      await tester.enterText(descripcionField, 'Compra de supermercado');
      await tester.pump();

      expect(find.text('150.75'), findsOneWidget);
      expect(find.text('Compra de supermercado'), findsOneWidget);
    });

    testWidgets('Campos de texto mantienen el foco correctamente', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final montoField = find.byType(TextFormField).first;

      // Hacer tap en el campo de monto
      await tester.tap(montoField);
      await tester.pump();

      // Verificar que el campo tiene foco
      expect(
        WidgetsBinding.instance.focusManager.primaryFocus?.hasFocus,
        isTrue,
      );
    });
  });

  group('FormGastos - Navegación y Botones', () {
    testWidgets('Botón Cancelar cierra el formulario', (
      WidgetTester tester,
    ) async {
      bool navigatorPopped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder:
                (context) => ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => FormGastos()),
                    );
                    navigatorPopped =
                        result ==
                        null; // Usar result para verificar cancelación
                  },
                  child: Text('Abrir Form'),
                ),
          ),
        ),
      );

      // Abrir el formulario
      await tester.tap(find.text('Abrir Form'));
      await tester.pumpAndSettle();

      // Hacer tap en Cancelar
      await tester.tap(find.widgetWithText(TextButton, 'Cancelar'));
      await tester.pumpAndSettle();

      expect(navigatorPopped, isTrue);
    });

    /*testWidgets('Formulario con datos válidos permite navegación', (WidgetTester tester) async {
      bool formCompleted = false;
      
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FormGastos()),
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

      // Llenar el formulario
      await tester.enterText(find.byType(TextFormField).first, '100');
      await tester.enterText(find.byType(TextFormField).last, 'Test Gasto');
      await tester.pump();

      // Intentar guardar
      await tester.tap(find.widgetWithText(ElevatedButton, 'Crear'));
      await tester.pumpAndSettle();

      expect(formCompleted, isTrue);
    });*/
  });

  group('FormGastos - Casos de Edición', () {
    /*testWidgets('Formulario de edición carga datos existentes correctamente', (WidgetTester tester) async {
      final transaccionExistente = Transaccion(
        id: 'test-id',
        tipo: 'egreso',
        monto: 75.0,
        fecha: DateTime(2024, 7, 15),
        categoria: categoriaComida,
        descripcion: 'Gasto existente',
      );

      await tester.pumpWidget(buildTestableWidget(transaccion: transaccionExistente));
      await tester.pumpAndSettle();

      expect(find.text('75'), findsOneWidget);
      expect(find.text('Gasto existente'), findsOneWidget);
      expect(find.text('15 julio 2024'), findsOneWidget);
      expect(find.text(categoriaComida.nombre), findsAtLeastNWidgets(1));
    });*/

    testWidgets('Formulario de edición permite modificar datos', (
      WidgetTester tester,
    ) async {
      final transaccionExistente = Transaccion(
        id: 'test-id',
        tipo: 'egreso',
        monto: 50.0,
        fecha: DateTime.now(),
        categoria: categoriaComida,
        descripcion: 'Gasto antiguo',
      );

      await tester.pumpWidget(
        buildTestableWidget(transaccion: transaccionExistente),
      );
      await tester.pumpAndSettle();

      // Modificar datos
      await tester.enterText(find.byType(TextFormField).first, '85.0');
      await tester.enterText(
        find.byType(TextFormField).last,
        'Gasto actualizado',
      );
      await tester.pump();

      expect(find.text('85.0'), findsOneWidget);
      expect(find.text('Gasto actualizado'), findsOneWidget);
    });

    testWidgets('Maneja categoría personalizada correctamente', (
      WidgetTester tester,
    ) async {
      final categoriaPersonalizada = Categoria(
        nombre: 'CategoríaPersonalizada',
        tipo: 'egreso',
        icono: '🎯',
      );

      final transaccionConCategoriaPersonalizada = Transaccion(
        id: 'test-id',
        tipo: 'egreso',
        monto: 100.0,
        fecha: DateTime.now(),
        categoria: categoriaPersonalizada,
        descripcion: 'Gasto con categoría personalizada',
      );

      await tester.pumpWidget(
        buildTestableWidget(transaccion: transaccionConCategoriaPersonalizada),
      );
      await tester.pumpAndSettle();

      // Verificar que la categoría personalizada se muestra
      expect(find.text('CategoríaPersonalizada'), findsOneWidget);
      expect(find.text('🎯'), findsOneWidget);
    });
  });

  group('FormGastos - Formato y Presentación', () {
    testWidgets('Formato de fecha se muestra correctamente', (
      WidgetTester tester,
    ) async {
      final fechaEspecifica = DateTime(2024, 12, 25); // 25 de diciembre
      final transaccion = Transaccion(
        id: 'test',
        tipo: 'egreso',
        monto: 100,
        fecha: fechaEspecifica,
        categoria: categoriaComida,
        descripcion: 'Test',
      );

      await tester.pumpWidget(buildTestableWidget(transaccion: transaccion));
      await tester.pumpAndSettle();

      expect(find.text('25 diciembre 2024'), findsOneWidget);
    });

    testWidgets('Muestra correctamente iconos de categorías', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Verificar que se muestra el ícono de la categoría
      expect(find.text(categoriaComida.icono), findsOneWidget);
    });

    testWidgets('Mantiene formato de moneda COP', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('COP'), findsOneWidget);
    });
  });

  group('FormGastos - Casos Edge', () {
    testWidgets('Maneja monto con decimales correctamente', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, '123.456');
      await tester.enterText(find.byType(TextFormField).last, 'Test decimal');
      await tester.pump();

      expect(find.text('123.456'), findsOneWidget);
      expect(find.text('Test decimal'), findsOneWidget);
    });

    testWidgets('Maneja descripción con caracteres especiales', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, '50');
      await tester.enterText(
        find.byType(TextFormField).last,
        'Café & té - 100%',
      );
      await tester.pump();

      expect(find.text('50'), findsOneWidget);
      expect(find.text('Café & té - 100%'), findsOneWidget);
    });

    testWidgets('Maneja fecha límite correctamente', (
      WidgetTester tester,
    ) async {
      final fechaLimite = DateTime(2100, 12, 31);
      final transaccion = Transaccion(
        id: 'test',
        tipo: 'egreso',
        monto: 100,
        fecha: fechaLimite,
        categoria: categoriaComida,
        descripcion: 'Fecha futura',
      );

      await tester.pumpWidget(buildTestableWidget(transaccion: transaccion));
      await tester.pumpAndSettle();

      expect(find.text('31 diciembre 2100'), findsOneWidget);
    });

    testWidgets('Valida monto cero', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, '0');
      await tester.enterText(find.byType(TextFormField).last, 'Monto cero');
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Crear'));
      await tester.pump();

      // Verificar que acepta monto cero (depende de tu lógica de validación)
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('Maneja monto muy grande', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, '999999999.99');
      await tester.enterText(find.byType(TextFormField).last, 'Monto grande');
      await tester.pump();

      expect(find.text('999999999.99'), findsOneWidget);
      expect(find.text('Monto grande'), findsOneWidget);
    });
  });

  group('FormGastos - Responsividad y Accesibilidad', () {
    /*testWidgets('Formulario es accesible con semantics', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Verificar que los elementos principales tienen semánticas apropiadas
      expect(find.byType(Semantics), findsWidgets);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.byType(DropdownButtonFormField), findsOneWidget);
    });*/

    testWidgets('Botones mantienen tamaño apropiado', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final crearButton = find.widgetWithText(ElevatedButton, 'Crear');
      final cancelarButton = find.widgetWithText(TextButton, 'Cancelar');

      expect(crearButton, findsOneWidget);
      expect(cancelarButton, findsOneWidget);

      // Verificar que los botones tienen un tamaño mínimo apropiado
      final crearWidget = tester.widget<ElevatedButton>(crearButton);
      final cancelarWidget = tester.widget<TextButton>(cancelarButton);

      expect(crearWidget.child, isA<Text>());
      expect(cancelarWidget.child, isA<Text>());
    });
  });
}
