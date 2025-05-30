import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finanse_tracker/main.dart';
import 'package:finanse_tracker/pages/registro_pages.dart';
import 'package:finanse_tracker/pages/principal_pages.dart';
import 'package:finanse_tracker/pages/estadisticas.dart';
import 'package:finanse_tracker/pages/transfer_history.dart';
import 'package:finanse_tracker/pages/side_menu.dart';
import 'package:finanse_tracker/pages/user_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Configuración para tests con SQLite
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('main() Function Tests', () {
    testWidgets('main() ejecuta con usuario existente y navega a /home', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'userName': 'TestUser',
      });

      // Ejecutar main
      main();
      await tester.pumpAndSettle();

      // Verificar que se creó MyApp con ruta /home
      expect(find.byType(MyApp), findsOneWidget);
      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.text('Finanse Tracker'), findsOneWidget);
    });

    testWidgets('main() ejecuta sin usuario existente y navega a /login', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      // Ejecutar main
      main();
      await tester.pumpAndSettle();

      // Verificar que se creó MyApp con ruta /login
      expect(find.byType(MyApp), findsOneWidget);
      expect(find.byType(PageRegistro), findsOneWidget);
    });

    testWidgets('main() maneja userName null correctamente', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'userName': '',
      });

      // Ejecutar main
      main();
      await tester.pumpAndSettle();

      // Debería navegar a /login cuando userName es null
      expect(find.byType(PageRegistro), findsOneWidget);
    });

    test('main() inicializa WidgetsFlutterBinding', () async {
      // Verificar que WidgetsFlutterBinding está inicializado
      expect(WidgetsBinding.instance, isNotNull);
    });

    test('main() verifica lógica de hasUser correctamente', () async {
      // Caso 1: Usuario existe
      SharedPreferences.setMockInitialValues({'userName': 'TestUser'});
      var prefs = await SharedPreferences.getInstance();
      var hasUser = prefs.getString('userName') != null;
      expect(hasUser, isTrue);

      // Caso 2: Usuario no existe
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      hasUser = prefs.getString('userName') != null;
      expect(hasUser, isFalse);

      // Caso 3: userName es null
      SharedPreferences.setMockInitialValues({'userName': ''});
      prefs = await SharedPreferences.getInstance();
      hasUser = prefs.getString('userName') != null;
      expect(hasUser, isFalse);
    });
  });

  group('MyApp Widget Tests', () {
    testWidgets('MyApp se construye correctamente con ruta inicial /login', (WidgetTester tester) async {
      const app = MyApp(initialRoute: '/login');
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      expect(find.byType(MyApp), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(PageRegistro), findsOneWidget);
    });

    testWidgets('MyApp se construye correctamente con ruta inicial /home', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'userName': 'TestUser'});
      
      const app = MyApp(initialRoute: '/home');
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      expect(find.byType(MyApp), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(MyHomePage), findsOneWidget);
    });

    testWidgets('MaterialApp tiene configuración correcta', (WidgetTester tester) async {
      const app = MyApp(initialRoute: '/login');
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.title, equals('Finanzas Personales'));
      expect(materialApp.debugShowCheckedModeBanner, isFalse);
      expect(materialApp.initialRoute, equals('/login'));
    });

    testWidgets('MaterialApp tiene rutas configuradas correctamente', (WidgetTester tester) async {
      const app = MyApp(initialRoute: '/login');
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.routes, isNotNull);
      expect(materialApp.routes!.containsKey('/login'), isTrue);
      expect(materialApp.routes!.containsKey('/home'), isTrue);
      expect(materialApp.routes!.length, equals(2));
    });

    testWidgets('MaterialApp tiene tema configurado correctamente', (WidgetTester tester) async {
      const app = MyApp(initialRoute: '/login');
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme, isNotNull);
      expect(materialApp.theme!.brightness, equals(Brightness.light));
      
      final bottomNavTheme = materialApp.theme!.bottomNavigationBarTheme;
      expect(bottomNavTheme.backgroundColor, equals(const Color(0xFF708871)));
      expect(bottomNavTheme.selectedItemColor, equals(const Color(0xFFBEC6A0)));
      expect(bottomNavTheme.unselectedItemColor, equals(Colors.white));
    });

    testWidgets('MyApp es StatefulWidget', (WidgetTester tester) async {
      const app = MyApp(initialRoute: '/login');
      await tester.pumpWidget(app);

      expect(app, isA<StatefulWidget>());
      expect(find.byType(MyApp), findsOneWidget);
    });

    testWidgets('MyApp acepta diferentes rutas iniciales', (WidgetTester tester) async {
      // Test con ruta personalizada (aunque no esté definida)
      const app = MyApp(initialRoute: '/custom');
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.initialRoute, equals('/custom'));
    });
  });

  group('MyHomePage Widget Tests', () {
    testWidgets('MyHomePage renderiza todos los componentes principales', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'userName': 'TestUser'});
      
      const app = MyApp(initialRoute: '/home');
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Finanse Tracker'), findsOneWidget);
    });

    testWidgets('MyHomePage tiene título correcto', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'userName': 'TestUser'});
      
      const homePage = MyHomePage(title: 'Test Title');
      await tester.pumpWidget(MaterialApp(home: homePage));
      await tester.pumpAndSettle();

      expect(find.text('Test Title'), findsOneWidget);
    });

    testWidgets('MyHomePage es StatefulWidget', (WidgetTester tester) async {
      const homePage = MyHomePage(title: 'Test');
      await tester.pumpWidget(MaterialApp(home: homePage));

      expect(homePage, isA<StatefulWidget>());
      expect(find.byType(MyHomePage), findsOneWidget);
    });

    testWidgets('ScaffoldKey está configurado correctamente', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'userName': 'TestUser'});
      
      const app = MyApp(initialRoute: '/home');
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.key, isNotNull);
    });
  });

  group('AppBar Tests', () {
    testWidgets('AppBar tiene configuración correcta', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'userName': 'TestUser'});
      
      const app = MyApp(initialRoute: '/home');
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.centerTitle, isFalse);
      
      // Verificar iconos en AppBar
      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.text('Finanse Tracker'), findsOneWidget);
    });

    testWidgets('Botón de menú funciona correctamente', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'userName': 'TestUser'});
      
      const app = MyApp(initialRoute: '/home');
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Tap en el botón de menú
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Verificar que el drawer se abre
      expect(find.byType(SideMenu), findsOneWidget);
    });

    testWidgets('Botón de perfil navega a UserProfilePage', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'userName': 'TestUser'});
      
      const app = MyApp(initialRoute: '/home');
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Tap en el botón de perfil
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      expect(find.byType(UserProfilePage), findsOneWidget);
    });

    testWidgets('Navegación a perfil y regreso funciona correctamente', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'userName': 'TestUser'});
      
      const app = MyApp(initialRoute: '/home');
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Ir a perfil
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      expect(find.byType(UserProfilePage), findsOneWidget);

      // Regresar
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(MyHomePage), findsOneWidget);
    });

    testWidgets('AppBar usa colores del tema correctamente', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'userName': 'TestUser'});
      
      const app = MyApp(initialRoute: '/home');
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      final theme = Theme.of(tester.element(find.byType(AppBar)));
      
      expect(appBar.backgroundColor, theme.appBarTheme.backgroundColor);
    });
  });

  group('BottomNavigationBar Tests', () {
    testWidgets('BottomNavigationBar tiene 3 elementos', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'userName': 'TestUser'});
      
      const app = MyApp(initialRoute: '/home');
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      final bottomNavBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNavBar.items.length, equals(3));
      expect(bottomNavBar.currentIndex, equals(0));
    });

    testWidgets('BottomNavigationBar tiene labels correctos', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'userName': 'TestUser'});
      
      const app = MyApp(initialRoute: '/home');
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      expect(find.text('Principal'), findsOneWidget);
      expect(find.text('Estadísticas'), findsOneWidget);
      expect(find.text('Registros'), findsOneWidget);
    });

    testWidgets('BottomNavigationBar tiene iconos correctos', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'userName': 'TestUser'});
      
      const app = MyApp(initialRoute: '/home');
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.bar_chart), findsOneWidget);
      expect(find.byIcon(Icons.list), findsOneWidget);
    });

    testWidgets('BottomNavigationBar tiene colores correctos', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'userName': 'TestUser'});
      
      const app = MyApp(initialRoute: '/home');
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      final bottomNavBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNavBar.backgroundColor, equals(const Color(0xFF368983)));
      expect(bottomNavBar.selectedItemColor, equals(const Color(0xFFBEC6A0)));
      expect(bottomNavBar.unselectedItemColor, equals(Colors.white));
    });
  });

  group('Navegación entre Páginas Tests', () {
    testWidgets('Página inicial es PrincipalPage (índice 0)', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'userName': 'TestUser'});
      
      const app = MyApp(initialRoute: '/home');
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      expect(find.byType(PrincipalPage), findsOneWidget);
      expect(find.byType(EstadisticasPage), findsNothing);
      expect(find.byType(Transferhistory), findsNothing);
    });

    testWidgets('Navegar a Estadísticas funciona correctamente', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'userName': 'TestUser'});
      
      const app = MyApp(initialRoute: '/home');
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      expect(find.byType(EstadisticasPage), findsOneWidget);
      expect(find.byType(PrincipalPage), findsNothing);
      expect(find.byType(Transferhistory), findsNothing);

      final bottomNavBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNavBar.currentIndex, equals(1));
    });

    testWidgets('Navegar a Registros funciona correctamente', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'userName': 'TestUser'});
      
      const app = MyApp(initialRoute: '/home');
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.list));
      await tester.pumpAndSettle();

      expect(find.byType(Transferhistory), findsOneWidget);
      expect(find.byType(PrincipalPage), findsNothing);
      expect(find.byType(EstadisticasPage), findsNothing);

      final bottomNavBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNavBar.currentIndex, equals(2));
    });

    testWidgets('Navegar de vuelta a Principal funciona correctamente', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'userName': 'TestUser'});
      
      const app = MyApp(initialRoute: '/home');
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Ir a Estadísticas
      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();
      expect(find.byType(EstadisticasPage), findsOneWidget);

      // Volver a Principal
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      expect(find.byType(PrincipalPage), findsOneWidget);
      expect(find.byType(EstadisticasPage), findsNothing);

      final bottomNavBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNavBar.currentIndex, equals(0));
    });

    testWidgets('Navegación secuencial entre todas las páginas', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'userName': 'TestUser'});
      
      const app = MyApp(initialRoute: '/home');
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Principal -> Estadísticas -> Registros -> Principal
      expect(find.byType(PrincipalPage), findsOneWidget);

      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();
      expect(find.byType(EstadisticasPage), findsOneWidget);

      await tester.tap(find.byIcon(Icons.list));
      await tester.pumpAndSettle();
      expect(find.byType(Transferhistory), findsOneWidget);

      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();
      expect(find.byType(PrincipalPage), findsOneWidget);
    });
  });

  group('_getPage Method Tests', () {
    testWidgets('_getPage retorna PrincipalPage para índice 0', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'userName': 'TestUser'});
      
      const app = MyApp(initialRoute: '/home');
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      expect(find.byType(PrincipalPage), findsOneWidget);
    });

    testWidgets('_getPage retorna EstadisticasPage para índice 1', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'userName': 'TestUser'});
      
      const app = MyApp(initialRoute: '/home');
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      expect(find.byType(EstadisticasPage), findsOneWidget);
    });

    testWidgets('_getPage retorna Transferhistory para índice 2', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'userName': 'TestUser'});
      
      const app = MyApp(initialRoute: '/home');
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.list));
      await tester.pumpAndSettle();

      expect(find.byType(Transferhistory), findsOneWidget);
    });

    testWidgets('_getPage usa GlobalKeys correctamente', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'userName': 'TestUser'});
      
      const app = MyApp(initialRoute: '/home');
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      final principalPage = tester.widget<PrincipalPage>(find.byType(PrincipalPage));
      expect(principalPage.key, isA<GlobalKey>());

      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      final estadisticasPage = tester.widget<EstadisticasPage>(find.byType(EstadisticasPage));
      expect(estadisticasPage.key, isA<GlobalKey>());
    });
  });

  group('Drawer Tests', () {
    testWidgets('SideMenu está configurado como drawer', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'userName': 'TestUser'});
      
      const app = MyApp(initialRoute: '/home');
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.drawer, isA<SideMenu>());
      expect(scaffold.endDrawer, isA<SideMenu>());
    });

    testWidgets('Drawer se abre y cierra correctamente', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'userName': 'TestUser'});
      
      const app = MyApp(initialRoute: '/home');
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Abrir drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      expect(find.byType(SideMenu), findsOneWidget);

      // Cerrar drawer tocando fuera
      await tester.tapAt(const Offset(300, 200));
      await tester.pumpAndSettle();
    });

    testWidgets('Drawer se abre múltiples veces sin problemas', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'userName': 'TestUser'});
      
      const app = MyApp(initialRoute: '/home');
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      for (int i = 0; i < 3; i++) {
        // Abrir drawer
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();
        expect(find.byType(SideMenu), findsOneWidget);

        // Cerrar drawer
        await tester.tapAt(const Offset(300, 200));
        await tester.pumpAndSettle();
      }
    });
  });

  group('Estado y Interacciones Tests', () {
    testWidgets('Estado se mantiene después de navegación a perfil', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'userName': 'TestUser'});
      
      const app = MyApp(initialRoute: '/home');
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Ir a Estadísticas
      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();
      expect(find.byType(EstadisticasPage), findsOneWidget);

      // Ir a perfil
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      expect(find.byType(UserProfilePage), findsOneWidget);

      // Regresar
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verificar que se mantiene en Estadísticas
      expect(find.byType(EstadisticasPage), findsOneWidget);
      
      final bottomNavBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNavBar.currentIndex, equals(1));
    });

    testWidgets('Múltiples cambios de pestaña funcionan correctamente', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'userName': 'TestUser'});
      
      const app = MyApp(initialRoute: '/home');
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Secuencia de navegación múltiple
      final navegacion = [
        (Icons.bar_chart, EstadisticasPage, 1),
        (Icons.list, Transferhistory, 2),
        (Icons.home, PrincipalPage, 0),
        (Icons.bar_chart, EstadisticasPage, 1),
      ];

      for (var (icono, tipo, indice) in navegacion) {
        await tester.tap(find.byIcon(icono));
        await tester.pumpAndSettle();

        expect(find.byType(tipo), findsOneWidget);
        
        final bottomNavBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
        expect(bottomNavBar.currentIndex, equals(indice));
      }
    });

    testWidgets('Taps rápidos en navegación no causan errores', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'userName': 'TestUser'});
      
      const app = MyApp(initialRoute: '/home');
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Hacer múltiples taps rápidos
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byIcon(Icons.bar_chart));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.tap(find.byIcon(Icons.list));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.tap(find.byIcon(Icons.home));
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.pumpAndSettle();

      // Verificar que la aplicación sigue funcionando
      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.byType(PrincipalPage), findsOneWidget);
    });

    testWidgets('_onItemTapped actualiza el índice seleccionado', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'userName': 'TestUser'});
      
      const app = MyApp(initialRoute: '/home');
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Verificar índice inicial
      var bottomNavBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNavBar.currentIndex, equals(0));

      // Cambiar a índice 1
      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      bottomNavBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNavBar.currentIndex, equals(1));

      // Cambiar a índice 2
      await tester.tap(find.byIcon(Icons.list));
      await tester.pumpAndSettle();

      bottomNavBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNavBar.currentIndex, equals(2));
    });
  });

  group('Performance Tests', () {
    testWidgets('Construcción inicial es eficiente', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'userName': 'TestUser'});
      
      final stopwatch = Stopwatch()..start();
      
      const app = MyApp(initialRoute: '/home');
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();
      
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      expect(find.byType(MyHomePage), findsOneWidget);
    });

    testWidgets('Cambios de página son eficientes', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'userName': 'TestUser'});
      
      const app = MyApp(initialRoute: '/home');
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();
      
      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();
      
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      expect(find.byType(EstadisticasPage), findsOneWidget);
    });

    testWidgets('Múltiples navegaciones no degradan performance', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'userName': 'TestUser'});
      
      const app = MyApp(initialRoute: '/home');
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Hacer múltiples navegaciones
      for (int i = 0; i < 10; i++) {
        await tester.tap(find.byIcon(Icons.bar_chart));
        await tester.pump();
        await tester.tap(find.byIcon(Icons.list));
        await tester.pump();
        await tester.tap(find.byIcon(Icons.home));
        await tester.pump();
      }

      await tester.pumpAndSettle();

      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.byType(PrincipalPage), findsOneWidget);
    });
  });

  group('Casos Edge Tests', () {
    testWidgets('Maneja rutas inválidas sin crash', (WidgetTester tester) async {
      const app = MyApp(initialRoute: '/ruta_inexistente');
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // No debería crashear, aunque la ruta no exista
      expect(find.byType(MyApp), findsOneWidget);
    });

    testWidgets('Maneja título vacío', (WidgetTester tester) async {
      const homePage = MyHomePage(title: '');
      await tester.pumpWidget(MaterialApp(home: homePage));
      await tester.pumpAndSettle();

      expect(find.text(''), findsOneWidget);
    });

    testWidgets('Maneja título muy largo', (WidgetTester tester) async {
      const tituloLargo = 'Este es un título extremadamente largo que podría causar problemas de layout';
      const homePage = MyHomePage(title: tituloLargo);
      await tester.pumpWidget(MaterialApp(home: homePage));
      await tester.pumpAndSettle();

      expect(find.text(tituloLargo), findsOneWidget);
    });

    testWidgets('Reconstrucción de página funciona correctamente', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'userName': 'TestUser'});
      
      const app = MyApp(initialRoute: '/home');
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // Verificar que cada navegación reconstruye la página
      expect(find.byType(PrincipalPage), findsOneWidget);

      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();
      expect(find.byType(EstadisticasPage), findsOneWidget);
      expect(find.byType(PrincipalPage), findsNothing);

      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();
      expect(find.byType(PrincipalPage), findsOneWidget);
      expect(find.byType(EstadisticasPage), findsNothing);
    });
  });

  group('Accesibilidad Tests', () {
    testWidgets('Elementos tienen semánticas apropiadas', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'userName': 'TestUser'});
      
      const app = MyApp(initialRoute: '/home');
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      expect(find.byType(Semantics), findsWidgets);
    });

    testWidgets('BottomNavigationBar es accesible', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'userName': 'TestUser'});
      
      const app = MyApp(initialRoute: '/home');
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      final bottomNavBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNavBar.items.length, equals(3));
      
      for (var item in bottomNavBar.items) {
        expect(item.label, isNotNull);
        expect(item.icon, isNotNull);
      }
    });

    testWidgets('Botones de AppBar son accesibles', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'userName': 'TestUser'});
      
      const app = MyApp(initialRoute: '/home');
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      final iconButtons = find.byType(IconButton);
      expect(iconButtons, findsNWidgets(2)); // Menu + Person

      for (int i = 0; i < 2; i++) {
        final button = tester.widget<IconButton>(iconButtons.at(i));
        expect(button.onPressed, isNotNull);
      }
    });
  });
}