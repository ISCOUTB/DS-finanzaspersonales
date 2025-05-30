import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../Modelos/transaccion.dart';
import '../Modelos/categoria.dart';
import 'package:logging/logging.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  Database? _testDatabase;
  final _logger = Logger('DatabaseHelper');

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_testDatabase != null) {
      return _testDatabase!; // Usar base de datos de prueba si está configurada
    }
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'finanzas.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transacciones(
        id TEXT PRIMARY KEY,
        tipo TEXT,
        monto REAL,
        fecha TEXT,
        descripcion TEXT,
        categoria_nombre TEXT,
        categoria_tipo TEXT,
        categoria_icono TEXT
      )
    ''');
  }

  Future<void> insertTransaccion(Transaccion transaccion) async {
    final db = await database;
    await db.insert('transacciones', {
      'id': transaccion.id,
      'tipo': transaccion.tipo,
      'monto': transaccion.monto,
      'fecha': transaccion.fecha.toIso8601String(),
      'descripcion': transaccion.descripcion,
      'categoria_nombre': transaccion.categoria.nombre,
      'categoria_tipo': transaccion.categoria.tipo,
      'categoria_icono': transaccion.categoria.icono,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Transaccion>> getTransacciones() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('transacciones');

    return List.generate(maps.length, (i) {
      return Transaccion(
        id: maps[i]['id'],
        tipo: maps[i]['tipo'],
        monto: maps[i]['monto'],
        fecha: DateTime.parse(maps[i]['fecha']),
        descripcion: maps[i]['descripcion'],
        categoria: Categoria(
          nombre: maps[i]['categoria_nombre'],
          tipo: maps[i]['categoria_tipo'],
          icono: maps[i]['categoria_icono'],
        ),
      );
    });
  }

  Future<void> deleteTransaccion(String id) async {
    final db = await database;
    await db.delete('transacciones', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllTransacciones() async {
  final db = await database;
  _logger.severe('Eliminando todas las transacciones...');
  await db.delete('transacciones');
  _logger.severe('Todas las transacciones han sido eliminadas.');
  }

  Future<void> updateTransaccion(Transaccion transaccion) async {
    final db = await database;
    await db.update(
      'transacciones',
      {
        'tipo': transaccion.tipo,
        'monto': transaccion.monto,
        'fecha': transaccion.fecha.toIso8601String(),
        'descripcion': transaccion.descripcion,
        'categoria_nombre': transaccion.categoria.nombre,
        'categoria_tipo': transaccion.categoria.tipo,
        'categoria_icono': transaccion.categoria.icono,
      },
      where: 'id = ?',
      whereArgs: [transaccion.id],
    );
  }

  Future<List<Transaccion>> getTransaccionesPorAnio(int anio) async {
    final db = await database;
    try {
      String fechaInicio = DateTime(anio, 1, 1).toIso8601String();
      String fechaFin = DateTime(anio + 1, 1, 1).toIso8601String();

      final List<Map<String, dynamic>> maps = await db.query(
        'transacciones',
        where: 'fecha >= ? AND fecha < ?',
        whereArgs: [fechaInicio, fechaFin],
      );

      return List.generate(maps.length, (i) {
        return Transaccion(
          id: maps[i]['id'],
          tipo: maps[i]['tipo'],
          monto: maps[i]['monto'],
          fecha: DateTime.parse(maps[i]['fecha']),
          descripcion: maps[i]['descripcion'],
          categoria: Categoria(
            nombre: maps[i]['categoria_nombre'],
            tipo: maps[i]['categoria_tipo'],
            icono: maps[i]['categoria_icono'],
          ),
        );
      });
    } catch (e) {
      _logger.severe('Error en getTransaccionesPorAnio: $e');
      return [];
    }
  }

  // Método para configurar base de datos de prueba
  void setTestDatabase(Database testDb) {
    _testDatabase = testDb;
  }

  // Método para limpiar configuración de prueba
  void clearTestDatabase() {
    _testDatabase = null;
  }
}
