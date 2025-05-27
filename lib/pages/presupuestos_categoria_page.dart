import 'package:flutter/material.dart';
import '../Modelos/categoria_service.dart';
import '../Servicios/gestor_finanzas.dart';

class PresupuestosPage extends StatefulWidget {
  const PresupuestosPage({Key? key}) : super(key: key);

  @override
  State<PresupuestosPage> createState() => _PresupuestosPageState();
}

class _PresupuestosPageState extends State<PresupuestosPage> {
  String _tipoPresupuesto = 'general'; // 'general' o 'categorias'
  double _presupuestoGeneral = 60000; // Valor por defecto, editable si lo deseas

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
              Card(
                color: const Color(0xFF368983).withOpacity(0.07),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Presupuesto General', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text('Límite mensual: ', style: TextStyle(fontSize: 15)),
                          Expanded(
                            child: TextFormField(
                              initialValue: _presupuestoGeneral.toStringAsFixed(0),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(suffixText: 'COP'),
                              onChanged: (val) {
                                final parsed = double.tryParse(val.replaceAll(',', ''));
                                if (parsed != null) setState(() => _presupuestoGeneral = parsed);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _PresupuestoGeneralBar(presupuesto: _presupuestoGeneral),
                    ],
                  ),
                ),
              ),
            ] else ...[
              const _PresupuestosPorCategoriaView(),
            ],
          ],
        ),
      ),
    );
  }
}

class _PresupuestoGeneralBar extends StatelessWidget {
  final double presupuesto;
  const _PresupuestoGeneralBar({required this.presupuesto});

  @override
  Widget build(BuildContext context) {
    final gestor = GestorFinanzas();
    final transacciones = gestor.transacciones;
    final now = DateTime.now();
    final gastado = transacciones
        .where((t) => t.tipo == 'egreso' && t.fecha.year == now.year && t.fecha.month == now.month)
        .fold(0.0, (sum, t) => sum + t.monto);
    final porcentaje = (gastado / presupuesto).clamp(0.0, 1.0);
    final sobrepasado = gastado > presupuesto;
    final colorBarra = sobrepasado ? Colors.red : const Color(0xFF368983);
    final colorFondo = sobrepasado ? Colors.red.withOpacity(0.08) : const Color(0xFF368983).withOpacity(0.07);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      return Stack(
        children: [
          const Center(
            child: Text('No hay presupuestos definidos para categorías.', style: TextStyle(fontSize: 17, color: Color(0xFF368983))),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: FloatingActionButton(
              backgroundColor: const Color(0xFF368983),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.add, size: 36),
              onPressed: () {
                // Aquí podrías abrir el modal para agregar una categoría o presupuesto
              },
            ),
          ),
        ],
      );
    }
    return Stack(
      children: [
        Column(
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
                  final colorFondo = sobrepasado ? Colors.red.withOpacity(0.08) : const Color(0xFF368983).withOpacity(0.07);
                  return Container(
                    decoration: BoxDecoration(
                      color: colorFondo,
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
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: FloatingActionButton(
            backgroundColor: const Color(0xFF368983),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: const Icon(Icons.add, size: 36),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (BuildContext context) {
                  return SizedBox(
                    height: 320,
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        const Text('Selecciona una categoría', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 16),
                        ...categorias.map((cat) => ListTile(
                              leading: Text(cat.icono, style: const TextStyle(fontSize: 24)),
                              title: Text(cat.nombre),
                              onTap: () {
                                setState(() {
                                  _categoriaSeleccionada = cat.nombre;
                                });
                                Navigator.pop(context);
                              },
                            )),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
