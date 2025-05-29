import 'package:flutter_test/flutter_test.dart';
import 'package:finanse_tracker/Modelos/categoria.dart';
import 'package:finanse_tracker/Modelos/categoria_service.dart';

void main() {
  group('CategoriaService', () {
    // Setup para limpiar las categorías personalizadas antes de cada test

    group('Categorías Predefinidas', () {
      test('getCategoriasIngresos retorna lista de categorías de ingresos', () {
        final categorias = CategoriaService.getCategoriasIngresos();
        
        expect(categorias, isA<List<Categoria>>());
        expect(categorias.isNotEmpty, true);
        expect(categorias.length, equals(12)); // 12 categorías predefinidas de ingresos
        
        for (final cat in categorias) {
          expect(cat, isA<Categoria>());
          expect(cat.tipo, equals('ingreso'));
          expect(cat.nombre, isNotEmpty);
          expect(cat.icono, isNotEmpty);
        }
      });

      test('getCategoriasGastos retorna lista de categorías de gastos', () {
        final categorias = CategoriaService.getCategoriasGastos();
        
        expect(categorias, isA<List<Categoria>>());
        expect(categorias.isNotEmpty, true);
        expect(categorias.length, equals(24)); // 24 categorías predefinidas de gastos
        
        for (final cat in categorias) {
          expect(cat, isA<Categoria>());
          expect(cat.tipo, equals('egreso'));
          expect(cat.nombre, isNotEmpty);
          expect(cat.icono, isNotEmpty);
        }
      });

      test('Las categorías de ingresos y gastos no son iguales', () {
        final ingresos = CategoriaService.getCategoriasIngresos();
        final gastos = CategoriaService.getCategoriasGastos();
        
        expect(ingresos, isNot(equals(gastos)));
        expect(ingresos.length, isNot(equals(gastos.length)));
      });

      test('Categorías predefinidas tienen nombres específicos esperados', () {
        final ingresos = CategoriaService.getCategoriasIngresos();
        final gastos = CategoriaService.getCategoriasGastos();
        
        // Verificar algunas categorías específicas de ingresos
        expect(ingresos.any((c) => c.nombre == 'Salario'), isTrue);
        expect(ingresos.any((c) => c.nombre == 'Freelance'), isTrue);
        expect(ingresos.any((c) => c.nombre == 'Inversiones'), isTrue);
        expect(ingresos.any((c) => c.nombre == 'Otros'), isTrue);
        
        // Verificar algunas categorías específicas de gastos
        expect(gastos.any((c) => c.nombre == 'Alimentación'), isTrue);
        expect(gastos.any((c) => c.nombre == 'Transporte'), isTrue);
        expect(gastos.any((c) => c.nombre == 'Vivienda'), isTrue);
        expect(gastos.any((c) => c.nombre == 'Otros'), isTrue);
      });

      test('Categorías predefinidas tienen iconos correctos', () {
        final ingresos = CategoriaService.getCategoriasIngresos();
        final gastos = CategoriaService.getCategoriasGastos();
        
        // Verificar iconos específicos
        final salario = ingresos.firstWhere((c) => c.nombre == 'Salario');
        expect(salario.icono, equals('💰'));
        
        final alimentacion = gastos.firstWhere((c) => c.nombre == 'Alimentación');
        expect(alimentacion.icono, equals('🍔'));
        
        final transporte = gastos.firstWhere((c) => c.nombre == 'Transporte');
        expect(transporte.icono, equals('🚗'));
      });
    });

    group('getCategorias y getCategoriasPorTipo', () {
      test('getCategorias retorna todas las categorías predefinidas', () {
        final todasCategorias = CategoriaService.getCategorias();
        
        expect(todasCategorias, isA<List<Categoria>>());
        expect(todasCategorias.length, equals(36)); // 12 ingresos + 24 gastos
        
        final ingresos = todasCategorias.where((c) => c.tipo == 'ingreso').length;
        final gastos = todasCategorias.where((c) => c.tipo == 'egreso').length;
        
        expect(ingresos, equals(12));
        expect(gastos, equals(24));
      });

      test('getCategoriasPorTipo funciona correctamente para ingresos', () {
        final categorias = CategoriaService.getCategoriasPorTipo('ingreso');
        final ingresosDirectos = CategoriaService.getCategoriasIngresos();
        
        expect(categorias, equals(ingresosDirectos));
        expect(categorias.length, equals(12));
        
        for (final cat in categorias) {
          expect(cat.tipo, equals('ingreso'));
        }
      });

      test('getCategoriasPorTipo funciona correctamente para gastos', () {
        final categorias = CategoriaService.getCategoriasPorTipo('egreso');
        final gastosDirectos = CategoriaService.getCategoriasGastos();
        
        expect(categorias, equals(gastosDirectos));
        expect(categorias.length, equals(24));
        
        for (final cat in categorias) {
          expect(cat.tipo, equals('egreso'));
        }
      });

      test('getCategoriasPorTipo retorna gastos para tipo no reconocido', () {
        final categorias = CategoriaService.getCategoriasPorTipo('tipoInvalido');
        final gastosDirectos = CategoriaService.getCategoriasGastos();
        
        expect(categorias, equals(gastosDirectos));
      });
    });

    group('Categorías Personalizadas - Agregar', () {
      test('agregarCategoria añade categoría personalizada de ingreso', () {
        final nuevaCategoria = Categoria(
          nombre: 'Bono Especial',
          tipo: 'ingreso',
          icono: '🎯',
        );
        
        final ingresosAntes = CategoriaService.getCategoriasIngresos().length;
        CategoriaService.agregarCategoria(nuevaCategoria);
        final ingresosDespues = CategoriaService.getCategoriasIngresos().length;
        
        expect(ingresosDespues, equals(ingresosAntes + 1));
        
        final ingresos = CategoriaService.getCategoriasIngresos();
        expect(ingresos.any((c) => c.nombre == 'Bono Especial'), isTrue);
        
        final categoriaAgregada = ingresos.firstWhere((c) => c.nombre == 'Bono Especial');
        expect(categoriaAgregada.tipo, equals('ingreso'));
        expect(categoriaAgregada.icono, equals('🎯'));
      });

      test('agregarCategoria añade categoría personalizada de gasto', () {
        final nuevaCategoria = Categoria(
          nombre: 'Gaming',
          tipo: 'egreso',
          icono: '🎲',
        );
        
        final gastosAntes = CategoriaService.getCategoriasGastos().length;
        CategoriaService.agregarCategoria(nuevaCategoria);
        final gastosDespues = CategoriaService.getCategoriasGastos().length;
        
        expect(gastosDespues, equals(gastosAntes + 1));
        
        final gastos = CategoriaService.getCategoriasGastos();
        expect(gastos.any((c) => c.nombre == 'Gaming'), isTrue);
        
        final categoriaAgregada = gastos.firstWhere((c) => c.nombre == 'Gaming');
        expect(categoriaAgregada.tipo, equals('egreso'));
        expect(categoriaAgregada.icono, equals('🎲'));
      });

      test('agregarCategoria afecta getCategorias correctamente', () {
        final todasAntes = CategoriaService.getCategorias().length;
        
        final categoria1 = Categoria(nombre: 'Test1', tipo: 'ingreso', icono: '🔥');
        final categoria2 = Categoria(nombre: 'Test2', tipo: 'egreso', icono: '❄️');
        
        CategoriaService.agregarCategoria(categoria1);
        CategoriaService.agregarCategoria(categoria2);
        
        final todasDespues = CategoriaService.getCategorias().length;
        expect(todasDespues, equals(todasAntes + 2));
        
        final todas = CategoriaService.getCategorias();
        expect(todas.any((c) => c.nombre == 'Test1'), isTrue);
        expect(todas.any((c) => c.nombre == 'Test2'), isTrue);
      });

      test('agregar múltiples categorías personalizadas', () {
        final categorias = [
          Categoria(nombre: 'Cat1', tipo: 'ingreso', icono: '1️⃣'),
          Categoria(nombre: 'Cat2', tipo: 'egreso', icono: '2️⃣'),
          Categoria(nombre: 'Cat3', tipo: 'ingreso', icono: '3️⃣'),
        ];
        
        for (final cat in categorias) {
          CategoriaService.agregarCategoria(cat);
        }
        
        final ingresos = CategoriaService.getCategoriasIngresos();
        final gastos = CategoriaService.getCategoriasGastos();
        
        expect(ingresos.where((c) => c.nombre.startsWith('Cat')).length, equals(2));
        expect(gastos.where((c) => c.nombre.startsWith('Cat')).length, equals(1));
      });
    });

    group('Categorías Personalizadas - Actualizar', () {
      test('actualizarCategoria actualiza categoría personalizada existente', () {
        final categoria = Categoria(nombre: 'Original', tipo: 'ingreso', icono: '🔴');
        CategoriaService.agregarCategoria(categoria);
        
        final categoriaActualizada = Categoria(nombre: 'Actualizada', tipo: 'ingreso', icono: '🔵');
        final resultado = CategoriaService.actualizarCategoria(categoria, categoriaActualizada);
        
        expect(resultado, isTrue);
        
        final ingresos = CategoriaService.getCategoriasIngresos();
        expect(ingresos.any((c) => c.nombre == 'Original'), isFalse);
        expect(ingresos.any((c) => c.nombre == 'Actualizada'), isTrue);
        
        final categoriaEncontrada = ingresos.firstWhere((c) => c.nombre == 'Actualizada');
        expect(categoriaEncontrada.icono, equals('🔵'));
      });

      test('actualizarCategoria no permite actualizar categorías predefinidas', () {
        final salario = CategoriaService.getCategoriasIngresos()
            .firstWhere((c) => c.nombre == 'Salario');
        final salarioModificado = Categoria(nombre: 'Salario Modificado', tipo: 'ingreso', icono: '💎');
        
        final resultado = CategoriaService.actualizarCategoria(salario, salarioModificado);
        
        expect(resultado, isFalse);
        
        final ingresos = CategoriaService.getCategoriasIngresos();
        expect(ingresos.any((c) => c.nombre == 'Salario'), isTrue);
        expect(ingresos.any((c) => c.nombre == 'Salario Modificado'), isFalse);
      });

      test('actualizarCategoria retorna false para categoría inexistente', () {
        final categoriaInexistente = Categoria(nombre: 'NoExiste', tipo: 'ingreso', icono: '❓');
        final categoriaActualizada = Categoria(nombre: 'Actualizada', tipo: 'ingreso', icono: '✅');
        
        final resultado = CategoriaService.actualizarCategoria(categoriaInexistente, categoriaActualizada);
        
        expect(resultado, isFalse);
      });

      test('actualizarCategoria permite cambiar tipo de categoría', () {
        final categoria = Categoria(nombre: 'Flexible', tipo: 'ingreso', icono: '🔄');
        CategoriaService.agregarCategoria(categoria);
        
        final categoriaActualizada = Categoria(nombre: 'Flexible', tipo: 'egreso', icono: '🔄');
        final resultado = CategoriaService.actualizarCategoria(categoria, categoriaActualizada);
        
        expect(resultado, isTrue);
        
        final ingresos = CategoriaService.getCategoriasIngresos();
        final gastos = CategoriaService.getCategoriasGastos();
        
        expect(ingresos.any((c) => c.nombre == 'Flexible'), isFalse);
        expect(gastos.any((c) => c.nombre == 'Flexible'), isTrue);
      });
    });

    group('Categorías Personalizadas - Eliminar', () {
      test('eliminarCategoria elimina categoría personalizada existente', () {
        final categoria = Categoria(nombre: 'AEliminar', tipo: 'ingreso', icono: '🗑️');
        CategoriaService.agregarCategoria(categoria);
        
        final ingresosAntes = CategoriaService.getCategoriasIngresos().length;
        final resultado = CategoriaService.eliminarCategoria('AEliminar');
        final ingresosDespues = CategoriaService.getCategoriasIngresos().length;
        
        expect(resultado, isTrue);
        expect(ingresosDespues, equals(ingresosAntes - 1));
        
        final ingresos = CategoriaService.getCategoriasIngresos();
        expect(ingresos.any((c) => c.nombre == 'AEliminar'), isFalse);
      });

      test('eliminarCategoria no permite eliminar categorías predefinidas', () {
        final gastosAntes = CategoriaService.getCategoriasGastos().length;
        final resultado = CategoriaService.eliminarCategoria('Alimentación');
        final gastosDespues = CategoriaService.getCategoriasGastos().length;
        
        expect(resultado, isFalse);
        expect(gastosDespues, equals(gastosAntes));
        
        final gastos = CategoriaService.getCategoriasGastos();
        expect(gastos.any((c) => c.nombre == 'Alimentación'), isTrue);
      });

      test('eliminarCategoria retorna false para categoría inexistente', () {
        final resultado = CategoriaService.eliminarCategoria('CategoriaInexistente');
        expect(resultado, isFalse);
      });

      test('eliminar múltiples categorías personalizadas', () {
        final categorias = [
          Categoria(nombre: 'EliminarA', tipo: 'ingreso', icono: '🅰️'),
          Categoria(nombre: 'EliminarB', tipo: 'egreso', icono: '🅱️'),
          Categoria(nombre: 'EliminarC', tipo: 'ingreso', icono: '🇨'),
        ];
        
        for (final cat in categorias) {
          CategoriaService.agregarCategoria(cat);
        }
        
        final todasAntes = CategoriaService.getCategorias().length;
        
        for (final cat in categorias) {
          final resultado = CategoriaService.eliminarCategoria(cat.nombre);
          expect(resultado, isTrue);
        }
        
        final todasDespues = CategoriaService.getCategorias().length;
        expect(todasDespues, equals(todasAntes - 3));
        
        final todas = CategoriaService.getCategorias();
        expect(todas.any((c) => c.nombre.startsWith('Eliminar')), isFalse);
      });
    });

    group('esCategoriaPredefinda', () {
      test('esCategoriaPredefinda retorna true para categorías de ingresos predefinidas', () {
        expect(CategoriaService.esCategoriaPredefinda('Salario'), isTrue);
        expect(CategoriaService.esCategoriaPredefinda('Freelance'), isTrue);
        expect(CategoriaService.esCategoriaPredefinda('Inversiones'), isTrue);
        expect(CategoriaService.esCategoriaPredefinda('Dividendos'), isTrue);
      });

      test('esCategoriaPredefinda retorna true para categorías de gastos predefinidas', () {
        expect(CategoriaService.esCategoriaPredefinda('Alimentación'), isTrue);
        expect(CategoriaService.esCategoriaPredefinda('Transporte'), isTrue);
        expect(CategoriaService.esCategoriaPredefinda('Vivienda'), isTrue);
        expect(CategoriaService.esCategoriaPredefinda('Emergencias'), isTrue);
      });

      test('esCategoriaPredefinda retorna false para categorías personalizadas', () {
        final categoria = Categoria(nombre: 'MiCategoria', tipo: 'ingreso', icono: '🌟');
        CategoriaService.agregarCategoria(categoria);
        
        expect(CategoriaService.esCategoriaPredefinda('MiCategoria'), isFalse);
      });

      test('esCategoriaPredefinda retorna false para categorías inexistentes', () {
        expect(CategoriaService.esCategoriaPredefinda('CategoriaInventada'), isFalse);
        expect(CategoriaService.esCategoriaPredefinda(''), isFalse);
      });

      test('esCategoriaPredefinda es case-sensitive', () {
        expect(CategoriaService.esCategoriaPredefinda('salario'), isFalse); // minúscula
        expect(CategoriaService.esCategoriaPredefinda('SALARIO'), isFalse); // mayúscula
        expect(CategoriaService.esCategoriaPredefinda('Salario'), isTrue);   // correcta
      });
    });

    group('Casos Edge y Validaciones', () {
      test('agregar categoría con nombre vacío', () {
        final categoria = Categoria(nombre: '', tipo: 'ingreso', icono: '❌');
        
        CategoriaService.agregarCategoria(categoria);
        
        final ingresos = CategoriaService.getCategoriasIngresos();
        expect(ingresos.any((c) => c.nombre == ''), isTrue);
      });

      test('agregar categoría con icono vacío', () {
        final categoria = Categoria(nombre: 'SinIcono', tipo: 'ingreso', icono: '');
        
        CategoriaService.agregarCategoria(categoria);
        
        final ingresos = CategoriaService.getCategoriasIngresos();
        final categoriaAgregada = ingresos.firstWhere((c) => c.nombre == 'SinIcono');
        expect(categoriaAgregada.icono, equals(''));
      });

      test('agregar categorías con nombres duplicados', () {
        final categoria1 = Categoria(nombre: 'Duplicado', tipo: 'ingreso', icono: '1️⃣');
        final categoria2 = Categoria(nombre: 'Duplicado', tipo: 'egreso', icono: '2️⃣');
        
        CategoriaService.agregarCategoria(categoria1);
        CategoriaService.agregarCategoria(categoria2);
        
        final ingresos = CategoriaService.getCategoriasIngresos();
        final gastos = CategoriaService.getCategoriasGastos();
        
        expect(ingresos.where((c) => c.nombre == 'Duplicado').length, equals(1));
        expect(gastos.where((c) => c.nombre == 'Duplicado').length, equals(1));
      });

      test('actualizar categoría cambiando solo el icono', () {
        final categoria = Categoria(nombre: 'CambiarIcono', tipo: 'ingreso', icono: '🔴');
        CategoriaService.agregarCategoria(categoria);
        
        final categoriaActualizada = Categoria(nombre: 'CambiarIcono', tipo: 'ingreso', icono: '🔵');
        final resultado = CategoriaService.actualizarCategoria(categoria, categoriaActualizada);
        
        expect(resultado, isTrue);
        
        final ingresos = CategoriaService.getCategoriasIngresos();
        final categoriaEncontrada = ingresos.firstWhere((c) => c.nombre == 'CambiarIcono');
        expect(categoriaEncontrada.icono, equals('🔵'));
      });

      test('operaciones con tipo de categoría inválido', () {
        final categoria = Categoria(nombre: 'TipoInvalido', tipo: 'invalido', icono: '❓');
        CategoriaService.agregarCategoria(categoria);
        
        final ingresos = CategoriaService.getCategoriasIngresos();
        final gastos = CategoriaService.getCategoriasGastos();
        
        // La categoría no debería aparecer en ingresos ni gastos debido al filtro where
        expect(ingresos.any((c) => c.nombre == 'TipoInvalido'), isFalse);
        expect(gastos.any((c) => c.nombre == 'TipoInvalido'), isFalse);
        
        // Pero debería aparecer en getCategorias (sin filtro)
        final todas = CategoriaService.getCategorias();
        expect(todas.any((c) => c.nombre == 'TipoInvalido'), isTrue);
      });
    });

    group('Persistencia entre Operaciones', () {
      test('categorías personalizadas persisten entre llamadas', () {
        final categoria = Categoria(nombre: 'Persistente', tipo: 'ingreso', icono: '💾');
        CategoriaService.agregarCategoria(categoria);
        
        // Múltiples llamadas
        for (int i = 0; i < 5; i++) {
          final ingresos = CategoriaService.getCategoriasIngresos();
          expect(ingresos.any((c) => c.nombre == 'Persistente'), isTrue);
        }
      });

      test('eliminar categoría no afecta otras categorías personalizadas', () {
        final categoria1 = Categoria(nombre: 'Mantener', tipo: 'ingreso', icono: '✅');
        final categoria2 = Categoria(nombre: 'Eliminar', tipo: 'ingreso', icono: '❌');
        
        CategoriaService.agregarCategoria(categoria1);
        CategoriaService.agregarCategoria(categoria2);
        
        CategoriaService.eliminarCategoria('Eliminar');
        
        final ingresos = CategoriaService.getCategoriasIngresos();
        expect(ingresos.any((c) => c.nombre == 'Mantener'), isTrue);
        expect(ingresos.any((c) => c.nombre == 'Eliminar'), isFalse);
      });

      test('actualizar categoría no afecta categorías predefinidas', () {
        final categoria = Categoria(nombre: 'Personal', tipo: 'ingreso', icono: '👤');
        CategoriaService.agregarCategoria(categoria);
        
        final categoriaActualizada = Categoria(nombre: 'PersonalActualizada', tipo: 'ingreso', icono: '👥');
        CategoriaService.actualizarCategoria(categoria, categoriaActualizada);
        
        // Verificar que las categorías predefinidas siguen intactas
        final ingresos = CategoriaService.getCategoriasIngresos();
        expect(ingresos.any((c) => c.nombre == 'Salario'), isTrue);
        expect(ingresos.any((c) => c.nombre == 'Freelance'), isTrue);
        expect(ingresos.any((c) => c.nombre == 'PersonalActualizada'), isTrue);
        expect(ingresos.any((c) => c.nombre == 'Personal'), isFalse);
      });
    });

    /* group('Performance y Límites', () {
      test('agregar gran cantidad de categorías personalizadas', () {
        final cantidadInicial = CategoriaService.getCategorias().length;
        
        // Agregar 100 categorías
        for (int i = 0; i < 100; i++) {
          final categoria = Categoria(
            nombre: 'Test$i',
            tipo: i % 2 == 0 ? 'ingreso' : 'egreso',
            icono: '📝',
          );
          CategoriaService.agregarCategoria(categoria);
        }
        
        final cantidadFinal = CategoriaService.getCategorias().length;
        expect(cantidadFinal, equals(cantidadInicial + 100));
        
        final ingresos = CategoriaService.getCategoriasIngresos();
        final gastos = CategoriaService.getCategoriasGastos();
        
        // 50 categorías de cada tipo
        expect(ingresos.where((c) => c.nombre.startsWith('Test')).length, equals(50));
        expect(gastos.where((c) => c.nombre.startsWith('Test')).length, equals(50));
      });

      test('operaciones son eficientes con muchas categorías', () {
        // Agregar muchas categorías
        for (int i = 0; i < 50; i++) {
          final categoria = Categoria(
            nombre: 'Performance$i',
            tipo: 'ingreso',
            icono: '⚡',
          );
          CategoriaService.agregarCategoria(categoria);
        }
        
        // Las operaciones deberían seguir siendo rápidas
        final stopwatch = Stopwatch()..start();
        
        final ingresos = CategoriaService.getCategoriasIngresos();
        final gastos = CategoriaService.getCategoriasGastos();
        final todas = CategoriaService.getCategorias();
        
        stopwatch.stop();
        
        expect(stopwatch.elapsedMilliseconds, lessThan(100)); // Menos de 100ms
        expect(ingresos.length, greaterThan(60));
        expect(gastos.length, equals(24));
        expect(todas.length, greaterThan(85));
      });
    });*/
  });
}