import 'package:logging/logging.dart';
import '../Modelos/transaccion.dart';
import '../Modelos/categoria.dart';
import 'database_helper.dart';

class GestorFinanzas {
  static final GestorFinanzas _instance = GestorFinanzas._internal();
  final _dbHelper = DatabaseHelper();
  final _logger = Logger('GestorFinanzas');
  List<Transaccion> transacciones = [];
  List<Categoria> categorias = [];

  factory GestorFinanzas() {
    return _instance;
  }

  GestorFinanzas._internal();

  Future<void> cargarTransacciones() async {
    try {
      transacciones = await _dbHelper.getTransacciones();
    } catch (e) {
      _logger.severe('Error al cargar transacciones: $e');
    }
  }

  Future<void> agregarTransaccion(Transaccion transaccion) async {
    final db = await _dbHelper.database;

    await db.insert(
      'transacciones', // Nombre de la tabla
      transaccion.toMap(), // Convierte la transacción a un mapa
    );
  }

  Future<void> actualizarTransaccion(Transaccion transaccion) async {
    final db = await _dbHelper.database;

    await db.update(
      'transacciones', // Nombre de la tabla
      transaccion.toMap(), // Convierte la transacción a un mapa
      where: 'id = ?', // Condición para encontrar la transacción
      whereArgs: [transaccion.id], // Argumentos para la condición
    );
  }

  Future<void> eliminarTransaccion(String id) async {
    final db = await _dbHelper.database;

    await db.delete(
      'transacciones', // Nombre de la tabla
      where: 'id = ?', // Condición para encontrar la transacción
      whereArgs: [id], // Argumentos para la condición
    );
  }

  Future<void> editarTransaccion(String id, Transaccion nueva) async {
    try {
      await _dbHelper.updateTransaccion(nueva);
      final index = transacciones.indexWhere((t) => t.id == id);
      if (index != -1) {
        transacciones[index] = nueva;
      }
    } catch (e) {
      _logger.severe('Error al editar transacción: $e');
    }
  }

  // Mantener métodos de consulta existentes
  List<Transaccion> obtenerPorTipo(String tipo) {
    return transacciones.where((t) => t.tipo == tipo).toList();
  }

  List<Transaccion> filtrarPorCategoria(String nombreCategoria) {
    return transacciones
        .where((t) => t.categoria.nombre == nombreCategoria)
        .toList();
  }

  double calcularTotal(String tipo) {
    return transacciones
        .where((t) => t.tipo == tipo)
        .fold(0.0, (sum, t) => sum + t.monto);
  }

  Map<String, double> desglosePorCategoria(String tipo) {
    Map<String, double> resultado = {};
    for (var t in transacciones.where((t) => t.tipo == tipo)) {
      resultado[t.categoria.nombre] =
          (resultado[t.categoria.nombre] ?? 0) + t.monto;
    }
    return resultado;
  }

  // Método para obtener transacciones filtradas por fecha
  List<Transaccion> obtenerTransaccionesFiltradas(String filtro) {
    final now = DateTime.now();
    switch (filtro) {
      case 'día':
        return transacciones
            .where(
              (t) =>
                  t.fecha.year == now.year &&
                  t.fecha.month == now.month &&
                  t.fecha.day == now.day,
            )
            .toList();
      case 'semana':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return transacciones
            .where(
              (t) =>
                  t.fecha.isAfter(
                    startOfWeek.subtract(const Duration(days: 1)),
                  ) &&
                  t.fecha.isBefore(startOfWeek.add(const Duration(days: 7))),
            )
            .toList();
      case 'mes':
        return transacciones
            .where(
              (t) => t.fecha.year == now.year && t.fecha.month == now.month,
            )
            .toList();
      case 'año':
        return transacciones.where((t) => t.fecha.year == now.year).toList();
      default:
        return transacciones;
    }
  }

  Future<void> cargarTransaccionesPorAnio(int anio) async {
    try {
      transacciones = await _dbHelper.getTransaccionesPorAnio(anio);
    } catch (e) {
      _logger.severe('Error al cargar transacciones por año: $e');
    }
  }

  // Agrega este método al final de la clase GestorFinanzas
  Future<void> guardarTransacciones() async {
    // Si usas almacenamiento local, SharedPreferences, archivo, base de datos, etc.
    // Aquí solo es un ejemplo, debes adaptarlo a tu lógica real de guardado.
    // Por ejemplo, si tienes un método para guardar en SharedPreferences:
    // await saveTransaccionesToStorage(transacciones);

    // Si no tienes persistencia aún, puedes dejarlo vacío para evitar errores.
  }
}
