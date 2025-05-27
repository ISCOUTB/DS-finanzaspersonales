import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../Modelos/categoria.dart';
import '../Modelos/transaccion.dart';
import '../Servicios/gestor_finanzas.dart';
import 'transfer_history.dart';

enum FiltroTiempo { dia, semana, mes, anio }

class EstadisticasPage extends StatefulWidget {
  static final GlobalKey<EstadisticasPageState> globalKey =
      GlobalKey<EstadisticasPageState>();

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
    cargarDatos();
    // Escuchar cambios en transacciones para recargar automáticamente
    transaccionesActualizadas.addListener(_onTransaccionesActualizadas);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    cargarDatos(); // Recargar datos al navegar a la página
  }

  @override
  void dispose() {
    transaccionesActualizadas.removeListener(_onTransaccionesActualizadas);
    _tabController.dispose();
    super.dispose();
  }

  void _onTransaccionesActualizadas() {
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    await _gestor.cargarTransacciones();
    setState(() {
      _transacciones = _gestor.transacciones;
    });
  }

  List<Transaccion> _filtrarTransacciones(FiltroTiempo filtro) {
    final now = DateTime.now();
    switch (filtro) {
      case FiltroTiempo.dia:
        return _transacciones
            .where(
              (t) =>
                  t.fecha.year == now.year &&
                  t.fecha.month == now.month &&
                  t.fecha.day == now.day,
            )
            .toList();
      case FiltroTiempo.semana:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return _transacciones
            .where(
              (t) =>
                  !t.fecha.isBefore(startOfWeek) && !t.fecha.isAfter(endOfWeek),
            )
            .toList();
      case FiltroTiempo.mes:
        return _transacciones
            .where(
              (t) => t.fecha.year == now.year && t.fecha.month == now.month,
            )
            .toList();
      case FiltroTiempo.anio:
        return _transacciones.where((t) => t.fecha.year == now.year).toList();
    }
  }

  Map<String, double> _calcularDesglosePorCategoria(
    List<Transaccion> lista,
    String tipo,
  ) {
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
        _etiquetasBarras = List.generate(
          5,
          (i) => (currentYear - (4 - i)).toString(),
        );
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

  List<Color> coloresIngresos = [
    Colors.blue.shade400,
    Colors.green.shade400,
    Colors.orange.shade400,
    Colors.purple.shade400,
    Colors.yellow.shade400,
    Colors.indigo.shade400,
    Colors.lightGreen.shade400,
    Colors.amber.shade400,
    Colors.deepPurple.shade400,
    Colors.lime.shade400,
    Colors.blueGrey.shade400,
    Colors.cyan.shade300,
    Colors.teal.shade300,
    Colors.lightBlue.shade300,
    Colors.pink.shade200,
    Colors.greenAccent.shade400,
    Colors.orangeAccent.shade400,
    Colors.yellowAccent.shade400,
    Colors.indigoAccent.shade200,
    Colors.purpleAccent.shade200,
  ];

  List<Color> coloresGastos = [
    Colors.red.shade400,
    Colors.pink.shade400,
    Colors.brown.shade400,
    Colors.teal.shade400,
    Colors.cyan.shade400,
    Colors.deepOrange.shade400,
    Colors.grey.shade600,
    Colors.indigo.shade900,
    Colors.green.shade900,
    Colors.blue.shade900,
    Colors.purple.shade900,
    Colors.redAccent.shade700,
    Colors.deepPurple.shade900,
    Colors.blueGrey.shade800,
    Colors.brown.shade800,
    Colors.teal.shade800,
    Colors.cyan.shade800,
    Colors.deepOrangeAccent.shade700,
    Colors.grey.shade800,
    Colors.black54,
  ];

  List<PieChartSectionData> _generarSeccionesPie(
    Map<String, double> data,
    List<Color> colores,
  ) {
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

  Widget _buildLegend(Map<String, double> data, List<Color> colores) {
    final total = data.values.fold(0.0, (a, b) => a + b);
    if (total == 0) {
      return const Center(child: Text('No hay datos para mostrar.'));
    }

    int i = 0;
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children:
          data.entries.map((entry) {
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

  Widget _buildPieChartTotal(
    Map<String, double> data,
    String label,
    Color color,
    List<Color> colores, // Agrega este parámetro para los colores
  ) {
    final total = data.values.fold(0.0, (a, b) => a + b);
    if (total == 0) {
      return const Center(child: Text('No hay datos para mostrar.'));
    }
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      shadowColor: Colors.black.withOpacity(0.15),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SizedBox(
          height: 250,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sections: _generarSeccionesPie(
                    data,
                    colores,
                  ), // Pasa los colores aquí
                  sectionsSpace: 8,
                  centerSpaceRadius: 80,
                  startDegreeOffset: -90,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIndicators(
    Map<String, double> data,
    List<Color> colores,
  ) {
    final total = data.values.fold(0.0, (a, b) => a + b);
    if (total == 0) {
      return const SizedBox();
    }
    int i = 0;
    return Column(
      children:
          data.entries.map((entry) {
            final color = colores[i % colores.length];
            i++;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text(
                    '\$${entry.value.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  // Widget para mostrar el historial de transacciones mostrando SIEMPRE el monto individual
  Widget _buildHistorialTransacciones(List<Transaccion> transacciones) {
    if (transacciones.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text('No hay transacciones para mostrar.')),
      );
    }
    // Ordenar por fecha descendente
    final lista = List<Transaccion>.from(transacciones)
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 8, top: 18),
          child: Text(
            'Historial de transacciones',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        ...lista.map((t) {
          final esIngreso = t.tipo == 'ingreso';
          // Mostrar SIEMPRE el monto individual, con símbolo de peso y formato correcto
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
            decoration: BoxDecoration(
              color: esIngreso ? Color(0xFFD6ECEB) : Color(0xFFF8F6FF),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 6,
              ),
              title: Text(
                t.categoria.nombre,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                '${t.fecha.day}/${t.fecha.month}/${t.fecha.year}',
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              trailing: Text(
                (esIngreso ? '+ \$' : '- \$') + t.monto.toStringAsFixed(2),
                style: TextStyle(
                  color: esIngreso ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  // Helper para abreviar meses en español
  String _mesAbreviado(int mes) {
    const meses = [
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
    return meses[mes - 1];
  }

  double _calcularIntervaloY() {
    final maxIngreso =
        _totalesIngresos.isNotEmpty
            ? _totalesIngresos.reduce((a, b) => a > b ? a : b)
            : 0.0;
    final maxEgreso =
        _totalesEgresos.isNotEmpty
            ? _totalesEgresos.reduce((a, b) => a > b ? a : b)
            : 0.0;
    final maxY = (maxIngreso > maxEgreso ? maxIngreso : maxEgreso);

    if (maxY == 0) return 1; // Si no hay datos, usa un intervalo de 1
    return (maxY / 4).ceilToDouble(); // Divide el valor máximo en 4 intervalos
  }

  @override
  Widget build(BuildContext context) {
    final filtradas = _filtrarTransacciones(_filtroSeleccionado);
    final ingresosPorCategoria = _calcularDesglosePorCategoria(
      filtradas,
      'ingreso',
    );
    final egresosPorCategoria = _calcularDesglosePorCategoria(
      filtradas,
      'egreso',
    );

    _calcularTotalesBarras(filtradas);

    final maxIngreso =
        _totalesIngresos.isNotEmpty
            ? _totalesIngresos.reduce((a, b) => a > b ? a : b)
            : 0.0;
    final maxEgreso =
        _totalesEgresos.isNotEmpty
            ? _totalesEgresos.reduce((a, b) => a > b ? a : b)
            : 0.0;
    final maxY = (maxIngreso > maxEgreso ? maxIngreso : maxEgreso) * 1.2;

    return DefaultTabController(
      length: 3, // Cambia a 3 pestañas
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xff368983),
          title: const Text('Estadísticas'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.pie_chart), text: 'Pastel'),
              Tab(icon: Icon(Icons.bar_chart), text: 'Barras'),
              Tab(icon: Icon(Icons.show_chart), text: 'Líneas'),
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
                cargarDatos(); // Recargar datos al cambiar el filtro
              },
              itemBuilder:
                  (context) => <PopupMenuEntry<FiltroTiempo>>[
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
            // 1. Gráfico de pastel + leyenda
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Tarjeta de Ingresos por categoría
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 10,
                    shadowColor: Colors.black.withOpacity(0.15),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 250,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                PieChart(
                                  PieChartData(
                                    sections: _generarSeccionesPie(
                                      ingresosPorCategoria,
                                      coloresIngresos,
                                    ),
                                    sectionsSpace: 8,
                                    centerSpaceRadius: 80,
                                    startDegreeOffset: -90,
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Total Ingresos',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    Text(
                                      '\$${ingresosPorCategoria.values.fold(0.0, (a, b) => a + b).toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildCategoryIndicators(
                            ingresosPorCategoria,
                            coloresIngresos,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Tarjeta de Gastos por categoría
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 10,
                    shadowColor: Colors.black.withOpacity(0.15),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 250,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                PieChart(
                                  PieChartData(
                                    sections: _generarSeccionesPie(
                                      egresosPorCategoria,
                                      coloresGastos,
                                    ),
                                    sectionsSpace: 8,
                                    centerSpaceRadius: 80,
                                    startDegreeOffset: -90,
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Total Gastos',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    Text(
                                      '\$${egresosPorCategoria.values.fold(0.0, (a, b) => a + b).toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildCategoryIndicators(
                            egresosPorCategoria,
                            coloresGastos,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Detalle por categoría',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  _buildLegend(ingresosPorCategoria, coloresIngresos),
                  const SizedBox(height: 10),
                  _buildLegend(egresosPorCategoria, coloresGastos),
                ],
              ),
            ),

            // 2. Gráfico de barras agrupadas
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 18),
                  Center(
                    child: Text(
                      'Ingresos y Gastos agrupados (${_filtroSeleccionado.name.toUpperCase()})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 340,
                    child: BarChart(
                      BarChartData(
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              interval:
                                  _calcularIntervaloY(), // Calcula un intervalo adecuado
                              getTitlesWidget: (value, meta) {
                                if (value % 1 != 0)
                                  return const SizedBox.shrink(); // Muestra solo números enteros
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Text(
                                    value
                                        .toInt()
                                        .toString(), // Convierte el valor a entero
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 32,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 ||
                                    index >= _etiquetasBarras.length) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    _etiquetasBarras[index],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              },
                            ),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        barGroups: _generarBarrasAgrupadas(),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval:
                              _calcularIntervaloY(), // Usa el mismo intervalo para las líneas horizontales
                          getDrawingHorizontalLine:
                              (value) => FlLine(
                                color: Colors.grey.withOpacity(0.15),
                                strokeWidth: 1,
                              ),
                        ),
                      ),
                    ),
                  ),
                  // Historial de transacciones debajo del gráfico de barras
                  _buildHistorialTransacciones(_transacciones),
                ],
              ),
            ),

            // 3. Gráfico de líneas
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Nuevo: Título centrado y filtro tipo "pill"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Gráfico de Líneas',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Filtros tipo "pill"
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 320,
                    child: LineChart(_generarLineChartDataEstiloImagen()),
                  ),
                  buildResumenBarras(
                    etiquetas: _etiquetasBarras,
                    ingresos: _totalesIngresos,
                    egresos: _totalesEgresos,
                  ),
                  // Agregado: Historial de transacciones debajo del gráfico de líneas
                  _buildHistorialTransacciones(_transacciones),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Nuevo: Widget para filtro tipo "pill"
  Widget _buildFiltroPill(FiltroTiempo filtro, String label) {
    final bool selected = _filtroSeleccionado == filtro;
    return GestureDetector(
      onTap: () {
        setState(() {
          _filtroSeleccionado = filtro;
        });
        cargarDatos();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xff009688) : Colors.grey[200],
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // Nuevo: Gráfico de líneas con fondo degradado y solo una línea
  LineChartData _generarLineChartDataEstiloImagen() {
    List<FlSpot> spots = [];
    for (int i = 0; i < _etiquetasBarras.length; i++) {
      spots.add(FlSpot(i.toDouble(), _totalesIngresos[i]));
    }
    final maxIngreso =
        _totalesIngresos.isNotEmpty
            ? _totalesIngresos.reduce((a, b) => a > b ? a : b)
            : 0.0;
    final maxY = (maxIngreso) * 1.2;

    return LineChartData(
      minY: 0,
      maxY: maxY == 0 ? 100 : maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: const Color(0xff009688),
          barWidth: 3,
          dotData: FlDotData(
            show: true,
            getDotPainter:
                (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 5,
                  color: const Color(0xff009688),
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                const Color(0xff009688).withOpacity(0.25),
                Colors.white.withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 48,
            interval:
                (_etiquetasBarras.length == 1)
                    ? null
                    : (maxY ~/ 4 > 0 ? maxY / 4 : (maxY > 0 ? maxY / 4 : 1)),
            getTitlesWidget: (value, meta) {
              // Si solo hay un dato, muestra solo 0 y el valor máximo
              if (_etiquetasBarras.length == 1) {
                final maxValue = maxY == 0 ? 100 : maxY;
                if (value == 0 || value == maxValue) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      value.toInt().toString(),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  );
                }
                return const SizedBox.shrink();
              }
              // Para varios datos, solo muestra valores enteros y bien alineados
              if (value < 0 || value > maxY) return const SizedBox.shrink();
              if (value % 1 != 0) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.right,
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= _etiquetasBarras.length) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _etiquetasBarras[index],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
        ),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxY ~/ 4 > 0 ? maxY / 4 : 1,
        getDrawingHorizontalLine:
            (value) =>
                FlLine(color: Colors.grey.withOpacity(0.15), strokeWidth: 1),
      ),
    );
  }

  // NUEVO: Mejor visualización de los valores mostrados en el gráfico
  Widget buildResumenBarras({
    required List<String> etiquetas,
    required List<double> ingresos,
    required List<double> egresos,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Valores mostrados en el gráfico:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(etiquetas.length, (i) {
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.10),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        etiquetas[i],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xff009688),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.arrow_upward,
                            color: Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            ingresos[i].toStringAsFixed(0),
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.arrow_downward,
                            color: Colors.red,
                            size: 16,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            egresos[i].toStringAsFixed(0),
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAlgo() {
    return Column(
      children: [
        const Text('Hola mundo'),
        ElevatedButton(
          onPressed: () {
            // Acción del botón
          },
          child: const Text('Presióname'),
        ),
      ],
    );
  }
}
