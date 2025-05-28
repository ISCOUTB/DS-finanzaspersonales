import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finanse_tracker/pages/detalle_transfer.dart';
import 'package:finanse_tracker/Modelos/transaccion.dart';
import 'package:finanse_tracker/Modelos/categoria.dart';

void main() {
  group('TransactionDetail Widget', () {
    final testCategoria = Categoria(
      nombre: 'Salario',
      tipo: 'ingreso',
      icono: '💰',
    );

    final testTransaccion = Transaccion(
      id: '1',
      tipo: 'ingreso',
      monto: 1000.0,
      fecha: DateTime(2025, 5, 27),
      categoria: testCategoria,
      descripcion: 'Pago mensual',
    );

    testWidgets('Renderiza correctamente los detalles de la transacción', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TransactionDetail(
            transaccion: testTransaccion,
          ),
        ),
      );

      expect(find.text('Detalle de Transferencia'), findsOneWidget);
      expect(find.text('Ingreso'), findsOneWidget);
      expect(find.text('\$1000.00'), findsOneWidget);
      expect(find.text('Salario'), findsOneWidget);
      expect(find.text('Pago mensual'), findsOneWidget);
    });

    testWidgets('Ejecuta la función de edición al presionar el botón de editar', (WidgetTester tester) async {
      bool editCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: TransactionDetail(
            transaccion: testTransaccion,
            onEdit: () async {
              editCalled = true;
              return true;
            },
          ),
        ),
      );

      final editButton = find.byIcon(Icons.edit);
      expect(editButton, findsOneWidget);

      await tester.tap(editButton);
      await tester.pumpAndSettle();

      expect(editCalled, isTrue);
    });

    testWidgets('Ejecuta la función de eliminación al presionar el botón de eliminar', (WidgetTester tester) async {
      bool deleteCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: TransactionDetail(
            transaccion: testTransaccion,
            onDelete: () async {
              deleteCalled = true;
            },
          ),
        ),
      );

      final deleteButton = find.byIcon(Icons.delete);
      expect(deleteButton, findsOneWidget);

      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      expect(deleteCalled, isTrue);
    });

    testWidgets('No muestra los botones de editar y eliminar si no se proporcionan funciones', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TransactionDetail(
            transaccion: testTransaccion,
          ),
        ),
      );

      expect(find.byIcon(Icons.edit), findsNothing);
      expect(find.byIcon(Icons.delete), findsNothing);
    });
  });
}