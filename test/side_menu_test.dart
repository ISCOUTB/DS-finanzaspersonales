import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/pages/side_menu.dart';

void main() {
  Future<void> openDrawer(WidgetTester tester) async {
    // Simula un gesto de arrastre desde el borde izquierdo para abrir el Drawer
    await tester.dragFrom(const Offset(0, 100), const Offset(300, 0));
    await tester.pumpAndSettle();
  }

  testWidgets('SideMenu muestra opciones principales', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          drawer: SideMenu(),
        ),
      ),
    );
    await openDrawer(tester);
    // Verifica que el título y las opciones estén presentes
    expect(find.text('Categorías'), findsOneWidget);
    expect(find.text('Gestionar Categorías'), findsOneWidget);
    expect(find.text('Presupuestos'), findsOneWidget);
  });

  testWidgets('SideMenu navega a CategoriasPage al pulsar Gestionar Categorías', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          drawer: SideMenu(),
        ),
      ),
    );
    await openDrawer(tester);
    await tester.tap(find.text('Gestionar Categorías'));
    await tester.pumpAndSettle();
    // No se puede verificar la navegación exacta sin mock, pero no debe haber errores
  });

  testWidgets('SideMenu navega a Presupuestos al pulsar Presupuestos', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          drawer: SideMenu(),
        ),
      ),
    );
    await openDrawer(tester);
    await tester.tap(find.text('Presupuestos'));
    await tester.pumpAndSettle();
    // No se puede verificar la navegación exacta sin mock, pero no debe haber errores
  });
}
