import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finanse_tracker/pages/categorias_pages.dart';
import 'package:finanse_tracker/pages/categoria_form.dart';
import 'package:finanse_tracker/Modelos/categoria.dart';
import 'package:finanse_tracker/Modelos/categoria_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CategoriasPage Widget', () {
    setUp(() {
      // Limpia las categorías personalizadas si existen
      if (CategoriaService.getCategorias is! Null) {
        // Si tienes una lista personalizada, límpiala aquí
        // CategoriaService.categoriasPersonalizadas.clear();
      }
    });

    testWidgets('Renderiza la lista de categorías', (
      WidgetTester tester,
    ) async {
      // Agrega una categoría personalizada para la prueba
      final categoria = Categoria(
        nombre: 'TestCat',
        tipo: 'ingreso',
        icono: '💡',
      );
      // Si tienes una lista personalizada, agrégala ahí
      // CategoriaService.categoriasPersonalizadas.add(categoria);

      await tester.pumpWidget(MaterialApp(home: CategoriasPage()));

      await tester.pumpAndSettle();

      expect(find.text('Categorías'), findsOneWidget);
      expect(find.byType(ListTile), findsWidgets);
    });

    testWidgets('Al presionar el botón "+" navega al formulario de categoría', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: CategoriasPage()));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verifica que se navega al formulario (busca el campo de nombre)
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets(
      'No permite editar una categoría predefinida y muestra SnackBar',
      (WidgetTester tester) async {
        // Usa una categoría predefinida
        final categoria = Categoria(
          nombre: 'Alimentación',
          tipo: 'egreso',
          icono: '🍔',
        );

        await tester.pumpWidget(MaterialApp(home: CategoriasPage()));

        await tester.pumpAndSettle();

        // Busca el botón de editar y presiónalo
        final editButtons = find.byIcon(Icons.edit);
        expect(editButtons, findsWidgets);

        await tester.tap(editButtons.first);
        await tester.pumpAndSettle();

        // Verifica que se muestra el SnackBar y NO el formulario
        expect(
          find.text('No se pueden modificar las categorías predefinidas'),
          findsOneWidget,
        );
        expect(find.byType(TextFormField), findsNothing);
      },
    );

    testWidgets(
      'Permite editar una categoría personalizada y navega al formulario',
      (WidgetTester tester) async {
        // Agrega una categoría personalizada
        final categoria = Categoria(
          nombre: 'Personalizada',
          tipo: 'egreso',
          icono: '🛒',
        );
        CategoriaService.agregarCategoria(categoria);

        await tester.pumpWidget(MaterialApp(home: CategoriasPage()));

        await tester.pumpAndSettle();

        // Busca el botón de editar de la categoría personalizada
        final editButtons = find.byIcon(Icons.edit);
        expect(editButtons, findsWidgets);

        // Busca el ListTile de la categoría personalizada y presiona su botón de editar
        final tile = find.widgetWithText(ListTile, 'Personalizada');
        expect(tile, findsOneWidget);

        // Encuentra el botón de editar dentro de ese ListTile
        final editButton = find.descendant(
          of: tile,
          matching: find.byIcon(Icons.edit),
        );
        expect(editButton, findsOneWidget);

        await tester.tap(editButton);
        await tester.pumpAndSettle();

        // Verifica que se navega al formulario (busca el campo de nombre)
        expect(find.byType(TextFormField), findsOneWidget);
      },
    );
  });
}
