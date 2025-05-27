class MetaAhorro {
  int? id;
  final String nombre;
  final double objetivo;
  double acumulado;
  final String icono;

  MetaAhorro({
    this.id,
    required this.nombre,
    required this.objetivo,
    required this.acumulado,
    required this.icono,
  });

  factory MetaAhorro.fromMap(Map<String, dynamic> map) {
    return MetaAhorro(
      id: map['id'],
      nombre: map['categoria_nombre'],
      objetivo: map['objetivo'],
      acumulado: map['acumulado'],
      icono: map['icono'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoria_nombre': nombre,
      'objetivo': objetivo,
      'acumulado': acumulado,
      'icono': icono,
    };
  }
}
