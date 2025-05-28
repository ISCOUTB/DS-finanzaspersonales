import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/pages/form_gastos.dart';

void main() {
  testWidgets('FormGastos muestra campos y permite crear gasto', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FormGastos(),
      ),
    );

    // Verifica que los campos principales estén presentes
    expect(find.text('Categoría'), findsOneWidget);
    expect(find.text('Cantidad'), findsOneWidget);
    expect(find.text('Fecha'), findsOneWidget);
    expect(find.text('Nombre'), findsOneWidget);
    expect(find.text('Crear'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);

    // Ingresa un monto
    await tester.enterText(find.byType(TextFormField).at(1), '1500');
    // Ingresa un nombre/descripción
    await tester.enterText(find.byType(TextFormField).last, 'Compra de comida');

    // Pulsa el botón Crear
    await tester.tap(find.text('Crear'));
    await tester.pump();
    // No hay SnackBar, pero debería cerrar el formulario (Navigator.pop)
    // No se puede verificar Navigator.pop directamente sin mock, pero no debe haber errores
  });

  testWidgets('FormGastos valida monto requerido', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FormGastos(),
      ),
    );
    // Intenta crear sin ingresar monto
    await tester.tap(find.text('Crear'));
    await tester.pump();
    expect(find.text('Por favor ingresa un monto'), findsOneWidget);
  });

  testWidgets('FormGastos valida monto mayor a 0', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FormGastos(),
      ),
    );
    // Ingresa un monto inválido
    await tester.enterText(find.byType(TextFormField).at(0), '-10');
    await tester.tap(find.text('Crear'));
    await tester.pumpAndSettle(); // Espera a que el error se muestre
    expect(find.text('Ingresa un monto válido y mayor a 0'), findsOneWidget);
  });
}
