import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../Servicios/gestor_finanzas.dart';
import '../Modelos/transaccion.dart';

class IncomeExpenses extends StatefulWidget {
  final int filterIndex;

  const IncomeExpenses({super.key, required this.filterIndex});

  @override
  State<IncomeExpenses> createState() => _IncomeExpensesState();
}

class _IncomeExpensesState extends State<IncomeExpenses> {
  final List<String> filters = ['día', 'semana', 'mes', 'año'];
  final GestorFinanzas _gestorFinanzas = GestorFinanzas();
  List<Transaccion> transacciones = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    await _gestorFinanzas.cargarTransacciones();
    setState(() {
      transacciones = _gestorFinanzas.transacciones;
    });
  }

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
                    final bool isSelected = widget.filterIndex == index;
                    return ChoiceChip(
                      label: Text(filters[index]),
                      selected: isSelected,
                      selectedColor: Colors.teal,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.teal[800],
                      ),
                      onSelected: (_) {
                        setState(() {
                          // No se actualiza el filtro aquí porque ahora es un parámetro
                        });
                      },
                    );
                  }),
                ),
              ),
              const SizedBox(height: 25),
              AspectRatio(
                aspectRatio: 1.5,
                child: BarChart(
                  generateGroupedBarChartData(widget.filterIndex),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Período: ${filters[widget.filterIndex]}',
                style: const TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Historial de transacciones',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Icon(Icons.swap_vert),
                ],
              ),
              const SizedBox(height: 10),
              ...transacciones.map(
                (transaccion) => transactionItem(
                  transaccion.descripcion ?? 'Sin descripción',
                  transaccion.fecha.toString(),
                  transaccion.monto,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BarChartData generateGroupedBarChartData(int filterIndex) {
    final filteredTransactions = _gestorFinanzas.obtenerTransaccionesFiltradas(
      filters[filterIndex],
    );

    List<String> labels = [];
    List<double> ingresos = [];
    List<double> egresos = [];

    switch (filters[filterIndex]) {
      case 'día':
        // Agrupar por horas del día
        labels = ['Mañana', 'Tarde', 'Noche'];
        var ingresosMap = _agruparTransaccionesPorPeriodo(
          filteredTransactions.where((t) => t.tipo == 'ingreso').toList(),
          'día',
        );
        var egresosMap = _agruparTransaccionesPorPeriodo(
          filteredTransactions.where((t) => t.tipo == 'gasto').toList(),
          'día',
        );

        for (final periodo in labels) {
          ingresos.add(ingresosMap[periodo] ?? 0);
          egresos.add(egresosMap[periodo] ?? 0);
        }
        break;

      case 'semana':
        // Agrupar por días de la semana
        labels = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
        var ingresosMap = _agruparTransaccionesPorPeriodo(
          filteredTransactions.where((t) => t.tipo == 'ingreso').toList(),
          'semana',
        );
        var egresosMap = _agruparTransaccionesPorPeriodo(
          filteredTransactions.where((t) => t.tipo == 'gasto').toList(),
          'semana',
        );

        for (final dia in labels) {
          ingresos.add(ingresosMap[dia] ?? 0);
          egresos.add(egresosMap[dia] ?? 0);
        }
        break;

      case 'mes':
        // Agrupar por semanas del mes
        labels = ['Semana 1', 'Semana 2', 'Semana 3', 'Semana 4'];
        var ingresosMap = _agruparTransaccionesPorPeriodo(
          filteredTransactions.where((t) => t.tipo == 'ingreso').toList(),
          'mes',
        );
        var egresosMap = _agruparTransaccionesPorPeriodo(
          filteredTransactions.where((t) => t.tipo == 'gasto').toList(),
          'mes',
        );

        for (final semana in labels) {
          ingresos.add(ingresosMap[semana] ?? 0);
          egresos.add(egresosMap[semana] ?? 0);
        }
        break;

      case 'año':
        // Agrupar por meses
        labels = [
          'Ene',
          'Feb',
          'Mar',
          'Abr',
          'May',
          'Jun',
          'Jul',
          'Ago',
          'Sep',
          'Oct',
          'Nov',
          'Dic',
        ];
        var ingresosMap = _agruparTransaccionesPorPeriodo(
          filteredTransactions.where((t) => t.tipo == 'ingreso').toList(),
          'año',
        );
        var egresosMap = _agruparTransaccionesPorPeriodo(
          filteredTransactions.where((t) => t.tipo == 'gasto').toList(),
          'año',
        );

        for (final mes in labels) {
          ingresos.add(ingresosMap[mes] ?? 0);
          egresos.add(egresosMap[mes] ?? 0);
        }
        break;
    }

    // Crear grupos de barras
    final barGroups = List.generate(labels.length, (i) {
      return BarChartGroupData(
        x: i,
        barsSpace: 6,
        barRods: [
          BarChartRodData(
            toY: ingresos[i],
            width: 18,
            color: Colors.green,
            borderRadius: BorderRadius.zero,
          ),
          BarChartRodData(
            toY: egresos[i],
            width: 18,
            color: Colors.red,
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

  Map<String, double> _agruparTransaccionesPorPeriodo(
    List<Transaccion> trans,
    String periodo,
  ) {
    Map<String, double> resultado = {};

    for (var t in trans) {
      String key;
      switch (periodo) {
        case 'día':
          // Agrupar por período del día
          int hora = t.fecha.hour;
          if (hora >= 6 && hora < 12){
            key = 'Mañana';
          }
          else if (hora >= 12 && hora < 18){
            key = 'Tarde';
          }
          else{
            key = 'Noche';
          }
          break;

        case 'semana':
          // Agrupar por día de la semana
          final dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
          key = dias[t.fecha.weekday - 1];
          break;

        case 'mes':
          // Agrupar por semana del mes
          int semana = ((t.fecha.day - 1) / 7).floor() + 1;
          key = 'Semana $semana';
          break;

        case 'año':
          // Agrupar por mes
          final meses = [
            'Ene',
            'Feb',
            'Mar',
            'Abr',
            'May',
            'Jun',
            'Jul',
            'Ago',
            'Sep',
            'Oct',
            'Nov',
            'Dic',
          ];
          key = meses[t.fecha.month - 1];
          break;

        default:
          key = 'Otros';
      }

      resultado[key] = (resultado[key] ?? 0) + t.monto;
    }

    return resultado;
  }

  Widget transactionItem(String title, String date, double amount) {
    final bool isPositive = amount > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          splashColor: Colors.teal.withAlpha(51), // 0.2 * 255 ≈ 51
          onTap: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Transacción: $title')));
          },
          child: Ink(
            decoration: BoxDecoration(
              color: isPositive ? Colors.teal[50] : Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withAlpha(13), // 0.05 * 255 ≈ 13
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
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
