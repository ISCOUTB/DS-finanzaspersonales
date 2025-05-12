import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../Servicios/gestor_finanzas.dart';
import '../Modelos/transaccion.dart';

class CategoryBarChart extends StatefulWidget {
  final int selectedFilter;

  const CategoryBarChart({super.key, required this.selectedFilter});

  @override
  State<CategoryBarChart> createState() => _CategoryBarChartState();
}

class _CategoryBarChartState extends State<CategoryBarChart> {
  final GestorFinanzas _gestorFinanzas = GestorFinanzas();
  List<Transaccion> transacciones = [];

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

  BarChartData _generateBarData() {
    final filtro = ['día', 'semana', 'mes', 'año'][widget.selectedFilter].toLowerCase();
    final transaccionesFiltradas = _gestorFinanzas.obtenerTransaccionesFiltradas(filtro);
    
    // Agrupar por categoría y tipo
    final Map<String, Map<String, double>> datos = {};
    for (var t in transaccionesFiltradas) {
      datos[t.categoria.nombre] = datos[t.categoria.nombre] ?? {'ingreso': 0, 'gasto': 0};
      datos[t.categoria.nombre]![t.tipo] = (datos[t.categoria.nombre]![t.tipo] ?? 0) + t.monto;
    }

    final List<BarChartGroupData> barGroups = [];
    var index = 0;

    datos.forEach((categoria, valores) {
      barGroups.add(
        BarChartGroupData(
          x: index++,
          barRods: [
            BarChartRodData(
              toY: valores['ingreso'] ?? 0,
              color: Colors.green,
              width: 16,
            ),
            BarChartRodData(
              toY: valores['gasto'] ?? 0,
              color: Colors.red,
              width: 16,
            ),
          ],
        ),
      );
    });

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: datos.values
          .expand((map) => map.values)
          .reduce((max, value) => value > max ? value : max) * 1.2,
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              if (value >= 0 && value < datos.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    datos.keys.elementAt(value.toInt()),
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 60,
            getTitlesWidget: (value, meta) {
              return Text(
                '\$${value.toInt()}',
                style: const TextStyle(fontSize: 12),
              );
            },
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      barGroups: barGroups,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          SizedBox(
            height: 400,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BarChart(_generateBarData()),
            ),
          ),
          // Leyenda
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Ingresos', Colors.green),
                const SizedBox(width: 20),
                _buildLegendItem('Gastos', Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}