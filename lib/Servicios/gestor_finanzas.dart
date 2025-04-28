import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../Modelos/transaccion.dart';
import '../Modelos/categoria.dart';

class GestorFinanzas {
  static final GestorFinanzas _instance = GestorFinanzas._internal();
  List<Transaccion> transacciones = [];
  List<Categoria> categorias = [];

  factory GestorFinanzas() {
    return _instance;
  }

  GestorFinanzas._internal();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _transaccionesFile async {
    final path = await _localPath;
    return File('$path/transacciones.json');
  }

  // Cargar transacciones desde el archivo
  Future<void> cargarTransacciones() async {
    try {
      final file = await _transaccionesFile;
      if (await file.exists()) {
        final contenido = await file.readAsString();
        final List<dynamic> jsonList = json.decode(contenido);
        transacciones = jsonList.map((json) => Transaccion.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error al cargar transacciones: $e');
    }
  }

  // Guardar transacciones en el archivo
  Future<void> guardarTransacciones() async {
    try {
      final file = await _transaccionesFile;
      final List<Map<String, dynamic>> jsonList = 
          transacciones.map((t) => t.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
    } catch (e) {
      print('Error al guardar transacciones: $e');
    }
  }

  // Modificar métodos existentes para que guarden los cambios
  Future<void> agregarTransaccion(Transaccion t) async {
    transacciones.add(t);
    await guardarTransacciones();
  }

  Future<void> eliminarTransaccion(String id) async {
    transacciones.removeWhere((t) => t.id == id);
    await guardarTransacciones();
  }

  Future<void> editarTransaccion(String id, Transaccion nueva) async {
    final index = transacciones.indexWhere((t) => t.id == id);
    if (index != -1) {
      transacciones[index] = nueva;
      await guardarTransacciones();
    }
  }

  // Mantener métodos de consulta existentes
  List<Transaccion> obtenerPorTipo(String tipo) {
    return transacciones.where((t) => t.tipo == tipo).toList();
  }

  List<Transaccion> filtrarPorCategoria(String nombreCategoria) {
    return transacciones.where((t) => t.categoria.nombre == nombreCategoria).toList();
  }

  double calcularTotal(String tipo) {
    return transacciones
        .where((t) => t.tipo == tipo)
        .fold(0.0, (sum, t) => sum + t.monto);
  }

  Map<String, double> desglosePorCategoria(String tipo) {
    Map<String, double> resultado = {};
    for (var t in transacciones.where((t) => t.tipo == tipo)) {
      resultado[t.categoria.nombre] = (resultado[t.categoria.nombre] ?? 0) + t.monto;
    }
    return resultado;
  }

  // Método para obtener transacciones filtradas por fecha
  List<Transaccion> obtenerTransaccionesFiltradas(String filtro) {
    final now = DateTime.now();
    switch (filtro) {
      case 'día':
        return transacciones.where((t) => 
          t.fecha.year == now.year &&
          t.fecha.month == now.month &&
          t.fecha.day == now.day
        ).toList();
      case 'semana':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return transacciones.where((t) => 
          t.fecha.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          t.fecha.isBefore(startOfWeek.add(const Duration(days: 7)))
        ).toList();
      case 'mes':
        return transacciones.where((t) => 
          t.fecha.year == now.year &&
          t.fecha.month == now.month
        ).toList();
      case 'año':
        return transacciones.where((t) => 
          t.fecha.year == now.year
        ).toList();
      default:
        return transacciones;
    }
  }
}
