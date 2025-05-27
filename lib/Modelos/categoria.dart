class Categoria {
  String nombre;
  String tipo; // 'ingreso' o 'egreso'
  String icono; // Puede ser un nombre, emoji, o código
  double? presupuestoMensual; // Nuevo: presupuesto mensual para egresos

  Categoria({
    required this.nombre,
    required this.tipo,
    required this.icono,
    this.presupuestoMensual,
  });

  // Para convertir a Map (útil al guardar como JSON)
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'tipo': tipo,
      'icono': icono,
      if (presupuestoMensual != null) 'presupuestoMensual': presupuestoMensual,
    };
  }

  // Para reconstruir desde JSON
  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      nombre: json['nombre'],
      tipo: json['tipo'],
      icono: json['icono'],
      presupuestoMensual: json['presupuestoMensual'] != null
          ? (json['presupuestoMensual'] as num).toDouble()
          : null,
    );
  }
}