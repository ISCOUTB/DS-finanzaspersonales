import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/pages/categoria_form.dart';

void main() {
  testWidgets('Crear categoría muestra campos y guarda correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CategoriaForm(),
      ),
    );

    // Verifica que los campos principales estén presentes
    expect(find.text('Nombre de la Categoría'), findsOneWidget);
    expect(find.text('Tipo de Categoría'), findsOneWidget);
    expect(find.text('Ícono'), findsOneWidget);
    expect(find.text('Crear'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);

    // Ingresa un nombre de categoría
    await tester.enterText(find.byType(TextFormField).first, 'TestCategoria');

    // Cambia el tipo a 'egreso' (gasto)
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gasto').last);
    await tester.pumpAndSettle();

    // Ingresa un presupuesto mensual
    await tester.enterText(find.byType(TextFormField).last, '1000');

    // Pulsa el botón Crear
    await tester.tap(find.text('Crear'));
    await tester.pump();

    // Espera el SnackBar de éxito
    expect(find.text('Categoría creada exitosamente'), findsOneWidget);
  });
}
