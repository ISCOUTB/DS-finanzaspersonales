import 'package:flutter/material.dart';
import '../graficos/graf_pastel.dart'; // Importa el gráfico pastel
import '../Servicios/gestor_finanzas.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final List<String> filters = ['Día', 'Semana', 'Mes', 'Año'];
  int selectedFilter = 2; // Por defecto, "Mes"
  final GestorFinanzas _gestorFinanzas = GestorFinanzas();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(225, 47, 125, 121),
        title: const Text(
          'Estadísticas',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color.fromARGB(225, 47, 125, 121),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filters.asMap().entries.map((entry) {
                  final index = entry.key;
                  final filter = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        filter,
                        style: TextStyle(
                          color: selectedFilter == index
                              ? const Color.fromARGB(225, 47, 125, 121)
                              : Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      selected: selectedFilter == index,
                      selectedColor: Colors.white,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      onSelected: (bool selected) {
                        if (selected) {
                          setState(() {
                            selectedFilter = index;
                          });
                        }
                      },
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Gráficos pastel
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Gráfico de ingresos
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ingresos por Categoría',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            CategoryPieChart(
                              selectedFilter: selectedFilter,
                              tipo: 'ingreso', // Especifica que es para ingresos
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Gráfico de egresos
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Gastos por Categoría',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            CategoryPieChart(
                              selectedFilter: selectedFilter,
                              tipo: 'gasto', // Especifica que es para egresos
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}