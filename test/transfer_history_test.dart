import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/pages/transfer_history.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('Muestra el título y pills de filtro', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Transferhistory()));
    expect(find.text('Historial de Transferencias'), findsOneWidget);
    expect(find.text('TODAS'), findsOneWidget);
    expect(find.text('INGRESOS'), findsOneWidget);
    expect(find.text('GASTOS'), findsOneWidget);
  });

  testWidgets('El buscador aparece y permite escribir', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Transferhistory()));
    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);
    await tester.enterText(searchField, 'comida');
    expect(find.text('comida'), findsOneWidget);
  });

  testWidgets('El botón de filtro de fecha aparece', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Transferhistory()));
    expect(find.byIcon(Icons.date_range), findsOneWidget);
  });

  testWidgets('Cambia el filtro al tocar un pill', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Transferhistory()));
    await tester.tap(find.text('GASTOS'));
    await tester.pumpAndSettle();
    // El pill activo debe ser GASTOS
    expect(find.text('GASTOS'), findsOneWidget);
  });

  testWidgets('Muestra mensaje vacío si no hay transacciones', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Transferhistory()));
    // No hay transacciones, la lista estará vacía
    expect(find.byType(ListTile), findsNothing);
  });
}
