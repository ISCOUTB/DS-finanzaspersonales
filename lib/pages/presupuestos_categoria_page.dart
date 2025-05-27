import 'package:flutter/material.dart';
import '../Modelos/categoria_service.dart';
import '../Servicios/gestor_finanzas.dart';

// Servicio de sesión para presupuesto general (solo memoria, no persistente)
class PresupuestoSession {
  static double presupuestoGeneral = 60000;
}

class PresupuestosPage extends StatefulWidget {
  const PresupuestosPage({Key? key}) : super(key: key);

  @override
  State<PresupuestosPage> createState() => _PresupuestosPageState();
}

class _PresupuestosPageState extends State<PresupuestosPage> {
  String _tipoPresupuesto = 'general'; // 'general' o 'categorias'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Presupuestos'),
        backgroundColor: const Color(0xFF368983),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Tipo de presupuesto:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _tipoPresupuesto,
                  items: const [
                    DropdownMenuItem(value: 'general', child: Text('General')),
                    DropdownMenuItem(value: 'categorias', child: Text('Por Categorías')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _tipoPresupuesto = value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (_tipoPresupuesto == 'general') ...[
              // Calcular gasto total del mes
              Builder(
                builder: (context) {
                  final gestor = GestorFinanzas();
                  final transacciones = gestor.transacciones;
                  final now = DateTime.now();
                  // Si no hay transacciones, gastado debe ser 0
                  final gastado = transacciones
                      .where((t) => t.tipo == 'egreso' && t.fecha.year == now.year && t.fecha.month == now.month)
                      .fold(0.0, (sum, t) => sum + t.monto);
                  final presupuestoGeneral = PresupuestoSession.presupuestoGeneral;
                  final porcentaje = presupuestoGeneral > 0 ? (gastado / presupuestoGeneral).clamp(0.0, 1.0) : 0.0;
                  final colorBarra = porcentaje >= 1 ? Colors.red : const Color(0xFF368983);
                  return Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF232D36)
                        : Colors.grey[200],
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.account_balance_wallet, color: Color(0xFF368983), size: 28),
                              const SizedBox(width: 10),
                              const Text('Presupuesto General', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: colorBarra.withOpacity(0.13),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  '${(porcentaje * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    color: colorBarra,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              const Text('Límite mensual:', style: TextStyle(fontSize: 15)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: TextFormField(
                                  initialValue: PresupuestoSession.presupuestoGeneral.toStringAsFixed(0),
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(suffixText: 'COP', border: InputBorder.none),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  onChanged: (val) {
                                    final parsed = double.tryParse(val.replaceAll(',', ''));
                                    if (parsed != null) {
                                      setState(() {
                                        PresupuestoSession.presupuestoGeneral = parsed;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0, end: porcentaje > 1 ? 1 : porcentaje),
                              duration: const Duration(milliseconds: 800),
                              builder: (context, value, child) => LinearProgressIndicator(
                                value: value,
                                backgroundColor: Colors.grey[300],
                                color: colorBarra,
                                minHeight: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Gastado: ${gastado.toStringAsFixed(2)} COP', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                              presupuestoGeneral > 0
                                ? Text('Límite: ${presupuestoGeneral.toStringAsFixed(0)} COP', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))
                                : const Text('Sin presupuesto', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey)),
                            ],
                          ),
                          if (porcentaje >= 1)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                children: const [
                                  Icon(Icons.warning, color: Colors.red, size: 20),
                                  SizedBox(width: 6),
                                  Text('¡Has superado tu presupuesto!', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              // Mostrar lista de egresos recientes debajo del presupuesto general
              Builder(
                builder: (context) {
                  final gestor = GestorFinanzas();
                  final transacciones = gestor.transacciones;
                  final now = DateTime.now();
                  // Mostrar lista de egresos recientes del mes
                  final egresosMes = transacciones
                      .where((t) => t.tipo == 'egreso' && t.fecha.year == now.year && t.fecha.month == now.month)
                      .toList();
                  if (egresosMes.isEmpty) return Container(); // No mostrar nada si no hay egresos
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 18),
                      const Text('Egresos recientes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      ...egresosMes.map((t) => Card(
                        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF232D36) : Colors.grey[200],
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            child: Text(t.categoria.icono, style: const TextStyle(fontSize: 24)),
                          ),
                          title: Text(
                            t.categoria.nombre,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            '${t.fecha.day}/${t.fecha.month}/${t.fecha.year}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          trailing: Text(
                            '- ${t.monto.toStringAsFixed(2)} COP',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )),
                    ],
                  );
                },
              ),
            ] else ...[
              // Mostrar el resumen de todas las categorías con presupuesto y opciones de agregar, editar y eliminar
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF368983),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text('Agregar'),
                          onPressed: () async {
                            final categorias = CategoriaService.getCategoriasGastos()
                                .where((c) => c.presupuestoMensual == null || c.presupuestoMensual == 0)
                                .toList();
                            if (categorias.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hay categorías disponibles para agregar presupuesto.')));
                              return;
                            }
                            String? seleccionada;
                            double? monto;
                            await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Agregar presupuesto a categoría'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    DropdownButtonFormField<String>(
                                      items: categorias.map((c) => DropdownMenuItem(value: c.nombre, child: Text('${c.icono} ${c.nombre}'))).toList(),
                                      onChanged: (v) => seleccionada = v,
                                      decoration: const InputDecoration(labelText: 'Categoría'),
                                    ),
                                    TextFormField(
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(labelText: 'Presupuesto mensual (COP)'),
                                      onChanged: (v) => monto = double.tryParse(v.replaceAll(',', '')),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.pop(context)),
                                  ElevatedButton(
                                    child: const Text('Guardar'),
                                    onPressed: () {
                                      if (seleccionada != null && monto != null && monto! > 0) {
                                        final cat = CategoriaService.getCategoriasGastos().firstWhere((c) => c.nombre == seleccionada);
                                        setState(() => cat.presupuestoMensual = monto);
                                        Navigator.pop(context);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView(
                        children: [
                          ...CategoriaService.getCategoriasGastos()
                              .where((c) => c.presupuestoMensual != null && c.presupuestoMensual! > 0)
                              .map((cat) {
                            final gestor = GestorFinanzas();
                            final transacciones = gestor.transacciones;
                            final now = DateTime.now();
                            final gastado = transacciones.isEmpty
                                ? 0.0
                                : transacciones
                                    .where((t) => t.tipo == 'egreso' && t.categoria.nombre == cat.nombre && t.fecha.year == now.year && t.fecha.month == now.month)
                                    .fold(0.0, (sum, t) => sum + t.monto);
                            final porcentaje = cat.presupuestoMensual! > 0 ? (gastado / cat.presupuestoMensual!).clamp(0.0, 1.0) : 0.0;
                            final colorBarra = porcentaje >= 1 ? Colors.red : const Color(0xFF368983);
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(cat.icono, style: const TextStyle(fontSize: 28)),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            cat.nombre,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: colorBarra.withOpacity(0.13),
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          child: Text(
                                            '${(porcentaje * 100).toStringAsFixed(0)}%',
                                            style: TextStyle(
                                              color: colorBarra,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Color(0xFF368983)),
                                          tooltip: 'Editar',
                                          onPressed: () async {
                                            double? nuevoMonto = cat.presupuestoMensual;
                                            await showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text('Editar presupuesto de ${cat.icono} ${cat.nombre}'),
                                                content: TextFormField(
                                                  initialValue: cat.presupuestoMensual?.toStringAsFixed(0),
                                                  keyboardType: TextInputType.number,
                                                  decoration: const InputDecoration(labelText: 'Presupuesto mensual (COP)'),
                                                  onChanged: (v) => nuevoMonto = double.tryParse(v.replaceAll(',', '')),
                                                ),
                                                actions: [
                                                  TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.pop(context)),
                                                  ElevatedButton(
                                                    child: const Text('Guardar'),
                                                    onPressed: () {
                                                      if (nuevoMonto != null && nuevoMonto! > 0) {
                                                        setState(() => cat.presupuestoMensual = nuevoMonto);
                                                        Navigator.pop(context);
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          tooltip: 'Eliminar',
                                          onPressed: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text('Eliminar presupuesto'),
                                                content: Text('¿Eliminar el presupuesto de la categoría ${cat.icono} ${cat.nombre}?'),
                                                actions: [
                                                  TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.pop(context, false)),
                                                  ElevatedButton(
                                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                    child: const Text('Eliminar'),
                                                    onPressed: () => Navigator.pop(context, true),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (confirm == true) {
                                              setState(() => cat.presupuestoMensual = 0);
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: LinearProgressIndicator(
                                        value: porcentaje > 1 ? 1 : porcentaje,
                                        backgroundColor: Colors.grey[200],
                                        color: colorBarra,
                                        minHeight: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text('Gastado: ${gastado.toStringAsFixed(2)} COP', style: const TextStyle(fontSize: 14)),
    cat.presupuestoMensual! > 0
      ? Text('Límite: ${cat.presupuestoMensual!.toStringAsFixed(0)} COP', style: const TextStyle(fontSize: 14))
      : const Text('Sin presupuesto', style: TextStyle(fontSize: 14, color: Colors.grey)),
  ],
),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PresupuestosPorCategoriaView extends StatefulWidget {
  const _PresupuestosPorCategoriaView();

  @override
  State<_PresupuestosPorCategoriaView> createState() => _PresupuestosPorCategoriaViewState();
}

class _PresupuestosPorCategoriaViewState extends State<_PresupuestosPorCategoriaView> {
  String? _categoriaSeleccionada;

  @override
  Widget build(BuildContext context) {
    final categorias = CategoriaService.getCategoriasGastos()
        .where((c) => c.presupuestoMensual != null && c.presupuestoMensual! > 0)
        .toList();
    final gestor = GestorFinanzas();
    final transacciones = gestor.transacciones;
    final now = DateTime.now();
    Map<String, double> gastosPorCategoria = {};
    for (var cat in categorias) {
      final total = transacciones
          .where((t) =>
              t.tipo == 'egreso' &&
              t.categoria.nombre == cat.nombre &&
              t.fecha.year == now.year &&
              t.fecha.month == now.month)
          .fold(0.0, (sum, t) => sum + t.monto);
      gastosPorCategoria[cat.nombre] = total;
    }
    if (categorias.isEmpty) {
      return const Center(
        child: Text('No hay presupuestos definidos para categorías.', style: TextStyle(fontSize: 17, color: Color(0xFF368983))),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        if (_categoriaSeleccionada != null)
          Builder(
            builder: (context) {
              final cat = categorias.firstWhere((c) => c.nombre == _categoriaSeleccionada);
              final gastado = gastosPorCategoria[cat.nombre] ?? 0.0;
              final presupuesto = cat.presupuestoMensual!;
              final porcentaje = (gastado / presupuesto).clamp(0.0, 1.0);
              final sobrepasado = gastado > presupuesto;
              final colorBarra = sobrepasado ? Colors.red : const Color(0xFF368983);
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colorBarra.withOpacity(0.18)),
                  boxShadow: [
                    BoxShadow(
                      color: colorBarra.withOpacity(0.07),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(cat.icono, style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            cat.nombre,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorBarra.withOpacity(0.13),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            '${(porcentaje * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: colorBarra,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: porcentaje > 1 ? 1 : porcentaje,
                        backgroundColor: Colors.grey[200],
                        color: colorBarra,
                        minHeight: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Gastado: ${gastado.toStringAsFixed(0)} COP', style: const TextStyle(fontSize: 14)),
                        Text('Límite: ${presupuesto.toStringAsFixed(0)} COP', style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        const SizedBox(height: 80), // Espacio para el botón flotante
      ],
    );
  }
}
