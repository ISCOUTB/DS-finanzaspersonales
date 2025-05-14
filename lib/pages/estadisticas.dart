import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../Modelos/transaccion.dart';
import '../Servicios/gestor_finanzas.dart';

class EstadisticasPage extends StatefulWidget {
  const EstadisticasPage({super.key});

  @override
  State<EstadisticasPage> createState() => _EstadisticasPageState();
}

class _EstadisticasPageState extends State<EstadisticasPage> {
  String _selectedFilter = 'día';
  List<Transaccion> _transacciones = [];
  final _gestorFinanzas = GestorFinanzas();

  @override
  void initState() {
    super.initState();
    cargarTransacciones();
  }

  Future<void> cargarTransacciones() async {
    await _gestorFinanzas.cargarTransacciones();
    if (mounted) {
      setState(() {
        _transacciones = _gestorFinanzas.transacciones;
      });
    }
  }

  Map<String, double> _calculateCategoryTotals(String tipo) {
    Map<String, double> categoryTotals = {};
    DateTime now = DateTime.now();

    for (var transaccion in _transacciones) {
      bool includeTransaction = false;

      switch (_selectedFilter) {
        case 'día':
          includeTransaction = transaccion.fecha.year == now.year &&
              transaccion.fecha.month == now.month &&
              transaccion.fecha.day == now.day;
          break;
        case 'semana':
          DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          includeTransaction = transaccion.fecha.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
              transaccion.fecha.isBefore(startOfWeek.add(const Duration(days: 7)));
          break;
        case 'mes':
          includeTransaction = transaccion.fecha.year == now.year &&
              transaccion.fecha.month == now.month;
          break;
        case 'año':
          includeTransaction = transaccion.fecha.year == now.year;
          break;
      }

      if (includeTransaction && transaccion.tipo == tipo) {
        categoryTotals[transaccion.categoria.nombre] =
            (categoryTotals[transaccion.categoria.nombre] ?? 0) + transaccion.monto;
      }
    }

    return categoryTotals;
  }

  PieChartData generatePieChartData(Map<String, double> categoryTotals) {
    if (categoryTotals.isEmpty) {
      return PieChartData(
        sections: [
          PieChartSectionData(
            color: Colors.grey,
            value: 1,
            title: 'Sin datos',
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      );
    }

    final double total = categoryTotals.values.reduce((a, b) => a + b);
    final List<Color> colors = [
      const Color(0xff368983),
      const Color(0xff44A3A5),
      const Color(0xff50C2C9),
      const Color(0xff36898F),
      const Color(0xff2D7A7F),
    ];

    return PieChartData(
      sectionsSpace: 0,
      centerSpaceRadius: 50,
      sections: categoryTotals.entries.map((entry) {
        final double percentage = (entry.value / total) * 100;
        final int colorIndex = categoryTotals.keys.toList().indexOf(entry.key) % colors.length;

        return PieChartSectionData(
          color: colors[colorIndex],
          value: entry.value,
          title: '${percentage.toStringAsFixed(1)}%', // Mostrar porcentaje
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final incomeTotals = _calculateCategoryTotals('ingreso');
    final expenseTotals = _calculateCategoryTotals('gasto');
    final List<Color> colors = [
      const Color(0xff368983),
      const Color(0xff44A3A5),
      const Color(0xff50C2C9),
      const Color(0xff36898F),
      const Color(0xff2D7A7F),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
        backgroundColor: const Color(0xff368983),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Filtros
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['día', 'semana', 'mes', 'año'].map((filter) {
                  bool isSelected = _selectedFilter == filter;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = filter),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xff368983) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xff368983)),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xff368983),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            // Gráfico de pastel para ingresos
            const Text(
              'Ingresos por Categoría',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Container(
              height: 220,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              margin: const EdgeInsets.only(bottom: 20),
              child: PieChart(generatePieChartData(incomeTotals)),
            ),
            // Leyenda para ingresos
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: incomeTotals.entries.map((entry) {
                  final int colorIndex = incomeTotals.keys.toList().indexOf(entry.key) % colors.length;
                  return Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: colors[colorIndex],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.key,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Text(
                        '\$${entry.value.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            // Gráfico de pastel para gastos
            const Text(
              'Gastos por Categoría',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Container(
              height: 220,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              margin: const EdgeInsets.only(bottom: 20),
              child: PieChart(generatePieChartData(expenseTotals)),
            ),
            // Leyenda para gastos
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: expenseTotals.entries.map((entry) {
                  final int colorIndex = expenseTotals.keys.toList().indexOf(entry.key) % colors.length;
                  return Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: colors[colorIndex],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.key,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Text(
                        '\$${entry.value.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}