import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../lib/pages/form_ingresos.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('FormIngresos muestra campos y permite crear ingreso', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FormIngresos(),
      ),
    );

    // Verifica que los campos principales estén presentes
    expect(find.text('Categoría'), findsOneWidget);
    expect(find.text('Cantidad'), findsOneWidget);
    expect(find.text('Fecha'), findsOneWidget);
    expect(find.text('Descripción'), findsAtLeastNWidgets(1));
    expect(find.text('Crear'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);

    // Ingresa un monto
    await tester.enterText(find.byType(TextFormField).at(0), '2000');
    // Ingresa una descripción
    await tester.enterText(find.byType(TextFormField).last, 'Pago de nómina');

    // Pulsa el botón Crear
    await tester.tap(find.text('Crear'));
    await tester.pump();
    // No hay SnackBar, pero debería cerrar el formulario (Navigator.pop)
    // No se puede verificar Navigator.pop directamente sin mock, pero no debe haber errores
  });

  testWidgets('FormIngresos valida monto requerido', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FormIngresos(),
      ),
    );
    // Intenta crear sin ingresar monto
    await tester.tap(find.text('Crear'));
    await tester.pump();
    expect(find.text('Por favor ingresa un monto'), findsOneWidget);
  });

  testWidgets('FormIngresos valida monto mayor a 0', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FormIngresos(),
      ),
    );
    // Ingresa un monto inválido
    await tester.enterText(find.byType(TextFormField).at(0), '-50');
    await tester.tap(find.text('Crear'));
    await tester.pumpAndSettle();
    expect(find.text('Ingresa un monto válido y mayor a 0'), findsOneWidget);
  });

  testWidgets('FormIngresos valida descripción máxima', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FormIngresos(),
      ),
    );
    // Ingresa una descripción muy larga
    String longDesc = 'a' * 101;
    await tester.enterText(find.byType(TextFormField).last, longDesc);
    await tester.tap(find.text('Crear'));
    await tester.pumpAndSettle();
    expect(find.text('Máximo 100 caracteres'), findsOneWidget);
  });
}
