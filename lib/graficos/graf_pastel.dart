import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../Servicios/gestor_finanzas.dart';
import '../Modelos/transaccion.dart';

class CategoryPieChart extends StatefulWidget {
  final int selectedFilter;
  final String tipo; // 'ingreso' o 'gasto'

  const CategoryPieChart({
    super.key,
    required this.selectedFilter,
    required this.tipo, // Asegúrate de que este parámetro sea requerido
  });

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  final GestorFinanzas _gestorFinanzas = GestorFinanzas();
  List<Transaccion> transacciones = [];
  final Map<String, Color> categoryColors = {
    'Comida': Colors.green,
    'Transporte': Colors.blue,
    'Vivienda': Colors.orange,
    'Servicios': Colors.red,
    'Entretenimiento': Colors.purple,
    'Salud': Colors.teal,
    'Educación': Colors.amber,
    'Otros': Colors.grey,
  };

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    await _gestorFinanzas.cargarTransacciones();
    if (mounted) {
      setState(() {
        transacciones = _gestorFinanzas.transacciones;
      });
    }
  }

  List<PieChartSectionData> _generateSections() {
    final filtro = ['día', 'semana', 'mes', 'año'][widget.selectedFilter].toLowerCase();
    final transaccionesFiltradas = _gestorFinanzas.obtenerTransaccionesFiltradas(filtro)
        .where((t) => t.tipo == widget.tipo) // Usa el parámetro 'tipo' para filtrar
        .toList();

    final Map<String, double> porCategoria = {};
    for (var t in transaccionesFiltradas) {
      final categoria = t.categoria.nombre;
      porCategoria[categoria] = (porCategoria[categoria] ?? 0) + t.monto;
    }

    final total = porCategoria.values.fold(0.0, (sum, amount) => sum + amount);

    return porCategoria.entries.map((entry) {
      final percentage = total > 0 ? (entry.value / total * 100) : 0;
      return PieChartSectionData(
        color: categoryColors[entry.key] ?? Colors.grey,
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildPieChart(List<PieChartSectionData> sections) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.tipo == 'ingreso' ? 'Ingresos por Categoría' : 'Gastos por Categoría',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 300,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 20),
        ..._buildLegend(sections),
      ],
    );
  }

  List<Widget> _buildLegend(List<PieChartSectionData> sections) {
    return sections.map((section) {
      final categoryName = categoryColors.keys.firstWhere(
        (key) => categoryColors[key] == section.color,
        orElse: () => 'Otros',
      );
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: section.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                categoryName,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            Text(
              '\$${section.value.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final sections = _generateSections();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildPieChart(sections),
      ),
    );
  }
}
