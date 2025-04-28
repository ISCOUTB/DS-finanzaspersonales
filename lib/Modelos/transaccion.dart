import 'categoria.dart';

class Transaccion {
  String id;
  String tipo; // 'ingreso' o 'egreso'
  double monto;
  DateTime fecha;
  Categoria categoria;
  String? descripcion;

  Transaccion({
    required this.id,
    required this.tipo,
    required this.monto,
    required this.fecha,
    required this.categoria,
    this.descripcion,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo,
      'monto': monto,
      'fecha': fecha.toIso8601String(),
      'categoria': categoria.toJson(),
      'descripcion': descripcion,
    };
  }

  factory Transaccion.fromJson(Map<String, dynamic> json) {
    return Transaccion(
      id: json['id'],
      tipo: json['tipo'],
      monto: json['monto'],
      fecha: DateTime.parse(json['fecha']),
      categoria: Categoria.fromJson(json['categoria']),
      descripcion: json['descripcion'],
    );
  }
}