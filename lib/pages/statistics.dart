import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../Modelos/transaccion.dart';
import '../Modelos/categoria.dart';
import '../Servicios/gestor_finanzas.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  String _selectedFilter = 'mes';
  final _gestorFinanzas = GestorFinanzas();
  List<Transaccion> _transacciones = [];
  
  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    await _gestorFinanzas.cargarTransacciones();
    setState(() {
      _transacciones = _gestorFinanzas.transacciones;
    });
  }

  Map<String, double> _calculateCategoryTotals(String type) {
    Map<String, double> categoryTotals = {};
    DateTime now = DateTime.now();

    for (var transaction in _transacciones) {
      if (transaction.tipo != type) continue;

      bool includeTransaction = false;
      switch (_selectedFilter) {
        case 'día':
          includeTransaction = transaction.fecha.year == now.year &&
              transaction.fecha.month == now.month &&
              transaction.fecha.day == now.day;
          break;
        case 'semana':
          DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          includeTransaction = transaction.fecha.isAfter(
              startOfWeek.subtract(const Duration(days: 1))) &&
              transaction.fecha.isBefore(startOfWeek.add(const Duration(days: 7)));
          break;
        case 'mes':
          includeTransaction = transaction.fecha.year == now.year &&
              transaction.fecha.month == now.month;
          break;
        case 'año':
          includeTransaction = transaction.fecha.year == now.year;
          break;
      }

      if (includeTransaction) {
        categoryTotals[transaction.categoria.nombre] =
            (categoryTotals[transaction.categoria.nombre] ?? 0) +
                transaction.monto;
      }
    }
    return categoryTotals;
  }

  List<BarChartGroupData> _generateBarGroups() {
    Map<int, Map<String, double>> monthlyData = {};
    DateTime now = DateTime.now();
    
    // Inicializar los últimos 6 meses con 0
    for (int i = 5; i >= 0; i--) {
      DateTime month = DateTime(now.year, now.month - i, 1);
      monthlyData[month.month] = {'ingresos': 0, 'gastos': 0};
    }

    // Calcular totales por mes
    for (var transaction in _transacciones) {
      if (transaction.fecha.year == now.year &&
          transaction.fecha.month > now.month - 6) {
        monthlyData[transaction.fecha.month]![transaction.tipo] =
            (monthlyData[transaction.fecha.month]![transaction.tipo] ?? 0) +
                transaction.monto;
      }
    }

    // Convertir datos a BarChartGroupData
    List<BarChartGroupData> barGroups = [];
    int index = 0;
    monthlyData.forEach((month, data) {
      barGroups.add(
        BarChartGroupData(
          x: index++,
          barRods: [
            BarChartRodData(
              toY: data['ingresos']!,
              color: const Color.fromARGB(255, 113, 180, 116),
              width: 16,
            ),
            BarChartRodData(
              toY: data['gastos']!,
              color: const Color.fromARGB(255, 195, 105, 104),
              width: 16,
            ),
          ],
        ),
      );
    });

    return barGroups;
  }

  @override
  Widget build(BuildContext context) {
    Map<String, double> incomeTotals = _calculateCategoryTotals('ingreso');
    Map<String, double> expenseTotals = _calculateCategoryTotals('gasto');

    return Scaffold(
      backgroundColor: const Color.fromARGB(225, 47, 125, 121),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            // Filtros
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['día', 'semana', 'mes', 'año'].map((filter) {
                  bool isSelected = _selectedFilter == filter;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? const Color(0xff368983) : Colors.white,
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
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Resumen de totales
                    _buildTotalSummary(incomeTotals, expenseTotals),
                    const SizedBox(height: 30),
                    // Gráficos de pastel
                    Row(
                      children: [
                        Expanded(
                          child: _buildPieChartSection(
                            'Ingresos por Categoría',
                            incomeTotals,
                            Colors.green,
                          ),
                        ),
                        Expanded(
                          child: _buildPieChartSection(
                            'Gastos por Categoría',
                            expenseTotals,
                            Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Gráfico de barras
                    const Text(
                      'Comparativa Mensual',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 300,
                      child: _buildBarChart(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSummary(Map<String, double> incomeTotals, Map<String, double> expenseTotals) {
    double totalIncome = incomeTotals.values.fold(0, (sum, value) => sum + value);
    double totalExpense = expenseTotals.values.fold(0, (sum, value) => sum + value);
    
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem('Ingresos', totalIncome, Colors.green),
              _buildSummaryItem('Gastos', totalExpense, Colors.red),
            ],
          ),
          const Divider(),
          _buildSummaryItem(
            'Balance',
            totalIncome - totalExpense,
            (totalIncome - totalExpense) >= 0 ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPieChartSection(String title, Map<String, double> data, Color baseColor) {
    if (data.isEmpty) {
      return Center(
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text('No hay datos disponibles'),
          ],
        ),
      );
    }

    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: Stack(
            children: [
              PieChart(
                PieChartData(
                  sections: _generatePieSections(data),
                  sectionsSpace: 0,
                  centerSpaceRadius: 30,
                ),
              ),
              Center(
                child: Text(
                  '\$${data.values.fold(0.0, (sum, value) => sum + value).toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Column(
          children: data.entries.map((entry) {
            final percentage = (entry.value / data.values.fold(0.0, (sum, value) => sum + value) * 100);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.primaries[data.keys.toList().indexOf(entry.key) % Colors.primaries.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    final barGroups = _generateBarGroups();
    if (barGroups.isEmpty) {
      return const Center(child: Text('No hay datos disponibles'));
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _calculateMaxY(),
        barGroups: barGroups,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text('\$${value.toInt()}');
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun'];
                if (value.toInt() >= 0 && value.toInt() < months.length) {
                  return Text(months[value.toInt()]);
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  List<PieChartSectionData> _generatePieSections(Map<String, double> totals) {
    if (totals.isEmpty) {
      return [
        PieChartSectionData(
          color: Colors.grey,
          value: 100,
          title: '0%',
          radius: 50,
          titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
        )
      ];
    }

    final double total = totals.values.reduce((a, b) => a + b);
    final List<Color> colors = [
      const Color(0xff368983),
      const Color(0xff44A3A5),
      const Color(0xff50C2C9),
      const Color(0xff36898F),
      const Color(0xff2D7A7F),
    ];

    return totals.entries.map((entry) {
      final double percentage = (entry.value / total) * 100;
      final int colorIndex = totals.keys.toList().indexOf(entry.key) % colors.length;
      
      return PieChartSectionData(
        color: colors[colorIndex],
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%\n\$${entry.value.toStringAsFixed(0)}',
        radius: 50,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();
  }

  double _calculateMaxY() {
    double maxValue = 0;
    for (var group in _generateBarGroups()) {
      for (var rod in group.barRods) {
        if (rod.toY > maxValue) maxValue = rod.toY;
      }
    }
    return maxValue * 1.2; // Añadir 20% de espacio extra
  }
}