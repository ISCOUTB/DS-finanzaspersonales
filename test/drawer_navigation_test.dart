import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import '../lib/pages/side_menu.dart';
import '../lib/pages/principal_pages.dart';
import '../lib/pages/metas_ahorro_page.dart';
import '../lib/pages/presupuestos_categoria_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Drawer muestra Presupuestos por Categoría y navega correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          drawer: const SideMenu(),
        ),
      ),
    );
    // Abre el Drawer
    final ScaffoldState state = tester.firstState(find.byType(Scaffold));
    state.openDrawer();
    await tester.pumpAndSettle();
    // Busca el ListTile de Presupuestos por Categoría
    expect(find.text('Presupuestos por Categoría'), findsOneWidget);
    // Toca el ListTile
    await tester.tap(find.text('Presupuestos por Categoría'));
    await tester.pumpAndSettle();
    // Verifica que navega a la pantalla correcta
    expect(find.byType(PresupuestosPage), findsOneWidget);
  });

  testWidgets('No se muestra Presupuestos por categoría en PrincipalPage', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PrincipalPage(),
      ),
    );
    // No debe haber ningún widget con el texto de la sección
    expect(find.text('Presupuestos por categoría'), findsNothing);
  });

  testWidgets('Drawer muestra Metas de Ahorro y navega correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          drawer: const SideMenu(),
        ),
        routes: {
          '/metas-ahorro': (context) => const MetasAhorroPage(),
        },
      ),
    );
    // Abre el Drawer
    final ScaffoldState state = tester.firstState(find.byType(Scaffold));
    state.openDrawer();
    await tester.pumpAndSettle();
    // Busca el ListTile de Metas de Ahorro
    expect(find.text('Metas de Ahorro'), findsOneWidget);
    // Toca el ListTile
    await tester.tap(find.text('Metas de Ahorro'));
    await tester.pumpAndSettle();
    // Verifica que navega a la pantalla correcta
    expect(find.byType(MetasAhorroPage), findsOneWidget);
  });
}
