import '../Modelos/categoria.dart';

class CategoriaService {
  // Lista de categorías predefinidas
  static final List<Categoria> categoriasPredefinidasIngresos = [
    Categoria(
      nombre: 'Salario',
      tipo: 'ingreso',
      icono: '💰',
    ),
    Categoria(
      nombre: 'Freelance',
      tipo: 'ingreso',
      icono: '💻',
    ),
    Categoria(
      nombre: 'Inversiones',
      tipo: 'ingreso',
      icono: '📈',
    ),
  ];

  // Lista para almacenar las categorías personalizadas
  static List<Categoria> _categoriasPersonalizadas = [];

  // Obtener todas las categorías de ingresos 
  static List<Categoria> getCategoriasIngresos() {
    return [...categoriasPredefinidasIngresos, ..._categoriasPersonalizadas.where((c) => c.tipo == 'ingreso')];
  }

  // Agregar una nueva categoría personalizada
  static void agregarCategoria(Categoria categoria) {
    _categoriasPersonalizadas.add(categoria);
  }

  // Eliminar una categoría personalizada
  static bool eliminarCategoria(String nombre) {
    int initialLength = _categoriasPersonalizadas.length;
    _categoriasPersonalizadas.removeWhere((c) => c.nombre == nombre);
    return _categoriasPersonalizadas.length < initialLength;
  }

  // Verificar si una categoría es predefinida
  static bool esCategoriaPredefinda(String nombre) {
    return categoriasPredefinidasIngresos.any((c) => c.nombre == nombre);
  }
}