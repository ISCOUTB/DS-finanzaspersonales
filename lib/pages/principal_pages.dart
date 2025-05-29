import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'form_ingresos.dart';
import 'form_gastos.dart';
import '../Modelos/transaccion.dart';
import '../Servicios/gestor_finanzas.dart';

class PrincipalPage extends StatefulWidget {
  static final GlobalKey<PrincipalPageState> globalKey =
      GlobalKey<PrincipalPageState>();

  const PrincipalPage({super.key});

  @override
  State<PrincipalPage> createState() => PrincipalPageState();
}

class PrincipalPageState extends State<PrincipalPage>
    with WidgetsBindingObserver {
  String _selectedFilter = 'día';
  List<Transaccion> _transacciones = [];
  final _gestorFinanzas = GestorFinanzas();
  String _userName = 'Usuario';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    cargarTransacciones();
    loadUserName();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadUserName(); // Recargar el nombre cuando la dependencia cambie
  }

  Future<void> loadUserName() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'Usuario';
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      cargarTransacciones();
    }
  }

  Future<void> cargarTransacciones() async {
    await _gestorFinanzas.cargarTransacciones();
    if (!mounted) return;
    setState(() {
      _transacciones = _gestorFinanzas.transacciones;
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 0 && hour < 12) {
      return 'Buenos días';
    } else if (hour >= 12 && hour < 18) {
      return 'Buenas tardes';
    } else {
      return 'Buenas noches';
    }
  }

  Map<String, double> _calculateBalance() {
    double ingresos = 0;
    double gastos = 0;
    DateTime now = DateTime.now();

    for (var transaccion in _transacciones) {
      bool includeTransaction = false;

      switch (_selectedFilter) {
        case 'día':
          includeTransaction =
              transaccion.fecha.year == now.year &&
              transaccion.fecha.month == now.month &&
              transaccion.fecha.day == now.day;
          break;
        case 'semana':
          DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          includeTransaction =
              transaccion.fecha.isAfter(
                startOfWeek.subtract(const Duration(days: 1)),
              ) &&
              transaccion.fecha.isBefore(
                startOfWeek.add(const Duration(days: 7)),
              );
          break;
        case 'mes':
          includeTransaction =
              transaccion.fecha.year == now.year &&
              transaccion.fecha.month == now.month;
          break;
        case 'año':
          includeTransaction = transaccion.fecha.year == now.year;
          break;
      }

      if (includeTransaction) {
        if (transaccion.tipo == 'ingreso') {
          ingresos += transaccion.monto;
        } else {
          gastos += transaccion.monto;
        }
      }
    }

    return {
      'ingresos': ingresos,
      'gastos': gastos,
      'balance': ingresos - gastos,
    };
  }

  PieChartData generatePieChartData() {
    final balance = _calculateBalance();
    final ingresos = balance['ingresos'] ?? 0.0;
    final gastos = balance['gastos'] ?? 0.0;
    final total = ingresos + gastos;

    // Colores originales fijos
    const ingresoColor = Color(0xFF4CAF50);
    const gastoColor = Color(0xFFE57373);

    return PieChartData(
      sectionsSpace: 2,
      centerSpaceRadius: 60,
      startDegreeOffset: -90,
      sections: [
        PieChartSectionData(
          color: ingresoColor,
          value: ingresos,
          title:
              total == 0
                  ? ''
                  : '${(ingresos / total * 100).toStringAsFixed(1)}%',
          radius: 70,
          titleStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(1, 1),
              ),
            ],
          ),
          badgeWidget:
              total == 0
                  ? null
                  : _buildPieBadge(
                    icon: Icons.arrow_upward,
                    color: ingresoColor,
                    label: 'Ingresos',
                  ),
          badgePositionPercentageOffset: .92,
        ),
        PieChartSectionData(
          color: gastoColor,
          value: gastos,
          title:
              total == 0 ? '' : '${(gastos / total * 100).toStringAsFixed(1)}%',
          radius: 70,
          titleStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(1, 1),
              ),
            ],
          ),
          badgeWidget:
              total == 0
                  ? null
                  : _buildPieBadge(
                    icon: Icons.arrow_downward,
                    color: gastoColor,
                    label: 'Gastos',
                  ),
          badgePositionPercentageOffset: .92,
        ),
      ],
      borderData: FlBorderData(show: false),
    );
  }

  // Widget para los badges de ingresos/gastos en el gráfico
  Widget _buildPieBadge({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    // Corrige el error de contexto de widget: asegúrate de que este método esté dentro de la clase PrincipalPageState
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          backgroundColor: color.withValues(alpha: (255 * 0.15)),
          radius: 18,
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _showTransactionDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: 280,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(225, 47, 125, 121),
                  minimumSize: const Size(double.infinity, 70),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () async {
                  final navContext = Navigator.of(context);
                  final scaffoldMessenger = ScaffoldMessenger.of(
                    context,
                  ); // Guarda la referencia ANTES del await

                  Navigator.pop(context);
                  final result = await navContext.push(
                    MaterialPageRoute(builder: (context) => const FormGastos()),
                  );

                  if (result == true && mounted) {
                    await cargarTransacciones();
                    if (mounted) {
                      scaffoldMessenger.showSnackBar(
                        // Usa la referencia guardada
                        const SnackBar(
                          content: Text('Gasto agregado correctamente'),
                        ),
                      );
                    }
                  }
                },

                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.trending_down, color: Colors.red, size: 30),
                    SizedBox(width: 20),
                    Text(
                      'Gastos',
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(225, 47, 125, 121),
                  minimumSize: const Size(double.infinity, 70),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () async {
                  final navContext = Navigator.of(context);
                  final scaffoldMessenger = ScaffoldMessenger.of(
                    context,
                  ); // Guarda la referencia ANTES del await

                  Navigator.pop(context);
                  final result = await navContext.push(
                    MaterialPageRoute(
                      builder: (context) => const FormIngresos(),
                    ),
                  );

                  if (result == true && mounted) {
                    await cargarTransacciones();
                    if (mounted) {
                      scaffoldMessenger.showSnackBar(
                        // Usa la referencia guardada
                        const SnackBar(
                          content: Text('Ingreso agregado correctamente'),
                        ),
                      );
                    }
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    Icon(Icons.trending_up, color: Colors.green, size: 30),
                    SizedBox(width: 20),
                    Text(
                      'Ingresos',
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color.fromARGB(225, 47, 125, 121),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final balance = _calculateBalance();
    // Colores originales
    const fondoHeader = Color(0xff368983);
    const fondoCard = Color.fromARGB(
      225,
      47,
      125,
      121,
    ); // Color original de la tarjeta
    const fondoBalance = Color(0xFFF8F6FF);
    const colorTextoBalance = Color(
      0xff368983,
    ); // Color original del texto de balance
    const colorIngresos = Color(0xFF4CAF50); // Verde original
    const colorGastos = Color(0xFFE57373); // Rojo original

    return Scaffold(
      backgroundColor: fondoBalance,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 240,
              decoration: const BoxDecoration(
                color: fondoHeader,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 35, left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -130),
              child: Container(
                height: 170,
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  color: fondoCard,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Balance',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: const Icon(
                              Icons.arrow_downward,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 7),
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Row(
                        children: [
                          Text(
                            '${balance['balance']?.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildBalanceItem(
                            icon: Icons.arrow_upward,
                            title: 'Ingresos',
                            amount:
                                balance['ingresos']?.toStringAsFixed(2) ??
                                '0.00',
                            isIncome: true,
                            color: colorIngresos,
                          ),
                          _buildBalanceItem(
                            icon: Icons.arrow_downward,
                            title: 'Gastos',
                            amount:
                                balance['gastos']?.toStringAsFixed(2) ??
                                '-0.00',
                            isIncome: false,
                            color: colorGastos,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -110),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children:
                      ['día', 'semana', 'mes', 'año'].map((filter) {
                        bool isSelected = _selectedFilter == filter;
                        return GestureDetector(
                          onTap: () async {
                            setState(() {
                              _selectedFilter = filter;
                            });
                            await cargarTransacciones(); // <-- Esto recarga los datos cada vez que cambias el filtro
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected ? fondoCard : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              filter,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -90),
              child: Container(
                height: 390,
                width: MediaQuery.of(context).size.width * 0.99,
                margin: const EdgeInsets.only(bottom: 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: (20)),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(
                    color: fondoCard.withValues(alpha: (18)),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 120,
                      child: PieChart(
                        generatePieChartData(),
                        swapAnimationDuration: const Duration(
                          milliseconds: 900,
                        ),
                        swapAnimationCurve: Curves.easeInOutCubic,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.only(top: 0, bottom: 2),
                      child: Column(
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '', // Aquí puedes poner el valor real si lo deseas
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: colorTextoBalance,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 18,
                        left: 16,
                        right: 16,
                        bottom: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildLegendItem(
                            color: colorIngresos,
                            label: 'Ingresos',
                            icon: Icons.arrow_upward,
                          ),
                          _buildLegendItem(
                            color: colorGastos,
                            label: 'Gastos',
                            icon: Icons.arrow_downward,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Eliminar campo de búsqueda, filtro de fechas y lista filtrada de la principal
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: fondoCard,
        onPressed: _showTransactionDialog,
        tooltip: 'Agregar Transacción',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBalanceItem({
    required IconData icon,
    required String title,
    required String amount,
    required bool isIncome,
    required Color color,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 13,
          backgroundColor: color.withValues(alpha: (46)),
          child: Icon(icon, color: color, size: 19),
        ),
        const SizedBox(width: 7),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '\$ $amount',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 17,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Leyenda para el gráfico mejorada con flecha visible y mejor tipografía
  Widget _buildLegendItem({
    required Color color,
    required String label,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: color.withValues(alpha: (46)),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: (13)), width: 1),
          ),
          child: Center(child: Icon(icon, color: color, size: 18)),
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: color,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
