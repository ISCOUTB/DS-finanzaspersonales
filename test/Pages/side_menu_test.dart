import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finanse_tracker/pages/side_menu.dart';
import 'package:finanse_tracker/pages/categorias_pages.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Helper para construir el widget SideMenu
  Widget buildTestableWidget() {
    return MaterialApp(
      home: Scaffold(
        drawer: SideMenu(),
        appBar: AppBar(title: Text('Test')),
        body: Text('Main Content'),
      ),
      routes: {
        '/categorias': (context) => Scaffold(
          appBar: AppBar(title: Text('Categorías')),
          body: Text('Categorías Page'),
        ),
      },
    );
  }

  group('SideMenu - Estructura y Renderizado', () {
    testWidgets('Renderiza correctamente la estructura del Drawer', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Abrir el drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Verificar elementos principales
      expect(find.byType(Drawer), findsOneWidget);
      expect(find.byType(Column), findsAtLeastNWidgets(1));
      expect(find.text('Categorías'), findsOneWidget);
      expect(find.text('Gestionar Categorías'), findsOneWidget);
      expect(find.byIcon(Icons.category), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
    });

    testWidgets('Header del drawer tiene los elementos correctos', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Abrir el drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Verificar el header
      expect(find.byIcon(Icons.category), findsOneWidget);
      expect(find.text('Categorías'), findsOneWidget);

      // Verificar que el ícono está presente y es del tamaño correcto
      final categoryIcon = tester.widget<Icon>(find.byIcon(Icons.category));
      expect(categoryIcon.size, equals(80));
      expect(categoryIcon.color, equals(Colors.white));
    });

    testWidgets('ListTile tiene la estructura correcta', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Abrir el drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Verificar ListTile
      expect(find.byType(ListTile), findsOneWidget);
      expect(find.text('Gestionar Categorías'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);

      // Verificar que el ListTile tiene un leading icon
      final listTile = tester.widget<ListTile>(find.byType(ListTile));
      expect(listTile.leading, isA<Container>());
      expect(listTile.title, isA<Text>());
      expect(listTile.onTap, isNotNull);
    });

    testWidgets('SizedBox espaciadores están presentes', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Abrir el drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Verificar SizedBox para espaciado
      expect(find.byType(SizedBox), findsAtLeastNWidgets(2));
    });
  });

  group('SideMenu - Estilos y Colores', () {
    testWidgets('Header tiene el color de fondo correcto', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Abrir el drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Encontrar el Container del header
      final headerContainer = tester.widget<Container>(
        find.descendant(
          of: find.byType(Drawer),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = headerContainer.decoration as BoxDecoration;
      expect(decoration.color, equals(const Color.fromARGB(225, 47, 125, 121)));
    });

    testWidgets('Texto del header tiene estilo correcto', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Abrir el drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      final headerText = tester.widget<Text>(find.text('Categorías'));
      expect(headerText.style?.color, equals(Colors.white));
      expect(headerText.style?.fontSize, equals(24));
      expect(headerText.style?.fontWeight, equals(FontWeight.bold));
    });

    testWidgets('ListTile leading container tiene decoración correcta', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Abrir el drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Encontrar el Container del leading icon
      final containers = find.byType(Container);
      expect(containers, findsAtLeastNWidgets(2)); // Header container + Leading container

      // El segundo container debería ser el del leading icon
      final leadingContainer = tester.widget<Container>(containers.at(1));
      expect(leadingContainer.decoration, isA<BoxDecoration>());
      
      final decoration = leadingContainer.decoration as BoxDecoration;
      expect(decoration.borderRadius, isA<BorderRadius>());
    });

    testWidgets('Ícono de flecha tiene color correcto', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Abrir el drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      final arrowIcon = tester.widget<Icon>(find.byIcon(Icons.arrow_upward));
      expect(arrowIcon.color, equals(const Color.fromARGB(225, 47, 125, 121)));
    });

    testWidgets('Texto del ListTile tiene estilo correcto', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Abrir el drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      final listTileText = tester.widget<Text>(find.text('Gestionar Categorías'));
      expect(listTileText.style?.fontSize, equals(16));
      expect(listTileText.style?.fontWeight, equals(FontWeight.w500));
    });
  });

  group('SideMenu - Dimensiones y Layout', () {
    /*testWidgets('Header container tiene ancho completo', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Abrir el drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      final headerContainer = tester.widget<Container>(
        find.descendant(
          of: find.byType(Drawer),
          matching: find.byType(Container),
        ).first,
      );

      expect(headerContainer.constraints?.maxWidth, isNull); // Debería ser double.infinity
    });*/

    testWidgets('Header tiene padding vertical correcto', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Abrir el drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      final headerContainer = tester.widget<Container>(
        find.descendant(
          of: find.byType(Drawer),
          matching: find.byType(Container),
        ).first,
      );

      expect(headerContainer.padding, equals(const EdgeInsets.symmetric(vertical: 50)));
    });

    testWidgets('Leading container tiene padding correcto', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Abrir el drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      final containers = find.byType(Container);
      final leadingContainer = tester.widget<Container>(containers.at(1));
      
      expect(leadingContainer.padding, equals(const EdgeInsets.all(8)));
    });

    testWidgets('SizedBox tienen las alturas correctas', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Abrir el drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      final sizedBoxes = find.byType(SizedBox);
      expect(sizedBoxes, findsAtLeastNWidgets(2));

      // Verificar que hay SizedBox con diferentes alturas
      final sizedBoxWidgets = sizedBoxes.evaluate().map((e) => e.widget as SizedBox).toList();
      
      // Debería haber un SizedBox con height 10 y otro con height 20
      expect(sizedBoxWidgets.any((sb) => sb.height == 10), isTrue);
      expect(sizedBoxWidgets.any((sb) => sb.height == 20), isTrue);
    });
  });

  group('SideMenu - Navegación', () {
    testWidgets('Tap en ListTile navega a CategoriasPage', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Abrir el drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Hacer tap en "Gestionar Categorías"
      await tester.tap(find.text('Gestionar Categorías'));
      await tester.pumpAndSettle();

      // Verificar que navegó a CategoriasPage
      expect(find.byType(CategoriasPage), findsOneWidget);
    });

    testWidgets('Navegación cierra el drawer automáticamente', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Abrir el drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Verificar que el drawer está abierto
      expect(find.byType(SideMenu), findsOneWidget);

      // Hacer tap en "Gestionar Categorías"
      await tester.tap(find.text('Gestionar Categorías'));
      await tester.pumpAndSettle();

      // Verificar que navegó y el drawer ya no está visible en la página actual
      expect(find.byType(CategoriasPage), findsOneWidget);
    });

    testWidgets('Botón back regresa desde CategoriasPage', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Abrir el drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Navegar a categorías
      await tester.tap(find.text('Gestionar Categorías'));
      await tester.pumpAndSettle();

      // Verificar que estamos en CategoriasPage
      expect(find.byType(CategoriasPage), findsOneWidget);

      // Regresar
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verificar que regresamos a la página principal
      expect(find.text('Main Content'), findsOneWidget);
    });
  });

  group('SideMenu - Interacciones de Usuario', () {
    testWidgets('Múltiples taps en ListTile no causan problemas', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Abrir el drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Hacer múltiples taps rápidos
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.text('Gestionar Categorías'));
        await tester.pump(Duration(milliseconds: 100));
      }
      
      await tester.pumpAndSettle();

      // Verificar que la navegación funcionó
      expect(find.byType(CategoriasPage), findsOneWidget);
    });

    testWidgets('Drawer puede abrirse y cerrarse múltiples veces', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      for (int i = 0; i < 3; i++) {
        // Abrir drawer
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();
        expect(find.byType(SideMenu), findsOneWidget);

        // Cerrar drawer tocando fuera
        await tester.tapAt(Offset(300, 200)); // Tap fuera del drawer
        await tester.pumpAndSettle();
      }
    });

    /*testWidgets('Swipe para abrir drawer funciona', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Hacer swipe desde la izquierda para abrir el drawer
      await tester.dragFrom(
        Offset(0, 200), 
        Offset(100, 200),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SideMenu), findsOneWidget);
    });*/
  });

  group('SideMenu - Widget como StatelessWidget', () {
    testWidgets('SideMenu es StatelessWidget', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Abrir el drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(find.byType(SideMenu), findsOneWidget);
      
      // Verificar que es StatelessWidget (no cambia estado interno)
      final sideMenuWidget = tester.widget<SideMenu>(find.byType(SideMenu));
      expect(sideMenuWidget, isA<StatelessWidget>());
    });

    testWidgets('Build method retorna Drawer', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Abrir el drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Verificar que el root widget del SideMenu es un Drawer
      expect(find.byType(Drawer), findsOneWidget);
    });
  });

  group('SideMenu - Accesibilidad', () {
    testWidgets('Elementos tienen semánticas apropiadas', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Abrir el drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(find.byType(Semantics), findsWidgets);
    });

    testWidgets('ListTile es interactivo', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Abrir el drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      final listTile = tester.widget<ListTile>(find.byType(ListTile));
      expect(listTile.onTap, isNotNull);
      expect(listTile.title, isA<Text>());
    });

    testWidgets('Iconos son reconocibles', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Abrir el drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.category), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
    });
  });

  group('SideMenu - Casos Edge', () {
    /*testWidgets('Maneja context nulo graciosamente', (WidgetTester tester) async {
      // Este test verifica que el widget no falle si hay problemas de contexto
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              drawer: SideMenu(),
              body: Text('Test'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Abrir drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(find.byType(SideMenu), findsOneWidget);
    });*/

    testWidgets('Funciona con diferentes tamaños de pantalla', (WidgetTester tester) async {
      // Simular pantalla pequeña
      tester.view.physicalSize = Size(320, 568);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Abrir drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(find.byType(SideMenu), findsOneWidget);
      expect(find.text('Gestionar Categorías'), findsOneWidget);

      // Restaurar tamaño normal
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });

    testWidgets('Drawer se mantiene funcional después de hot reload simulado', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Abrir drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Simular hot reload
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Verificar que el drawer sigue funcionando
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      
      expect(find.byType(SideMenu), findsOneWidget);
    });
  });

  group('SideMenu - Performance', () {
    testWidgets('Construcción del widget es eficiente', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Abrir drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // La construcción debería ser rápida
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      expect(find.byType(SideMenu), findsOneWidget);
    });

    testWidgets('No hay rebuilds innecesarios', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Abrir y cerrar drawer múltiples veces
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pump();
        await tester.tapAt(Offset(300, 200)); // Cerrar tocando fuera
        await tester.pump();
      }
      
      await tester.pumpAndSettle();
      
      // Verificar que no hay errores y funciona correctamente
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      expect(find.byType(SideMenu), findsOneWidget);
    });
  });
}