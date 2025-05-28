import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/pages/estadisticas.dart';

void main() {
  testWidgets('EstadisticasPage muestra pestañas y filtros', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: EstadisticasPage(),
      ),
    );

    // Verifica que el título esté presente
    expect(find.text('Estadísticas'), findsOneWidget);
    // Verifica que las pestañas estén presentes
    expect(find.text('Pastel'), findsOneWidget);
    expect(find.text('Barras'), findsOneWidget);
    expect(find.text('Líneas'), findsOneWidget);

    // Cambia a la pestaña de Barras
    await tester.tap(find.text('Barras'));
    await tester.pumpAndSettle();
    // Si no hay transacciones, debe mostrar el mensaje de vacío
    expect(find.text('No hay transacciones para mostrar.'), findsOneWidget);

    // Cambia a la pestaña de Líneas
    await tester.tap(find.text('Líneas'));
    await tester.pumpAndSettle();
    expect(find.text('Valores mostrados en el gráfico:'), findsOneWidget);

    // Abre el filtro de tiempo
    await tester.tap(find.byIcon(Icons.filter_alt_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Día'), findsOneWidget);
    expect(find.text('Semana'), findsOneWidget);
    expect(find.text('Mes'), findsOneWidget);
    expect(find.text('Año'), findsOneWidget);
  });
}
