import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class IncomeExpenses extends StatefulWidget {
  const IncomeExpenses({Key? key}) : super(key: key);

  @override
  State<IncomeExpenses> createState() => _IncomeExpensesState();
}

class _IncomeExpensesState extends State<IncomeExpenses> {
  final List<String> filters = ['Day', 'Week', 'Month', 'Year'];
  int selectedFilter = 2; // Month por defecto

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Ingresos y Egresos',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Center(
                child: Wrap(
                  spacing: 8,
                  children: List.generate(filters.length, (index) {
                    final bool isSelected = selectedFilter == index;
                    return ChoiceChip(
                      label: Text(filters[index]),
                      selected: isSelected,
                      selectedColor: Colors.teal,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.teal[800],
                      ),
                      onSelected: (_) {
                        setState(() {
                          selectedFilter = index;
                        });
                      },
                    );
                  }),
                ),
              ),
              const SizedBox(height: 25),
              AspectRatio(
                aspectRatio: 1.5,
                child: BarChart(generateGroupedBarChartData(selectedFilter)),
              ),
              const SizedBox(height: 20),
              Text(
                'Período: ${filters[selectedFilter]}',
                style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Historial de transacciones',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Icon(Icons.swap_vert),
                ],
              ),
              const SizedBox(height: 10),
              transactionItem('Salario', '01 Mar 2025', 1200.0),
              transactionItem('Alquiler', '01 Mar 2025', -400.0),
              transactionItem('Comida', '02 Mar 2025', -150.0),
              transactionItem('Uber', '03 Mar 2025', -30.0),
            ],
          ),
        ),
      ),
    );
  }

  BarChartData generateGroupedBarChartData(int filterIndex) {
    List<String> labels = [];
    List<double> ingresos = [];
    List<double> egresos = [];

    switch (filters[filterIndex]) {
      case 'Day':
        labels = ['6 AM', '9 AM', '12 PM', '3 PM'];
        ingresos = [50, 70, 40, 90];
        egresos = [20, 30, 25, 10];
        break;
      case 'Week':
        labels = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes'];
        ingresos = [100, 80, 70, 90, 60];
        egresos = [40, 50, 30, 35, 20];
        break;
      case 'Month':
        labels = ['Alquiler', 'Comida', 'Transporte', 'Ocio', 'Otros'];
        ingresos = [500, 300, 200, 150, 100];  // Ingresos por categoría
        egresos = [400, 250, 120, 80, 90];     // Egresos por categoría
        break;
      case 'Year':
        labels = ['2021', '2022', '2023', '2024', '2025'];
        ingresos = [1200, 1400, 1300, 1500, 1700];
        egresos = [900, 1100, 1000, 1300, 1400];
        break;
    }

    final barGroups = List.generate(labels.length, (i) {
      return BarChartGroupData(
        x: i,
        barsSpace: 6,
        barRods: [
          BarChartRodData(
            toY: ingresos[i],
            width: 18,
            color: Colors.green, // Ingresos en verde
            borderRadius: BorderRadius.zero,
          ),
          BarChartRodData(
            toY: egresos[i],
            width: 18,
            color: Colors.red, // Egresos en rojo
            borderRadius: BorderRadius.zero,
          ),
        ],
      );
    });

    return BarChartData(
      maxY: ([...ingresos, ...egresos].reduce((a, b) => a > b ? a : b)) + 100,
      barGroups: barGroups,
      barTouchData: BarTouchData(enabled: true),
      gridData: FlGridData(show: true),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 42,
            getTitlesWidget: (value, meta) {
              if (value.toInt() < labels.length) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 6,
                  child: Text(
                    labels[value.toInt()],
                    style: const TextStyle(fontSize: 11),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 36,
            getTitlesWidget: (value, meta) {
              return Text(
                '\$${value.toInt()}',
                style: const TextStyle(fontSize: 10),
              );
            },
          ),
        ),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
    );
  }

  Widget transactionItem(String title, String date, double amount) {
    final bool isPositive = amount > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          splashColor: Colors.teal.withOpacity(0.2),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Transacción: $title')),
            );
          },
          child: Ink(
            decoration: BoxDecoration(
              color: isPositive ? Colors.teal[50] : Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(date, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                Text(
                  '${isPositive ? '+' : '-'} \$${amount.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
