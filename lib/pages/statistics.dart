import 'package:flutter/material.dart';
import '../graficos/graficos.dart';
import '../Servicios/gestor_finanzas.dart';
import '../Modelos/transaccion.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> filters = ['Día', 'Semana', 'Mes', 'Año'];
  int selectedFilter = 2; // Mes por defecto
  final GestorFinanzas _gestorFinanzas = GestorFinanzas();
  List<Transaccion> transacciones = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
                    'Análisis por Categorías',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
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
                            backgroundColor: Colors.white.withValues(alpha: 51),
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
            // TabBar
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
            // Contenido
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Vista del gráfico circular
                  CategoryPieChart(selectedFilter: selectedFilter),
                  // Vista del gráfico de barras
                  CategoryBarChart(selectedFilter: selectedFilter),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}