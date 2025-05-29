import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finanse_tracker/pages/user_page.dart';
import 'package:finanse_tracker/pages/registro_pages.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Necesario para tests con sqflite en entorno no-Android/iOS
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Helper para construir el widget UserProfilePage
  Widget buildTestableWidget() {
    return MaterialApp(
      home: UserProfilePage(),
      routes: {
        '/registro': (context) => Scaffold(
          appBar: AppBar(title: Text('Registro')),
          body: Text('Registro Page'),
        ),
      },
    );
  }

  // Setup para SharedPreferences en cada test
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('UserProfilePage - Renderizado de UI', () {
    testWidgets('Renderiza correctamente todos los elementos principales', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Verificar elementos principales
      expect(find.text('Usuario'), findsOneWidget); // Nombre por defecto
      expect(find.text('Editar Perfil'), findsOneWidget);
      expect(find.text('Eliminar Información de la Cuenta'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsNWidgets(2)); // Avatar principal + icono cámara
      expect(find.byIcon(Icons.person), findsOneWidget); // Ícono por defecto
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    });

    testWidgets('Scaffold tiene fondo degradado correcto', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(Stack),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.gradient, isA<LinearGradient>());
      
      final gradient = decoration.gradient as LinearGradient;
      expect(gradient.colors, hasLength(2));
      expect(gradient.colors[0], equals(const Color.fromARGB(225, 47, 125, 121)));
      expect(gradient.colors[1], equals(const Color.fromARGB(255, 246, 253, 250)));
    });

    testWidgets('Avatar principal tiene configuración correcta', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final avatars = find.byType(CircleAvatar);
      final mainAvatar = tester.widget<CircleAvatar>(avatars.first);
      
      expect(mainAvatar.radius, equals(70));
      expect(mainAvatar.backgroundColor, equals(const Color.fromARGB(225, 47, 125, 121)));
      expect(mainAvatar.backgroundImage, isNull); // Sin imagen inicial
    });

    testWidgets('Avatar de cámara tiene configuración correcta', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final avatars = find.byType(CircleAvatar);
      final cameraAvatar = tester.widget<CircleAvatar>(avatars.last);
      
      expect(cameraAvatar.radius, equals(20));
      expect(cameraAvatar.backgroundColor, equals(Colors.white));
    });

    testWidgets('Nombre de usuario tiene estilo correcto', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final nameText = tester.widget<Text>(find.text('Usuario'));
      expect(nameText.style?.fontSize, equals(28));
      expect(nameText.style?.fontWeight, equals(FontWeight.bold));
      expect(nameText.style?.color, equals(Colors.white));
    });
  });

  group('UserProfilePage - Carga de Datos de Usuario', () {
    testWidgets('Carga nombre desde SharedPreferences', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'userName': 'Juan Pérez',
      });

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Juan Pérez'), findsOneWidget);
      expect(find.text('Usuario'), findsNothing);
    });

    testWidgets('Muestra nombre por defecto cuando no hay datos guardados', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Usuario'), findsOneWidget);
    });

    testWidgets('Maneja userName null correctamente', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        // 'userName': null, // Omitir la clave para simular ausencia
      });

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Usuario'), findsOneWidget);
    });
  });

  group('UserProfilePage - Botones y Estilos', () {
    /*testWidgets('Botón Editar Perfil tiene estilo correcto', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final editButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Editar Perfil'),
      );

      final buttonStyle = editButton.style as MaterialStateProperty?;
      expect(editButton.style, isNotNull);
      
      final textWidget = tester.widget<Text>(find.text('Editar Perfil'));
      expect(textWidget.style?.color, equals(const Color.fromARGB(225, 47, 125, 121)));
      expect(textWidget.style?.fontSize, equals(16));
    });*/

    testWidgets('Botón Eliminar Cuenta tiene estilo correcto', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final deleteButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Eliminar Información de la Cuenta'),
      );

      expect(deleteButton.style, isNotNull);
      
      final textWidget = tester.widget<Text>(find.text('Eliminar Información de la Cuenta'));
      expect(textWidget.style?.color, equals(Colors.white));
      expect(textWidget.style?.fontSize, equals(16));
    });

    testWidgets('SizedBox tienen las alturas correctas', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final sizedBoxes = find.byType(SizedBox);
      expect(sizedBoxes, findsAtLeastNWidgets(4));

      final sizedBoxWidgets = sizedBoxes.evaluate().map((e) => e.widget as SizedBox).toList();
      
      // Verificar que hay SizedBox con diferentes alturas
      expect(sizedBoxWidgets.any((sb) => sb.height == 16), isTrue);
      expect(sizedBoxWidgets.any((sb) => sb.height == 40), isTrue);
      expect(sizedBoxWidgets.any((sb) => sb.height == 20), isTrue);
    });
  });

  group('UserProfilePage - Diálogo de Editar Nombre', () {
    testWidgets('Abre diálogo al tap en Editar Perfil', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Editar Perfil'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Editar Nombre'), findsOneWidget);
      expect(find.text('Ingresa tu nuevo nombre'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Guardar'), findsOneWidget);
    });

    testWidgets('Campo de texto muestra nombre actual', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'userName': 'María García',
      });

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Editar Perfil'));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, equals('María García'));
    });

    testWidgets('Botón Cancelar cierra el diálogo', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Editar Perfil'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Guarda nuevo nombre correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Editar Perfil'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Nuevo Nombre');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(find.text('Nuevo Nombre'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);

      // Verificar que se guardó en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('userName'), equals('Nuevo Nombre'));
    });

    testWidgets('Permite editar texto en el campo', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Editar Perfil'));
      await tester.pumpAndSettle();

      const newName = 'Ana Lucía';
      await tester.enterText(find.byType(TextField), newName);
      await tester.pump();

      expect(find.text(newName), findsOneWidget);
    });
  });

  group('UserProfilePage - Diálogo de Opciones de Imagen', () {
    testWidgets('Abre diálogo al tap en avatar', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(CircleAvatar).first);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Opciones de Imagen'), findsOneWidget);
      expect(find.text('¿Qué deseas hacer con la imagen de perfil?'), findsOneWidget);
      expect(find.text('Ver Imagen'), findsOneWidget);
      expect(find.text('Cambiar Imagen'), findsOneWidget);
    });

    testWidgets('Botón Ver Imagen muestra SnackBar cuando no hay imagen', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(CircleAvatar).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ver Imagen'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('No hay imagen de perfil para mostrar.'), findsOneWidget);
    });

    testWidgets('Dialogo se cierra después de seleccionar opción', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(CircleAvatar).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ver Imagen'));
      await tester.pumpAndSettle();

      // El diálogo de opciones debería haberse cerrado
      expect(find.text('Opciones de Imagen'), findsNothing);
    });
  });

  group('UserProfilePage - Diálogo de Eliminar Cuenta', () {
    testWidgets('Abre diálogo de confirmación al tap en eliminar', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Eliminar Información de la Cuenta'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Confirmar Eliminación'), findsOneWidget);
      expect(find.text('¿Estás seguro de que deseas eliminar toda la información de tu cuenta? Esta acción no se puede deshacer.'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Eliminar'), findsOneWidget);
    });

    testWidgets('Botón Cancelar cierra el diálogo de confirmación', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Eliminar Información de la Cuenta'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });

    /*testWidgets('Botón Eliminar navega a página de registro', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'userName': 'Test User',
        'someOtherData': 'data',
      });

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Eliminar Información de la Cuenta'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Eliminar'));
      await tester.pumpAndSettle();

      // Verificar que navegó a PageRegistro
      expect(find.byType(PageRegistro), findsOneWidget);

      // Verificar que SharedPreferences se limpió
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('userName'), isNull);
      expect(prefs.getString('someOtherData'), isNull);
    });*/
  });

  group('UserProfilePage - Gestión de Estado', () {
    testWidgets('initState carga datos correctamente', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'userName': 'Test User',
      });

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Test User'), findsOneWidget);
    });

    testWidgets('setState actualiza la UI correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Verificar nombre inicial
      expect(find.text('Usuario'), findsOneWidget);

      // Cambiar nombre
      await tester.tap(find.text('Editar Perfil'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Nuevo Usuario');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      // Verificar que la UI se actualizó
      expect(find.text('Nuevo Usuario'), findsOneWidget);
      expect(find.text('Usuario'), findsNothing);
    });

    testWidgets('Widget mantiene estado después de rebuild', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'userName': 'Persistent User',
      });

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Persistent User'), findsOneWidget);

      // Simular rebuild
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Persistent User'), findsOneWidget);
    });
  });

  group('UserProfilePage - Interacciones de Usuario', () {
    testWidgets('Múltiples ediciones de nombre funcionan correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final nombres = ['Primer Nombre', 'Segundo Nombre', 'Tercer Nombre'];

      for (String nombre in nombres) {
        await tester.tap(find.text('Editar Perfil'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), nombre);
        await tester.tap(find.text('Guardar'));
        await tester.pumpAndSettle();

        expect(find.text(nombre), findsOneWidget);
      }
    });

    /*testWidgets('GestureDetector en avatar responde a tap', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final gestureDetector = find.byType(GestureDetector);
      expect(gestureDetector, findsOneWidget);

      await tester.tap(gestureDetector);
      await tester.pumpAndSettle();

      expect(find.text('Opciones de Imagen'), findsOneWidget);
    });*/

    testWidgets('Múltiples taps rápidos no causan problemas', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Hacer múltiples taps rápidos en el botón editar
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.text('Editar Perfil'));
        await tester.pump(Duration(milliseconds: 100));
      }

      await tester.pumpAndSettle();

      // Solo debería haber un diálogo abierto
      expect(find.byType(AlertDialog), findsOneWidget);
    });
  });

  group('UserProfilePage - Layout y Estructura', () {
    /*testWidgets('Stack contiene Container y Column', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Stack), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
      expect(find.byType(Column), findsOneWidget);
    });*/

    testWidgets('Column tiene MainAxisAlignment.center', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.mainAxisAlignment, equals(MainAxisAlignment.center));
    });

    /*testWidgets('Center widget envuelve la Column', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Center), findsOneWidget);
      
      final center = tester.widget<Center>(find.byType(Center));
      expect(center.child, isA<Column>());
    });*/

    /*testWidgets('Stack de avatar tiene alignment correcto', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final stacks = find.byType(Stack);
      final avatarStack = tester.widget<Stack>(stacks.last); // Stack del avatar
      expect(avatarStack.alignment, equals(Alignment.bottomRight));
    });*/
  });

  group('UserProfilePage - Casos Edge', () {
    testWidgets('Maneja nombres muy largos correctamente', (WidgetTester tester) async {
      const longName = 'Este es un nombre extremadamente largo que podría causar problemas de layout en la interfaz de usuario';
      
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Editar Perfil'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), longName);
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(find.text(longName), findsOneWidget);
    });

    testWidgets('Maneja nombres con caracteres especiales', (WidgetTester tester) async {
      const specialName = 'José María O\'Connor-Smith 🌟';
      
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Editar Perfil'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), specialName);
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(find.text(specialName), findsOneWidget);
    });

    testWidgets('Maneja nombre vacío', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Editar Perfil'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      // Debería aceptar nombre vacío (según el código actual)
      expect(find.text(''), findsOneWidget);
    });

    /*testWidgets('Maneja errores de SharedPreferences graciosamente', (WidgetTester tester) async {
      // Simular error con valores malformados
      SharedPreferences.setMockInitialValues({
        'profileImage': 'invalid/path/that/does/not/exist.jpg',
      });

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Debería manejar el error y mostrar valores por defecto
      expect(find.text('Usuario'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });*/
  });

  group('UserProfilePage - Accesibilidad', () {
    testWidgets('Elementos tienen semánticas apropiadas', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Semantics), findsWidgets);
    });

    testWidgets('Botones son accesibles', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byType(ElevatedButton), findsNWidgets(2));
      
      final buttons = find.byType(ElevatedButton);
      for (int i = 0; i < 2; i++) {
        final button = tester.widget<ElevatedButton>(buttons.at(i));
        expect(button.onPressed, isNotNull);
      }
    });

    /*testWidgets('Avatar es interactivo', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final gestureDetector = tester.widget<GestureDetector>(find.byType(GestureDetector));
      expect(gestureDetector.onTap, isNotNull);
    });*/
  });

  group('UserProfilePage - Performance', () {
    testWidgets('Construcción inicial es eficiente', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      expect(find.text('Usuario'), findsOneWidget);
    });

    testWidgets('Actualizaciones de estado son eficientes', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();
      
      await tester.tap(find.text('Editar Perfil'));
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextField), 'Nuevo Nombre');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      expect(find.text('Nuevo Nombre'), findsOneWidget);
    });

    testWidgets('Múltiples rebuilds no degradan performance', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Hacer múltiples cambios
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.text('Editar Perfil'));
        await tester.pumpAndSettle();
        
        await tester.enterText(find.byType(TextField), 'Nombre $i');
        await tester.tap(find.text('Guardar'));
        await tester.pumpAndSettle();
      }

      expect(find.text('Nombre 4'), findsOneWidget);
    });
  });
}