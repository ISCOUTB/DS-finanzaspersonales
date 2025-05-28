import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../lib/pages/presupuestos_categoria_page.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('PresupuestosPage muestra selector y presupuesto general', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PresupuestosPage(),
      ),
    );

    // Verifica que el selector de tipo de presupuesto esté presente
    expect(find.text('Tipo de presupuesto:'), findsOneWidget);
    expect(find.text('General'), findsOneWidget);
    // Abre el menú desplegable para ver la opción "Por Categorías"
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    expect(find.text('Por Categorías'), findsOneWidget);
    // Verifica que el presupuesto general se muestre
    expect(find.text('Presupuesto General'), findsOneWidget);
    expect(find.text('Límite mensual:'), findsOneWidget);
    expect(find.textContaining('Gastado:'), findsOneWidget);
  });

  testWidgets('PresupuestosPage cambia a vista por categorías', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PresupuestosPage(),
      ),
    );
    // Cambia el selector a "Por Categorías"
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Por Categorías').last);
    await tester.pumpAndSettle();
    // Verifica que el botón Agregar esté presente
    expect(find.text('Agregar'), findsOneWidget);
  });

  testWidgets('PresupuestosPage muestra mensaje si no hay egresos recientes', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PresupuestosPage(),
      ),
    );
    // Por defecto, si no hay egresos, no debe mostrar la lista de egresos recientes
    expect(find.text('Egresos recientes'), findsNothing);
  });
}
