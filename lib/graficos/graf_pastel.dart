import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../Servicios/gestor_finanzas.dart';
import '../Modelos/transaccion.dart';

class Statistics extends StatefulWidget {
  const Statistics({super.key});

  @override
  State<Statistics> createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  final List<String> filters = ['Día', 'Semana', 'Mes', 'Año'];
  int selectedFilter = 2; // Default to 'Mes'
  int? touchedIndex;
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
              shadowColor: Colors.black.withAlpha(38), // 0.15 * 255 ≈ 38
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
              shadowColor: Colors.black.withAlpha(38), // 0.15 * 255 ≈ 38
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
            ...transacciones.map((t) => buildTransactionItem(t)),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> getChartData(String filtro) {
    List<Transaccion> filteredTransactions = _gestorFinanzas.obtenerTransaccionesFiltradas(filtro.toLowerCase());
    
    double ingresos = filteredTransactions
        .where((t) => t.tipo == 'ingreso')
        .fold(0.0, (sum, t) => sum + t.monto);
    
    double egresos = filteredTransactions
        .where((t) => t.tipo == 'gasto')
        .fold(0.0, (sum, t) => sum + t.monto);

    final total = ingresos + egresos;
    final porcIngreso = total > 0 ? ((ingresos / total) * 100).toStringAsFixed(1) : "0.0";
    final porcEgreso = total > 0 ? ((egresos / total) * 100).toStringAsFixed(1) : "0.0";

    // Calcular gastos por categoría
    Map<String, double> gastosPorCategoria = {};
    for (var t in filteredTransactions.where((t) => t.tipo == 'gasto')) {
      gastosPorCategoria[t.categoria.nombre] = 
          (gastosPorCategoria[t.categoria.nombre] ?? 0) + t.monto;
    }

    return {
      "ingresos": ingresos,
      "egresos": egresos,
      "porcIngreso": porcIngreso,
      "porcEgreso": porcEgreso,
      "totalEgresos": egresos,
      "categorias": gastosPorCategoria,
    };
  }

  List<PieChartSectionData> showingIncomesAndExpenses(Map<String, dynamic> data) {
    final ingresos = data["ingresos"] as double;
    final egresos = data["egresos"] as double;
    final total = ingresos + egresos;

    if (total == 0) {
      return [
        PieChartSectionData(
          color: Colors.grey,
          value: 1,
          title: "Sin datos",
          radius: 80,
          titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        )
      ];
    }

    return [
      if (ingresos > 0)
        PieChartSectionData(
          color: Colors.green,
          value: ingresos,
          title: "\$${ingresos.toStringAsFixed(2)}",
          radius: 80,
          titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      if (egresos > 0)
        PieChartSectionData(
          color: Colors.red,
          value: egresos,
          title: "\$${egresos.toStringAsFixed(2)}",
          radius: 80,
          titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
    ];
  }

  List<PieChartSectionData> showingExpenseCategories(Map<String, dynamic> data) {
    Map<String, double> categorias = data["categorias"] as Map<String, double>;
    
    if (categorias.isEmpty) {
      return [
        PieChartSectionData(
          color: Colors.grey,
          value: 1,
          title: "Sin gastos",
          radius: 75,
          titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        )
      ];
    }

    // Colores para las diferentes categorías
    final List<Color> categoryColors = [
      Colors.red[400]!,
      Colors.red[500]!,
      Colors.red[600]!,
      Colors.red[700]!,
      Colors.red[800]!,
    ];

    return List.generate(categorias.length, (i) {
      final entry = categorias.entries.elementAt(i);
      final String category = entry.key;
      final double value = entry.value;
      final Color color = categoryColors[i % categoryColors.length];

      return PieChartSectionData(
        color: color,
        value: value,
        title: "\$${value.toStringAsFixed(0)}",
        radius: 75,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        badgeWidget: _buildCategoryBadge(category, value),
      );
    });
  }

  Widget _buildCategoryBadge(String label, double value) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(179), // 0.7 * 255 ≈ 179
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '$label: \$${value.toStringAsFixed(2)}',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget buildTransactionItem(Transaccion t) {
    bool isPositive = t.tipo == 'ingreso';
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Transacción: ${t.descripcion}')));
          },
          borderRadius: BorderRadius.circular(15),
          child: Ink(
            decoration: BoxDecoration(
              color: isPositive ? Colors.teal[50] : Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withAlpha(51),
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
                      Text(t.descripcion ?? 'Sin descripción',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        '${t.fecha.day}/${t.fecha.month}/${t.fecha.year}',
                        style: const TextStyle(color: Colors.grey)
                      ),
                    ],
                  ),
                ),
                Text(
                  '${isPositive ? '+' : '-'} \$${t.monto.toStringAsFixed(2)}',
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