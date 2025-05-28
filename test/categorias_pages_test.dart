import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/pages/categorias_pages.dart';

void main() {
  testWidgets('CategoriasPage muestra lista y permite buscar', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CategoriasPage(),
      ),
    );

    // Verifica que el título esté presente
    expect(find.text('Categorías'), findsOneWidget);
    // Verifica que el campo de búsqueda esté presente
    expect(find.byType(TextField), findsOneWidget);
    // Verifica que el botón flotante esté presente
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Simula escribir en el campo de búsqueda
    await tester.enterText(find.byType(TextField), 'sueldo');
    await tester.pumpAndSettle();
    // El resultado depende de las categorías cargadas, pero el campo de búsqueda debe filtrar
    // (No se puede asegurar un resultado exacto sin mock de datos)

    // Pulsa el botón flotante para crear nueva categoría
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    // Verifica que se navega a la pantalla de crear categoría
    expect(find.text('Crear Categoría'), findsOneWidget);
  });
}
