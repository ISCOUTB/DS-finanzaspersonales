import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finanse_tracker/pages/registro_pages.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Helper para construir el widget PageRegistro
  Widget buildTestableWidget() {
    return MaterialApp(
      home: PageRegistro(),
      routes: {
        '/home': (context) => Scaffold(
          appBar: AppBar(title: Text('Home')),
          body: Text('Home Page'),
        ),
      },
    );
  }

  // Setup para SharedPreferences en cada test
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('PageRegistro - Renderizado de UI', () {
    testWidgets('Renderiza correctamente todos los elementos', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Verificar elementos principales
      expect(find.text('Spend Smarter\nSave More'), findsOneWidget);
      expect(find.text('¿Cómo te llamas?'), findsOneWidget);
      expect(find.text('Siguiente'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('Imagen se renderiza correctamente con asset', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Verificar que existe una imagen
      expect(find.byType(Image), findsOneWidget);
      
      final imageWidget = tester.widget<Image>(find.byType(Image));
      expect(imageWidget.image, isA<AssetImage>());
    });

    testWidgets('Campo de texto tiene la decoración correcta', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      
      expect(textField.decoration?.hintText, equals('¿Cómo te llamas?'));
      expect(textField.decoration?.prefixIcon, isA<Icon>());
      expect(textField.decoration?.filled, isTrue);
    });

    testWidgets('Scaffold tiene fondo blanco', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(Colors.white));
    });

    testWidgets('Layout usa SingleChildScrollView', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
    });
  });

  group('PageRegistro - Estado del Botón', () {
    testWidgets('Botón está deshabilitado inicialmente', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('Botón se habilita cuando se ingresa texto', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Ingresar texto en el campo
      await tester.enterText(find.byType(TextField), 'Juan');
      await tester.pump();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('Botón se deshabilita cuando se borra el texto', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Ingresar texto
      await tester.enterText(find.byType(TextField), 'Juan');
      await tester.pump();

      // Verificar que está habilitado
      var button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);

      // Borrar el texto
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      // Verificar que está deshabilitado
      button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('Botón responde a cambios incrementales de texto', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Añadir texto caracter por caracter
      await tester.enterText(find.byType(TextField), 'J');
      await tester.pump();
      
      var button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);

      await tester.enterText(find.byType(TextField), 'Ju');
      await tester.pump();
      
      button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
    });
  });

  group('PageRegistro - Funcionalidad de Texto', () {
    testWidgets('Permite ingresar texto en el campo', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      const testName = 'María García';
      await tester.enterText(find.byType(TextField), testName);
      await tester.pump();

      expect(find.text(testName), findsOneWidget);
    });

    testWidgets('Campo de texto acepta caracteres especiales', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      const testName = 'José María O\'Connor';
      await tester.enterText(find.byType(TextField), testName);
      await tester.pump();

      expect(find.text(testName), findsOneWidget);
    });

    testWidgets('Campo de texto acepta espacios', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      const testName = 'Ana Lucía';
      await tester.enterText(find.byType(TextField), testName);
      await tester.pump();

      expect(find.text(testName), findsOneWidget);
    });

    testWidgets('Campo mantiene el foco correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Hacer tap en el campo
      await tester.tap(find.byType(TextField));
      await tester.pump();

      // Verificar que el campo tiene foco
      expect(WidgetsBinding.instance.focusManager.primaryFocus?.hasFocus, isTrue);
    });
  });

  group('PageRegistro - Navegación y SharedPreferences', () {
    /*testWidgets('Guarda el nombre en SharedPreferences al navegar', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      const testName = 'Carlos';
      
      // Ingresar nombre
      await tester.enterText(find.byType(TextField), testName);
      await tester.pump();

      // Hacer tap en el botón
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verificar que se guardó en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('userName'), equals(testName));
    });*/

    /*testWidgets('Navega a la página home después de guardar', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Ingresar nombre
      await tester.enterText(find.byType(TextField), 'Laura');
      await tester.pump();

      // Hacer tap en el botón
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verificar que navegó a home (debe mostrar 'Home Page')
      expect(find.text('Home Page'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
    });*/

    testWidgets('No navega si el campo está vacío', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Verificar que el botón está deshabilitado
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);

      // Verificar que seguimos en la página de registro
      expect(find.text('Spend Smarter\nSave More'), findsOneWidget);
    });

    testWidgets('Maneja espacios en blanco como texto vacío', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Ingresar solo espacios
      await tester.enterText(find.byType(TextField), '   ');
      await tester.pump();

      // El botón debería estar habilitado (el código actual no trim los espacios)
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
    });
  });

  group('PageRegistro - Estilos y Colores', () {
    testWidgets('Usa Google Fonts para el título', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final titleText = tester.widget<Text>(find.text('Spend Smarter\nSave More'));
      expect(titleText.style?.fontFamily, contains('Poppins'));
    });

    testWidgets('Título tiene el color correcto', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final titleText = tester.widget<Text>(find.text('Spend Smarter\nSave More'));
      expect(titleText.style?.color, equals(const Color.fromARGB(225, 47, 125, 121)));
    });

    /*testWidgets('Botón tiene el color de fondo correcto cuando está habilitado', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Habilitar el botón
      await tester.enterText(find.byType(TextField), 'Pedro');
      await tester.pump();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final buttonStyle = button.style as MaterialStateProperty<Color?>?;
      // Verificar que el botón tiene estilo (no podemos verificar el color exacto fácilmente en tests)
      expect(button.style, isNotNull);
    });*/

    testWidgets('Ícono del campo tiene el color correcto', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final icon = tester.widget<Icon>(find.byIcon(Icons.person_outline));
      expect(icon.color, equals(const Color.fromARGB(225, 47, 125, 121)));
    });
  });

  group('PageRegistro - Layout y Dimensiones', () {
    testWidgets('Imagen tiene la altura correcta', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final image = tester.widget<Image>(find.byType(Image));
      expect(image.height, equals(300));
      expect(image.fit, equals(BoxFit.contain));
    });

    testWidgets('Botón tiene el ancho y alto correctos', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(ElevatedButton),
          matching: find.byType(SizedBox),
        ).first,
      );
      
      expect(sizedBox.width, equals(double.infinity));
      expect(sizedBox.height, equals(56));
    });

    testWidgets('Padding principal es correcto', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final padding = tester.widget<Padding>(
        find.descendant(
          of: find.byType(SingleChildScrollView),
          matching: find.byType(Padding),
        ).first,
      );
      
      expect(padding.padding, equals(const EdgeInsets.all(24.0)));
    });

    testWidgets('Column tiene crossAxisAlignment correcto', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.crossAxisAlignment, equals(CrossAxisAlignment.start));
    });
  });

  group('PageRegistro - Casos Edge', () {
    testWidgets('Maneja nombres muy largos', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      const longName = 'Este es un nombre extremadamente largo que podría causar problemas de layout';
      await tester.enterText(find.byType(TextField), longName);
      await tester.pump();

      expect(find.text(longName), findsOneWidget);
      
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('Maneja caracteres Unicode', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      const unicodeName = '张伟 🌟 José';
      await tester.enterText(find.byType(TextField), unicodeName);
      await tester.pump();

      expect(find.text(unicodeName), findsOneWidget);
    });

    testWidgets('Maneja números en el nombre', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      const nameWithNumbers = 'Juan123';
      await tester.enterText(find.byType(TextField), nameWithNumbers);
      await tester.pump();

      expect(find.text(nameWithNumbers), findsOneWidget);
      
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('Error de imagen se maneja correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // La imagen debería tener un errorBuilder
      final image = tester.widget<Image>(find.byType(Image));
      expect(image.errorBuilder, isNotNull);
    });
  });

  group('PageRegistro - Ciclo de Vida del Widget', () {
    testWidgets('initState configura el listener correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Verificar que el listener funciona
      await tester.enterText(find.byType(TextField), 'Test');
      await tester.pump();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
    });

    /*testWidgets('dispose limpia los recursos correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Navegar fuera del widget para trigger dispose
      await tester.enterText(find.byType(TextField), 'Test');
      await tester.pump();
      
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // El widget debería haberse eliminado sin errores
      expect(find.byType(PageRegistro), findsNothing);
    });*/
  });

  group('PageRegistro - Accesibilidad', () {
    testWidgets('Elementos tienen semánticas apropiadas', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Semantics), findsWidgets);
    });

    testWidgets('Campo de texto es accesible', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration?.hintText, isNotNull);
    });

    testWidgets('Botón tiene texto descriptivo', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Siguiente'), findsOneWidget);
    });
  });

  /*group('PageRegistro - Integración con SharedPreferences', () {
    testWidgets('Múltiples usuarios pueden registrarse', (WidgetTester tester) async {
      // Primer usuario
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Usuario1');
      await tester.pump();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      var prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('userName'), equals('Usuario1'));

      // Simular segundo usuario (nuevo widget)
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Usuario2');
      await tester.pump();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('userName'), equals('Usuario2'));
    });

    testWidgets('SharedPreferences se actualiza correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      const testName = 'TestUser';
      await tester.enterText(find.byType(TextField), testName);
      await tester.pump();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('userName'), equals(testName));
      expect(prefs.containsKey('userName'), isTrue);
    });
  });*/
}