import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../Modelos/transaccion.dart';

class GestorArchivos {
  static const String fileName = 'transacciones.json';

  Future<String> get _externalPath async {
    // Obtener el directorio de documentos externo
    final directory = await getExternalStorageDirectory();
    final path = '${directory?.path}/FinanseTracker';
    
    // Crear el directorio si no existe
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    
    return path;
  }

  Future<File> get _file async {
    final path = await _externalPath;
    return File('$path/$fileName');
  }

  Future<void> guardarTransacciones(List<Transaccion> lista) async {
    // Solicitar permisos de almacenamiento
    if (await Permission.storage.request().isGranted) {
      final file = await _file;
      final jsonList = lista.map((t) => t.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonList));
      
      // Crear una copia de respaldo
      final backupFile = File('${await _externalPath}/backup_$fileName');
      await backupFile.writeAsString(jsonEncode(jsonList));
    }
  }

  Future<List<Transaccion>> cargarTransacciones() async {
    try {
      final file = await _file;
      if (!await file.exists()) {
        // Intentar cargar desde el backup
        final backupFile = File('${await _externalPath}/backup_$fileName');
        if (await backupFile.exists()) {
          return _parseTransacciones(await backupFile.readAsString());
        }
        return [];
      }

      return _parseTransacciones(await file.readAsString());
    } catch (e) {
      print('Error al cargar transacciones: $e');
      return [];
    }
  }

  List<Transaccion> _parseTransacciones(String contenido) {
    final jsonList = jsonDecode(contenido) as List;
    return jsonList.map((item) => Transaccion.fromJson(item)).toList();
  }
}
