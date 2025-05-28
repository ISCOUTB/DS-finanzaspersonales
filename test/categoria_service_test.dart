import 'package:flutter_test/flutter_test.dart';
import '../lib/Modelos/categoria_service.dart';
import '../lib/Modelos/categoria.dart';

void main() {
  setUp(() {
    // Limpia las categorías personalizadas antes de cada test
    while (CategoriaService.getCategorias().length > CategoriaService.categoriasPredefinidasIngresos.length + CategoriaService.categoriasPredefinidasGastos.length) {
      final all = CategoriaService.getCategorias();
      for (final c in all) {
        if (!CategoriaService.esCategoriaPredefinda(c.nombre)) {
          CategoriaService.eliminarCategoria(c.nombre);
        }
      }
    }
  });

  test('getCategorias, getCategoriasPorTipo y agregarCategoria', () {
    final personalizada = Categoria(nombre: 'MiCategoria', tipo: 'ingreso', icono: '⭐');
    CategoriaService.agregarCategoria(personalizada);
    expect(CategoriaService.getCategorias().any((c) => c.nombre == 'MiCategoria'), isTrue);
    expect(CategoriaService.getCategoriasPorTipo('ingreso').any((c) => c.nombre == 'MiCategoria'), isTrue);
    expect(CategoriaService.getCategoriasPorTipo('egreso').any((c) => c.nombre == 'MiCategoria'), isFalse);
  });

  test('actualizarCategoria solo permite personalizadas', () {
    final personalizada = Categoria(nombre: 'Personalizada', tipo: 'egreso', icono: '🆕');
    CategoriaService.agregarCategoria(personalizada);
    final nueva = Categoria(nombre: 'Personalizada', tipo: 'egreso', icono: '🔄');
    final ok = CategoriaService.actualizarCategoria(personalizada, nueva);
    expect(ok, isTrue);
    expect(CategoriaService.getCategorias().any((c) => c.icono == '🔄'), isTrue);
    // No permite actualizar predefinidas
    final predef = CategoriaService.categoriasPredefinidasIngresos.first;
    final fail = CategoriaService.actualizarCategoria(predef, predef);
    expect(fail, isFalse);
  });

  test('eliminarCategoria solo permite personalizadas', () {
    final personalizada = Categoria(nombre: 'Eliminarme', tipo: 'egreso', icono: '❌');
    CategoriaService.agregarCategoria(personalizada);
    final ok = CategoriaService.eliminarCategoria('Eliminarme');
    expect(ok, isTrue);
    expect(CategoriaService.getCategorias().any((c) => c.nombre == 'Eliminarme'), isFalse);
    // No permite eliminar predefinidas
    final predef = CategoriaService.categoriasPredefinidasGastos.first;
    final fail = CategoriaService.eliminarCategoria(predef.nombre);
    expect(fail, isFalse);
  });

  test('esCategoriaPredefinda funciona correctamente', () {
    final predef = CategoriaService.categoriasPredefinidasIngresos.first;
    expect(CategoriaService.esCategoriaPredefinda(predef.nombre), isTrue);
    final personalizada = Categoria(nombre: 'NoPredef', tipo: 'egreso', icono: '❌');
    expect(CategoriaService.esCategoriaPredefinda(personalizada.nombre), isFalse);
  });
}
