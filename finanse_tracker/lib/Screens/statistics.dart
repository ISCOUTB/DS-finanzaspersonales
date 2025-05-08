import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Statistics extends StatefulWidget {
  const Statistics({Key? key}) : super(key: key);

  @override
  State<Statistics> createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  List<String> filters = ['Day', 'Week', 'Month', 'Year'];
  int selectedFilter = 2; // Default to 'Month'
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    String filtro = filters[selectedFilter];
    final data = getChartData(filtro);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas - Gráfico Circular'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Distribución de Ingresos y Egresos',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              children: List.generate(filters.length, (index) {
                final bool isSelected = selectedFilter == index;
                return ChoiceChip(
                  label: Text(filters[index]),
                  selected: isSelected,
                  selectedColor: Colors.teal,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.teal[800],
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) {
                    setState(() {
                      selectedFilter = index;
                      touchedIndex = -1;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 30),

            // Primer gráfico: Ingresos y Egresos
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 10,
              shadowColor: Colors.black.withOpacity(0.15),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 200, // Tamaño ajustado
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sections: showingIncomesAndExpenses(data),
                              pieTouchData: PieTouchData(
                                touchCallback: (event, response) {
                                  setState(() {
                                    touchedIndex = response?.touchedSection?.touchedSectionIndex;
                                  });
                                },
                              ),
                              sectionsSpace: 8, // Espacio entre secciones
                              centerSpaceRadius: 70, // Mayor espacio central
                              startDegreeOffset: -90,
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(fontSize: 14, color: Colors.black54),
                              ),
                              Text(
                                '\$${(data["ingresos"] + data["egresos"]).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Indicator(color: Colors.green, text: "Ingresos (${data["porcIngreso"]}%)"),
                        const SizedBox(width: 24),
                        Indicator(color: Colors.red, text: "Egresos (${data["porcEgreso"]}%)"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Segundo gráfico: Categorías de Egresos
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 10,
              shadowColor: Colors.black.withOpacity(0.15),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 250, // Aumento el tamaño para mejor visualización
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sections: showingExpenseCategories(data),
                              pieTouchData: PieTouchData(
                                touchCallback: (event, response) {
                                  setState(() {
                                    touchedIndex = response?.touchedSection?.touchedSectionIndex;
                                  });
                                },
                              ),
                              sectionsSpace: 10, // Espaciado ajustado
                              centerSpaceRadius: 80, // Aumento el espacio central
                              startDegreeOffset: -90,
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Total Gastos',
                                style: TextStyle(fontSize: 14, color: Colors.black54),
                              ),
                              Text(
                                '\$${(data["totalEgresos"]).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Historial de transacciones',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            buildTransactionItem('Salario', '01 Mar 2025', 1200),
            buildTransactionItem('Alquiler', '02 Mar 2025', -400),
            buildTransactionItem('Uber', '03 Mar 2025', -30),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> getChartData(String filtro) {
    double ingresos = 0;
    double egresos = 0;

    switch (filtro) {
      case 'Day':
        ingresos = 200;
        egresos = 100;
        break;
      case 'Week':
        ingresos = 600;
        egresos = 300;
        break;
      case 'Month':
        ingresos = 1500;
        egresos = 900;
        break;
      case 'Year':
        ingresos = 12000;
        egresos = 8500;
        break;
    }

    final total = ingresos + egresos;
    final porcIngreso = ((ingresos / total) * 100).toStringAsFixed(1);
    final porcEgreso = ((egresos / total) * 100).toStringAsFixed(1);

    return {
      "ingresos": ingresos,
      "egresos": egresos,
      "porcIngreso": porcIngreso,
      "porcEgreso": porcEgreso,
      "totalEgresos": egresos,
    };
  }

  List<PieChartSectionData> showingIncomesAndExpenses(Map<String, dynamic> data) {
    final ingresos = data["ingresos"];
    final egresos = data["egresos"];

    return [
      PieChartSectionData(
        color: Colors.green,
        value: ingresos,
        title: "\$${ingresos.toInt()}",
        radius: 80, // Ajuste del tamaño
        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: Colors.red,
        value: egresos,
        title: "\$${egresos.toInt()}",
        radius: 80, // Ajuste del tamaño
        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ];
  }

  List<PieChartSectionData> showingExpenseCategories(Map<String, dynamic> data) {
    List<String> categories = ["Alquiler", "Comida", "Transporte", "Ocio", "Otros"];
    List<double> categoryEgresos = [400, 250, 120, 80, 90];

    return List.generate(5, (i) {
      final double value = categoryEgresos[i];
      final Color color = Colors.red;
      final String title = "\$${value.toInt()}";

      return PieChartSectionData(
        color: color,
        value: value,
        title: title,
        radius: 75, // Ajuste de tamaño de las categorías
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        badgePositionPercentageOffset: 0.1,
        badgeWidget: _buildCategoryBadge(categories[i], value),
      );
    });
  }

  Widget _buildCategoryBadge(String label, double value) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '$label: \$${value.toStringAsFixed(2)}',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget buildTransactionItem(String title, String date, double amount) {
    bool isPositive = amount > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Transacción: $title')));
          },
          borderRadius: BorderRadius.circular(15),
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
                      Text(title,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
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

class Indicator extends StatelessWidget {
  final Color color;
  final String text;

  const Indicator({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 6, backgroundColor: color),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 14, color: Colors.black87)),
      ],
    );
  }
}
