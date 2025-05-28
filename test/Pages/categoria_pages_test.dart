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
      CategoriaService.limpiarCategorias(); // Método que limpia las categorías
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

  });
}

class CategoriaService {
  static final List<Categoria> categoriasPersonalizadas = [];

  static void agregarCategoria(Categoria categoria) {
    categoriasPersonalizadas.add(categoria);
  }

  static void limpiarCategorias() {
    categoriasPersonalizadas.clear();
  }
}
