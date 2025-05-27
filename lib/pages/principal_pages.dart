import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'form_ingresos.dart';
import 'form_gastos.dart';
import '../Modelos/transaccion.dart';
import '../Servicios/gestor_finanzas.dart';
import 'transfer_history.dart';

class PrincipalPage extends StatefulWidget {
  static final GlobalKey<PrincipalPageState> globalKey = GlobalKey<PrincipalPageState>();

  const PrincipalPage({super.key});

  @override
  State<PrincipalPage> createState() => PrincipalPageState();
}

class PrincipalPageState extends State<PrincipalPage> with WidgetsBindingObserver {
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
    // Escuchar cambios en transacciones
    transaccionesActualizadas.addListener(_onTransaccionesActualizadas);
  }

  void _onTransaccionesActualizadas() {
    cargarTransacciones();
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
    transaccionesActualizadas.removeListener(_onTransaccionesActualizadas);
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
          includeTransaction = transaccion.fecha.year == now.year &&
              transaccion.fecha.month == now.month &&
              transaccion.fecha.day == now.day;
          break;
        case 'semana':
          // Corregido: semana actual de lunes a domingo
          DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
          includeTransaction = !transaccion.fecha.isBefore(startOfWeek) && !transaccion.fecha.isAfter(endOfWeek);
          break;
        case 'mes':
          includeTransaction = transaccion.fecha.year == now.year &&
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

    // Colores minimalistas
    const ingresoColor = Color(0xFF43A047); // Verde más sobrio
    const gastoColor = Color(0xFFE53935); // Rojo más sobrio

    return PieChartData(
      sectionsSpace: 0, // Sin separación
      centerSpaceRadius: 70, // Más espacio central
      startDegreeOffset: -90,
      sections: [
        PieChartSectionData(
          color: ingresoColor,
          value: ingresos,
          title: total == 0 ? '' : '${(ingresos / total * 100).toStringAsFixed(1)}%',
          radius: 65,
          titleStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
          badgeWidget: null, // Sin badge para minimalismo
        ),
        PieChartSectionData(
          color: gastoColor,
          value: gastos,
          title: total == 0 ? '' : '${(gastos / total * 100).toStringAsFixed(1)}%',
          radius: 65,
          titleStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
          badgeWidget: null, // Sin badge para minimalismo
        ),
      ],
      borderData: FlBorderData(show: false),
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
                  Navigator.pop(context);
                  final result = await navContext.push(
                    MaterialPageRoute(builder: (context) => const FormGastos()),
                  );
                  if (result == true && mounted) {
                    await cargarTransacciones();
                    transaccionesActualizadas.value = !transaccionesActualizadas.value;
                    ScaffoldMessenger.of(navContext.context).showSnackBar(
                      const SnackBar(content: Text('Gasto agregado correctamente')),
                    );
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
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
                  Navigator.pop(context);
                  final result = await navContext.push(
                    MaterialPageRoute(builder: (context) => const FormIngresos()),
                  );
                  if (result == true && mounted) {
                    await cargarTransacciones();
                    transaccionesActualizadas.value = !transaccionesActualizadas.value;
                    ScaffoldMessenger.of(navContext.context).showSnackBar(
                      const SnackBar(content: Text('Ingreso agregado correctamente')),
                    );
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
    const fondoCard = Color.fromARGB(225, 47, 125, 121); // Color original de la tarjeta
    const fondoBalance = Color(0xFFF8F6FF);
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
                  color: fondoCard, // Verde principal
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.22), // Más oscura
                      blurRadius: 38,
                      spreadRadius: 6,
                      offset: const Offset(0, 28), // Más desplazada
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.65), // Borde blanco sutil
                    width: 1.4,
                  ),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF368983), Color(0xFF4CAF50)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Círculo decorativo grande
                    Positioned(
                      left: -60,
                      top: 30,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    // Eliminado: círculo decorativo pequeño (sombra rara)
                    // Positioned(
                    //   right: -30,
                    //   bottom: -20,
                    //   child: Container(
                    //     width: 70,
                    //     height: 70,
                    //     decoration: BoxDecoration(
                    //       color: Colors.black.withOpacity(0.10),
                    //       shape: BoxShape.circle,
                    //     ),
                    //   ),
                    // ),
                    // Chip de tarjeta en vez de wifi
                    Positioned(
                      right: 24,
                      top: 18,
                      child: CardChip(),
                    ),
                    // Número de tarjeta y logo ficticio
                    Positioned(
                      left: 24,
                      top: 18,
                      child: Row(
                        children: [
                          // Eliminado: Texto '•••• 1237' y chip 'FINANZAS'
                        ],
                      ),
                    ),
                    // Contenido principal
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Spacer(),
                          Text(
                            'Total Balance',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            balance['balance'] != null && (balance['ingresos'] != 0 || balance['gastos'] != 0)
                                ? balance['balance']!.toStringAsFixed(2)
                                : '0.00',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.arrow_upward, color: colorIngresos, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                '+${balance['ingresos']?.toStringAsFixed(2) ?? '0.00'}',
                                style: TextStyle(
                                  color: colorIngresos,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(width: 18),
                              Icon(Icons.arrow_downward, color: colorGastos, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                '-${balance['gastos']?.toStringAsFixed(2) ?? '0.00'}',
                                style: TextStyle(
                                  color: colorGastos,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
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
            Transform.translate(
              offset: const Offset(0, -110),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['día', 'semana', 'mes', 'año'].map((filter) {
                      bool isSelected = _selectedFilter == filter;
                      return InkWell(
                        borderRadius: BorderRadius.circular(22),
                        onTap: () => setState(() => _selectedFilter = filter),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [Color(0xFF368983), Color(0xFF4CAF50)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: isSelected ? null : Colors.transparent,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF368983).withOpacity(0.18),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [],
                            border: isSelected
                                ? null
                                : Border.all(color: const Color(0xFF368983).withOpacity(0.13), width: 1.2),
                          ),
                          child: Text(
                            filter.toUpperCase(),
                            style: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF368983),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -90),
              child: Container(
                height: 400, // Aumenta la altura
                width: MediaQuery.of(context).size.width * 0.99, // Más ancho
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(36), // Más redondeado
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(
                    color: fondoCard.withOpacity(0.10),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 36),
                    SizedBox(
                      height: 180, // Más grande el gráfico
                      child: PieChart(
                        generatePieChartData(),
                        swapAnimationDuration: const Duration(milliseconds: 900),
                        swapAnimationCurve: Curves.easeInOutCubic,
                      ),
                    ),
                    const SizedBox(height: 44),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: colorIngresos.withOpacity(0.13),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.arrow_upward, color: colorIngresos, size: 22),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    '+${balance['ingresos']?.toStringAsFixed(2) ?? '0.00'}',
                                    style: TextStyle(
                                      color: colorIngresos,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: colorGastos.withOpacity(0.13),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.arrow_downward, color: colorGastos, size: 22),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    '-${balance['gastos']?.toStringAsFixed(2) ?? '0.00'}',
                                    style: TextStyle(
                                      color: colorGastos,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
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
}

// Widget para el chip de tarjeta tipo EMV
class CardChip extends StatelessWidget {
  const CardChip({super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      height: 28,
      child: CustomPaint(
        painter: _CardChipPainter(),
      ),
    );
  }
}

class _CardChipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = 7.0;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final chipPaint = Paint()
      ..color = const Color(0xFFE0DFDB)
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = Colors.black.withOpacity(0.38)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    // Dibuja el rectángulo principal del chip
    final chipRRect = RRect.fromRectAndRadius(rect, Radius.circular(r));
    canvas.drawRRect(chipRRect, chipPaint);
    canvas.drawRRect(chipRRect, borderPaint);
    // Líneas internas (similares a la imagen)
    final linePaint = Paint()
      ..color = Colors.black.withOpacity(0.45)
      ..strokeWidth = 1.0;
    // Líneas horizontales
    canvas.drawLine(Offset(size.width * 0.0, size.height * 0.33), Offset(size.width, size.height * 0.33), linePaint);
    canvas.drawLine(Offset(size.width * 0.0, size.height * 0.66), Offset(size.width, size.height * 0.66), linePaint);
    // Líneas verticales
    canvas.drawLine(Offset(size.width * 0.33, 0), Offset(size.width * 0.33, size.height), linePaint);
    canvas.drawLine(Offset(size.width * 0.66, 0), Offset(size.width * 0.66, size.height), linePaint);
    // Líneas diagonales y detalles
    canvas.drawLine(Offset(0, size.height * 0.33), Offset(size.width * 0.33, 0), linePaint);
    canvas.drawLine(Offset(size.width * 0.33, 0), Offset(size.width * 0.66, size.height * 0.33), linePaint);
    canvas.drawLine(Offset(size.width * 0.66, size.height * 0.33), Offset(size.width, 0), linePaint);
    canvas.drawLine(Offset(size.width * 0.33, size.height), Offset(size.width * 0.0, size.height * 0.66), linePaint);
    canvas.drawLine(Offset(size.width * 0.33, size.height), Offset(size.width * 0.66, size.height * 0.66), linePaint);
    canvas.drawLine(Offset(size.width * 0.66, size.height), Offset(size.width, size.height * 0.66), linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
