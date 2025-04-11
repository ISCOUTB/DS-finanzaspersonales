import 'dart:convert';
import 'dart:io';
import '../modelos/transaccion.dart';

class GestorArchivos {
  final String pathArchivo;

  GestorArchivos(this.pathArchivo);

  Future<void> guardarTransacciones(List<Transaccion> lista) async {
    final file = File(pathArchivo);
    final jsonList = lista.map((t) => t.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

  Future<List<Transaccion>> cargarTransacciones() async {
    final file = File(pathArchivo);
    if (!await file.exists()) return [];

    final contenido = await file.readAsString();
    final jsonList = jsonDecode(contenido) as List;
    return jsonList.map((item) => Transaccion.fromJson(item)).toList();
  }
}
