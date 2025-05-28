import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/pages/registro_pages.dart';

void main() {
  testWidgets('PageRegistro muestra campos principales', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PageRegistro(),
      ),
    );
    // Verifica que el campo de nombre y el botón Siguiente estén presentes
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('¿Cómo te llamas?'), findsOneWidget);
    expect(find.text('Siguiente'), findsOneWidget);
  });

  testWidgets('PageRegistro deshabilita botón Siguiente si el campo está vacío', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PageRegistro(),
      ),
    );
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('PageRegistro habilita botón Siguiente si el campo tiene texto', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PageRegistro(),
      ),
    );
    await tester.enterText(find.byType(TextField), 'Juan');
    await tester.pumpAndSettle();
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNotNull);
  });

  testWidgets('PageRegistro muestra imagen de inicio', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PageRegistro(),
      ),
    );
    expect(find.byType(Image), findsOneWidget);
  });
}
