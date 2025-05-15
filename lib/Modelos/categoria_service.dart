import '../Modelos/categoria.dart';

class CategoriaService {
  // Lista de categorías predefinidas
  static final List<Categoria> categoriasPredefinidasIngresos = [
    Categoria(nombre: 'Salario', tipo: 'ingreso', icono: '💰'),
    Categoria(nombre: 'Freelance', tipo: 'ingreso', icono: '💻'),
    Categoria(nombre: 'Inversiones', tipo: 'ingreso', icono: '📈'),
    Categoria(nombre: 'Ventas', tipo: 'ingreso', icono: '🛒'),
    Categoria(nombre: 'Premios', tipo: 'ingreso', icono: '🏆'),
    Categoria(nombre: 'Regalos', tipo: 'ingreso', icono: '🎁'),
    Categoria(nombre: 'Intereses Bancarios', tipo: 'ingreso', icono: '🏦'),
    Categoria(nombre: 'Alquiler de Propiedades', tipo: 'ingreso', icono: '🏠'),
    Categoria(
      nombre: 'Devoluciones de Impuestos',
      tipo: 'ingreso',
      icono: '🧾',
    ),
    Categoria(nombre: 'Dividendos', tipo: 'ingreso', icono: '📊'),
    Categoria(nombre: 'Subsidios / Ayudas', tipo: 'ingreso', icono: '🆘'),
    Categoria(nombre: 'Otros', tipo: 'ingreso', icono: '✨'),
  ];

  static final List<Categoria> categoriasPredefinidasGastos = [
    Categoria(nombre: 'Alimentación', tipo: 'egreso', icono: '🍔'),
    Categoria(nombre: 'Transporte', tipo: 'egreso', icono: '🚗'),
    Categoria(nombre: 'Vivienda', tipo: 'egreso', icono: '🏠'),
    Categoria(nombre: 'Servicios Básicos', tipo: 'egreso', icono: '💡'),
    Categoria(nombre: 'Internet y Telefonía', tipo: 'egreso', icono: '📱'),
    Categoria(nombre: 'Educación', tipo: 'egreso', icono: '🎓'),
    Categoria(nombre: 'Salud', tipo: 'egreso', icono: '🏥'),
    Categoria(nombre: 'Seguro Médico', tipo: 'egreso', icono: '🛡️'),
    Categoria(nombre: 'Entretenimiento', tipo: 'egreso', icono: '🎮'),
    Categoria(nombre: 'Ropa y Calzado', tipo: 'egreso', icono: '👕'),
    Categoria(nombre: 'Mascotas', tipo: 'egreso', icono: '🐶'),
    Categoria(nombre: 'Gastos Personales', tipo: 'egreso', icono: '🛍️'),
    Categoria(nombre: 'Viajes', tipo: 'egreso', icono: '✈️'),
    Categoria(nombre: 'Hogar y Mantenimiento', tipo: 'egreso', icono: '🛠️'),
    Categoria(nombre: 'Deudas y Préstamos', tipo: 'egreso', icono: '💳'),
    Categoria(nombre: 'Impuestos', tipo: 'egreso', icono: '📄'),
    Categoria(nombre: 'Ahorros', tipo: 'egreso', icono: '🏦'),
    Categoria(nombre: 'Donaciones', tipo: 'egreso', icono: '❤️'),
    Categoria(nombre: 'Cuidado Personal', tipo: 'egreso', icono: '💇‍♂️'),
    Categoria(nombre: 'Suscripciones', tipo: 'egreso', icono: '📺'),
    Categoria(nombre: 'Eventos Sociales', tipo: 'egreso', icono: '🎉'),
    Categoria(nombre: 'Electrónica', tipo: 'egreso', icono: '🖥️'),
    Categoria(nombre: 'Emergencias', tipo: 'egreso', icono: '🚨'),
    Categoria(nombre: 'Otros', tipo: 'egreso', icono: '✨'),
  ];

  // Lista para almacenar las categorías personalizadas
  static final List<Categoria> _categoriasPersonalizadas = [];

  // Obtener todas las categorías de ingresos
  static List<Categoria> getCategoriasIngresos() {
    return [
      ...categoriasPredefinidasIngresos,
      ..._categoriasPersonalizadas.where((c) => c.tipo == 'ingreso'),
    ];
  }

  static List<Categoria> getCategoriasGastos() {
    return [
      ...categoriasPredefinidasGastos,
      ..._categoriasPersonalizadas.where((c) => c.tipo == 'egreso'),
    ];
  }

  // Obtener todas las categorías (tanto predefinidas como personalizadas)
  static List<Categoria> getCategorias() {
    return [
      ...categoriasPredefinidasIngresos,
      ...categoriasPredefinidasGastos,
      ..._categoriasPersonalizadas,
    ];
  }

  // Obtener categorías por tipo
  static List<Categoria> getCategoriasPorTipo(String tipo) {
    if (tipo == 'ingreso') {
      return getCategoriasIngresos();
    } else {
      return getCategoriasGastos();
    }
  }

  // Agregar una nueva categoría personalizada
  static void agregarCategoria(Categoria categoria) {
    _categoriasPersonalizadas.add(categoria);
  }

  // Actualizar una categoría personalizada existente
  static bool actualizarCategoria(
    Categoria oldCategoria,
    Categoria newCategoria,
  ) {
    // No permitir modificar categorías predefinidas
    if (categoriasPredefinidasIngresos.any(
          (c) => c.nombre == oldCategoria.nombre,
        ) ||
        categoriasPredefinidasGastos.any(
          (c) => c.nombre == oldCategoria.nombre,
        )) {
      return false;
    }

    // Buscar en categorías personalizadas por nombre
    final index = _categoriasPersonalizadas.indexWhere(
      (c) => c.nombre == oldCategoria.nombre,
    );
    if (index != -1) {
      _categoriasPersonalizadas[index] = newCategoria;
      return true;
    }
    return false;
  }

  // Eliminar una categoría personalizada
  static bool eliminarCategoria(String nombre) {
    if (esCategoriaPredefinda(nombre)) {
      return false; // No se pueden eliminar categorías predefinidas
    }

    int initialLength = _categoriasPersonalizadas.length;
    _categoriasPersonalizadas.removeWhere((c) => c.nombre == nombre);
    return _categoriasPersonalizadas.length < initialLength;
  }

  // Verificar si una categoría es predefinida
  static bool esCategoriaPredefinda(String nombre) {
    return categoriasPredefinidasIngresos.any((c) => c.nombre == nombre) ||
        categoriasPredefinidasGastos.any((c) => c.nombre == nombre);
  }
}
