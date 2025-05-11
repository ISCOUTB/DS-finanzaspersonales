import 'package:flutter/material.dart';
import '../graficos/graficos.dart';

class Statistics extends StatefulWidget {
  const Statistics({Key? key}) : super(key: key);

  @override
  State<Statistics> createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<String> filters = ['Día', 'Semana', 'Mes', 'Año'];
  int selectedFilter = 2;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // Header con título y filtros
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color.fromARGB(225, 47, 125, 121),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Estadísticas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Filtros mejorados
                  SingleChildScrollView(
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
                ],
              ),
            ),
            // TabBar mejorado
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: const Color.fromARGB(225, 47, 125, 121),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color.fromARGB(225, 47, 125, 121),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.pie_chart),
                    text: 'Distribución',
                  ),
                  Tab(
                    icon: Icon(Icons.bar_chart),
                    text: 'Comparativa',
                  ),
                ],
              ),
            ),
            // Contenido de las pestañas
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Vista del gráfico circular
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        height: 400, // Altura fija para el gráfico
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Placeholder(), // Replace with your actual PieChartSample widget implementation or import
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Vista del gráfico de barras
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        height: 400, // Altura fija para el gráfico
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: IncomeExpenses(filterIndex: selectedFilter),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}