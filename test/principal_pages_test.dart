import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../lib/pages/principal_pages.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('PrincipalPage muestra saludo, usuario y balance', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PrincipalPage(),
      ),
    );
    // Verifica saludo
    expect(
      find.textContaining('Buenos').evaluate().isNotEmpty ||
      find.textContaining('Buenas').evaluate().isNotEmpty,
      isTrue,
    );
    // Verifica nombre de usuario por defecto
    expect(find.text('Usuario'), findsOneWidget);
    // Verifica que se muestre el balance
    expect(find.text('Total Balance'), findsOneWidget);
  });

  testWidgets('PrincipalPage muestra filtros de periodo', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PrincipalPage(),
      ),
    );
    // Verifica los filtros de periodo
    expect(find.text('DÍA'), findsOneWidget);
    expect(find.text('SEMANA'), findsOneWidget);
    expect(find.text('MES'), findsOneWidget);
    expect(find.text('AÑO'), findsOneWidget);
  });

  testWidgets('PrincipalPage muestra gráfico de pastel', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PrincipalPage(),
      ),
    );
    // Verifica que el gráfico de pastel esté presente
    expect(find.byWidgetPredicate((widget) => widget.runtimeType.toString() == 'PieChart'), findsOneWidget);
  });

  testWidgets('PrincipalPage muestra botón para agregar transacción', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PrincipalPage(),
      ),
    );
    // Verifica que el botón flotante esté presente
    expect(find.byType(FloatingActionButton), findsOneWidget);
    // Pulsa el botón y verifica que se abre el modal
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Gastos'), findsOneWidget);
    expect(find.text('Ingresos'), findsOneWidget);
  });
}
