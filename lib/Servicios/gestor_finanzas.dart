import '../modelos/transaccion.dart';
import '../modelos/categoria.dart';

class GestorFinanzas {
  List<Transaccion> transacciones = [];
  List<Categoria> categorias = [];

  void agregarTransaccion(Transaccion t) {
    transacciones.add(t);
  }

  void eliminarTransaccion(String id) {
    transacciones.removeWhere((t) => t.id == id);
  }

  void editarTransaccion(String id, Transaccion nueva) {
    final index = transacciones.indexWhere((t) => t.id == id);
    if (index != -1) {
      transacciones[index] = nueva;
    }
  }

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
}
