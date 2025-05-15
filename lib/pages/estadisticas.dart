import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../Modelos/categoria.dart';
import '../Modelos/transaccion.dart';
import '../Servicios/gestor_finanzas.dart';

enum FiltroTiempo { dia, semana, mes, anio }

class EstadisticasPage extends StatefulWidget {
  static final GlobalKey<EstadisticasPageState> globalKey = GlobalKey<EstadisticasPageState>();

  const EstadisticasPage({super.key});

  @override
  EstadisticasPageState createState() => EstadisticasPageState();
}

class EstadisticasPageState extends State<EstadisticasPage>
    with SingleTickerProviderStateMixin {       
  final GestorFinanzas _gestor = GestorFinanzas();
  int _anioSeleccionado = DateTime.now().year;
  List<Transaccion> _transacciones = [];

  FiltroTiempo _filtroSeleccionado = FiltroTiempo.mes;

  late TabController _tabController;

  List<String> _etiquetasBarras = [];
  List<double> _totalesIngresos = [];
  List<double> _totalesEgresos = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    await _gestor.cargarTransacciones();
    setState(() {
      _transacciones = _gestor.transacciones;
    });
  }

  List<Transaccion> _filtrarTransacciones(FiltroTiempo filtro) {
    final now = DateTime.now();
    switch (filtro) {
      case FiltroTiempo.dia:
        return _transacciones.where((t) =>
            t.fecha.year == now.year &&
            t.fecha.month == now.month &&
            t.fecha.day == now.day).toList();
      case FiltroTiempo.semana:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return _transacciones.where((t) =>
            !t.fecha.isBefore(startOfWeek) && !t.fecha.isAfter(endOfWeek)).toList();
      case FiltroTiempo.mes:
        return _transacciones.where((t) =>
            t.fecha.year == now.year).toList(); // <- Filtramos solo por año para sumar meses
      case FiltroTiempo.anio:
        return _transacciones.where((t) => t.fecha.year == now.year).toList();
    }
  }

  Map<String, double> _calcularDesglosePorCategoria(List<Transaccion> lista, String tipo) {
    final filtrada = lista.where((t) => t.tipo == tipo).toList();
    Map<String, double> map = {};
    for (var t in filtrada) {
      map[t.categoria.nombre] = (map[t.categoria.nombre] ?? 0) + t.monto;
    }
    return map;
  }

  // Método actualizado para calcular barras con 12 meses en filtro mes
  void _calcularTotalesBarras(List<Transaccion> lista) {
    _etiquetasBarras = [];
    _totalesIngresos = [];
    _totalesEgresos = [];

    final now = DateTime.now();

    switch (_filtroSeleccionado) {
      case FiltroTiempo.dia:
        _etiquetasBarras = ['Hoy'];
        double ingresosDia = 0;
        double egresosDia = 0;
        for (var t in lista) {
          if (t.tipo == 'ingreso') ingresosDia += t.monto;
          if (t.tipo == 'egreso') egresosDia += t.monto;
        }
        _totalesIngresos = [ingresosDia];
        _totalesEgresos = [egresosDia];
        break;

      case FiltroTiempo.semana:
        _etiquetasBarras = ['L', 'Ma', 'Mi', 'J', 'V', 'S', 'D'];
        List<double> ingresos = List.filled(7, 0);
        List<double> egresos = List.filled(7, 0);

        for (var t in lista) {
          int dayIndex = t.fecha.weekday - 1;
          if (t.tipo == 'ingreso') ingresos[dayIndex] += t.monto;
          if (t.tipo == 'egreso') egresos[dayIndex] += t.monto;
        }
        _totalesIngresos = ingresos;
        _totalesEgresos = egresos;
        break;

      case FiltroTiempo.mes:
        // Aquí 12 meses con sumas por mes (solo año actual)
        _etiquetasBarras = const [
          'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
          'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
        ];
        List<double> ingresos = List.filled(12, 0);
        List<double> egresos = List.filled(12, 0);

        for (var t in lista) {
          if (t.fecha.year == now.year) {
            int monthIndex = t.fecha.month - 1;
            if (t.tipo == 'ingreso') ingresos[monthIndex] += t.monto;
            if (t.tipo == 'egreso') egresos[monthIndex] += t.monto;
          }
        }
        _totalesIngresos = ingresos;
        _totalesEgresos = egresos;
        break;

      case FiltroTiempo.anio:
        int currentYear = now.year;
        _etiquetasBarras =
            List.generate(5, (i) => (currentYear - (4 - i)).toString());
        List<double> ingresos = List.filled(5, 0);
        List<double> egresos = List.filled(5, 0);
        for (var t in lista) {
          int index = currentYear - t.fecha.year;
          if (index >= 0 && index < 5) {
            int pos = 4 - index;
            if (t.tipo == 'ingreso') ingresos[pos] += t.monto;
            if (t.tipo == 'egreso') egresos[pos] += t.monto;
          }
        }
        _totalesIngresos = ingresos;
        _totalesEgresos = egresos;
        break;
    }
  }

  List<Color> colores = [
    Colors.blue.shade400,
    Colors.green.shade400,
    Colors.orange.shade400,
    Colors.purple.shade400,
    Colors.red.shade400,
    Colors.yellow.shade400,
    Colors.cyan.shade400,
    Colors.teal.shade400,
    Colors.pink.shade400,
    Colors.brown.shade400,
  ];

  List<PieChartSectionData> _generarSeccionesPie(Map<String, double> data) {
    final total = data.values.fold(0.0, (a, b) => a + b);
    if (total == 0) return [];

    int i = 0;
    return data.entries.map((entry) {
      final porcentaje = (entry.value / total) * 100;
      final color = colores[i % colores.length];
      i++;
      return PieChartSectionData(
        value: entry.value,
        title: '${porcentaje.toStringAsFixed(1)}%',
        color: color,
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<BarChartGroupData> _generarBarrasAgrupadas() {
    List<BarChartGroupData> barras = [];
    for (int i = 0; i < _etiquetasBarras.length; i++) {
      barras.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: _totalesIngresos[i],
              color: Colors.green.shade600,
              width: 10,
            ),
            BarChartRodData(
              toY: _totalesEgresos[i],
              color: Colors.red.shade600,
              width: 10,
            ),
          ],
          barsSpace: 6,
        ),
      );
    }
    return barras;
  }

  Widget _buildLegend(Map<String, double> data) {
    final total = data.values.fold(0.0, (a, b) => a + b);
    if (total == 0) return const Center(child: Text('No hay datos para mostrar.'));

    int i = 0;
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: data.entries.map((entry) {
        final color = colores[i % colores.length];
        i++;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 16, height: 16, color: color),
            const SizedBox(width: 6),
            Text('${entry.key}: \$${entry.value.toStringAsFixed(2)}'),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtradas = _filtrarTransacciones(_filtroSeleccionado);
    final ingresosPorCategoria = _calcularDesglosePorCategoria(filtradas, 'ingreso');
    final egresosPorCategoria = _calcularDesglosePorCategoria(filtradas, 'egreso');

    _calcularTotalesBarras(filtradas);

    final maxIngreso = _totalesIngresos.isNotEmpty
        ? _totalesIngresos.reduce((a, b) => a > b ? a : b)
        : 0.0;
    final maxEgreso = _totalesEgresos.isNotEmpty
        ? _totalesEgresos.reduce((a, b) => a > b ? a : b)
        : 0.0;
    final maxY = (maxIngreso > maxEgreso ? maxIngreso : maxEgreso) * 1.2;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xff368983),
          title: const Text('Estadísticas'),
          bottom: TabBar(
            tabs: const [
              Tab(icon: Icon(Icons.pie_chart), text: 'Pastel'),
              Tab(icon: Icon(Icons.bar_chart), text: 'Barras'),
            ],
          ),
          actions: [
            PopupMenuButton<FiltroTiempo>(
              initialValue: _filtroSeleccionado,
              tooltip: 'Filtrar por',
              icon: const Icon(Icons.filter_alt_outlined, color: Colors.white),
              onSelected: (FiltroTiempo seleccion) {
                setState(() {
                  _filtroSeleccionado = seleccion;
                });
              },
              itemBuilder: (context) => <PopupMenuEntry<FiltroTiempo>>[
                const PopupMenuItem(
                  value: FiltroTiempo.dia,
                  child: Text('Día'),
                ),
                const PopupMenuItem(
                  value: FiltroTiempo.semana,
                  child: Text('Semana'),
                ),
                const PopupMenuItem(
                  value: FiltroTiempo.mes,
                  child: Text('Mes'),
                ),
                const PopupMenuItem(
                  value: FiltroTiempo.anio,
                  child: Text('Año'),
                ),
              ],
            ),
          ],
        ),
        body: TabBarView(
          children: [
            // Gráfico de pastel + leyenda
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Ingresos por Categoría',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 220,
                    child: ingresosPorCategoria.isEmpty
                        ? const Center(child: Text('No hay ingresos registrados'))
                        : PieChart(
                            PieChartData(
                              sections: _generarSeccionesPie(ingresosPorCategoria),
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                            ),
                          ),
                  ),
                  const SizedBox(height: 8),
                  _buildLegend(ingresosPorCategoria),

                  const SizedBox(height: 32),

                  Text(
                    'Gastos por Categoría',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 220,
                    child: egresosPorCategoria.isEmpty
                        ? const Center(child: Text('No hay gastos registrados'))
                        : PieChart(
                            PieChartData(
                              sections: _generarSeccionesPie(egresosPorCategoria),
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                            ),
                          ),
                  ),
                  const SizedBox(height: 8),
                  _buildLegend(egresosPorCategoria),
                ],
              ),
            ),

            // Gráfico de barras agrupadas
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Ingresos y Gastos agrupados (${_filtroSeleccionado.name.toUpperCase()})',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  if (_filtroSeleccionado == FiltroTiempo.dia)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'No hay datos agrupados para filtro Día.\nUsa gráfico de pastel para detalles.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 320,
                      child: BarChart(
                        BarChartData(
                          maxY: maxY,
                          barGroups: _generarBarrasAgrupadas(),
                          groupsSpace: 18,
                          barTouchData: BarTouchData(enabled: true),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index < 0 || index >= _etiquetasBarras.length) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      _etiquetasBarras[index],
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(show: true),
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
