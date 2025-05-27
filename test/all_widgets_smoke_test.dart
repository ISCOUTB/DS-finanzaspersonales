import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import '../lib/main.dart';
import '../lib/pages/side_menu.dart';
import '../lib/pages/metas_ahorro_page.dart';
import '../lib/pages/form_meta_ahorro.dart';
import '../lib/pages/presupuestos_categoria_page.dart';
import '../lib/pages/categorias_pages.dart';
import '../lib/pages/user_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('La app principal carga sin errores', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(initialRoute: '/home'));
    expect(find.byType(MyApp), findsOneWidget);
  });

  testWidgets('El Drawer se muestra y contiene opciones clave', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(drawer: const SideMenu()),
      ),
    );
    final ScaffoldState state = tester.firstState(find.byType(Scaffold));
    state.openDrawer();
    await tester.pumpAndSettle();
    expect(find.text('Gestionar Categorías'), findsOneWidget);
    expect(find.text('Metas de Ahorro'), findsOneWidget);
    expect(find.text('Presupuestos'), findsOneWidget);
  });

  testWidgets('Pantalla de Metas de Ahorro muestra mensaje si no hay metas', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: MetasAhorroPage()),
    );
    expect(find.textContaining('No tienes metas de ahorro'), findsOneWidget);
  });

  testWidgets('Formulario de nueva meta de ahorro muestra campos clave', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: FormMetaAhorro(onSave: (_,__,___){},))),
    );
    expect(find.text('Nueva Meta de Ahorro'), findsOneWidget);
    expect(find.text('Guardar Meta'), findsOneWidget);
  });

  testWidgets('Pantalla de presupuestos muestra mensaje si no hay presupuestos', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: PresupuestosPage()),
    );
    expect(find.textContaining('No hay presupuestos definidos para categorías.'), findsOneWidget);
  });

  testWidgets('Pantalla de categorías carga correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: CategoriasPage()),
    );
    expect(find.text('Categorías'), findsOneWidget);
  });

  testWidgets('Pantalla de usuario carga correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: UserProfilePage()),
    );
    expect(find.byType(UserProfilePage), findsOneWidget);
  });
}
