import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Añade esta línea al inicio
import '../Modelos/transaccion.dart';
import '../Servicios/gestor_finanzas.dart';

class PrincipalPage extends StatefulWidget {
  // Agregar una key global para acceder al estado
  static final GlobalKey<_PrincipalPageState> globalKey = GlobalKey<_PrincipalPageState>();
  
  PrincipalPage({Key? key}) : super(key: globalKey);

  @override
  State<PrincipalPage> createState() => _PrincipalPageState();
}

class _PrincipalPageState extends State<PrincipalPage> with WidgetsBindingObserver {
  String _selectedFilter = 'día';
  List<Transaccion> _transacciones = [];
  final _gestorFinanzas = GestorFinanzas();
  String _userName = ''; // Añade esta línea después de la declaración de la clase

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    cargarTransacciones();
    _loadUserName(); // Añade esta línea
  }

  Future<void> _loadUserName() async {
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
    if (mounted) {
      setState(() {
        _transacciones = _gestorFinanzas.transacciones;
      });
    }
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
          DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          includeTransaction = transaccion.fecha.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
              transaccion.fecha.isBefore(startOfWeek.add(const Duration(days: 7)));
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

  List<Transaccion> _getTransaccionesFiltradas() {
    DateTime now = DateTime.now();
    return _transacciones.where((transaccion) {
      switch (_selectedFilter) {
        case 'día':
          return transaccion.fecha.year == now.year &&
              transaccion.fecha.month == now.month &&
              transaccion.fecha.day == now.day;
        case 'semana':
          DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          return transaccion.fecha.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
              transaccion.fecha.isBefore(startOfWeek.add(const Duration(days: 7)));
        case 'mes':
          return transaccion.fecha.year == now.year &&
              transaccion.fecha.month == now.month;
        case 'año':
          return transaccion.fecha.year == now.year;
        default:
          return false;
      }
    }).toList();
  }

  PieChartData generatePieChartData() {
    final balance = _calculateBalance();
    final ingresos = balance['ingresos'] ?? 0.0;
    final gastos = balance['gastos'] ?? 0.0;
    final total = ingresos + gastos;

    return PieChartData(
      sectionsSpace: 0,
      centerSpaceRadius: 50,
      sections: [
        PieChartSectionData(
          color: const Color.fromARGB(255, 113, 180, 116), // Verde más suave
          value: ingresos,
          title: '${(ingresos / total * 100).toStringAsFixed(1)}%',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        PieChartSectionData(
          color: Color.fromARGB(255, 195, 105, 104), // Rojo más suave
          value: gastos,
          title: '${(gastos / total * 100).toStringAsFixed(1)}%',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final balance = _calculateBalance();
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color.fromARGB(0, 128, 171, 218),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header container con el fondo verde
            Container(
              width: double.infinity,
              height: 240,
              decoration: const BoxDecoration(
                color: Color(0xff368983),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Stack(
                children: [
                  // Saludo y nombre
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
                            color: Color.fromARGB(255, 224, 223, 223),
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

            // Tarjeta de balance superpuesta
            Transform.translate(
              offset: const Offset(0, -130),
              child: Container(
                height: 170,
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(225, 47, 125, 121),
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
                            onTap: () {
                              // Aquí puedes agregar la acción al tocar la flecha
                            },
                            child: const Icon(Icons.arrow_downward, color: Colors.white),
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
                            '\$ ${balance['balance']?.toStringAsFixed(2)}',
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
                            amount: balance['ingresos']?.toStringAsFixed(2) ?? '0.00',
                            isIncome: true,
                          ),
                          _buildBalanceItem(
                            icon: Icons.arrow_downward,
                            title: 'Gastos',
                            amount: balance['gastos']?.toStringAsFixed(2) ?? '-0.00',
                            isIncome: false,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Filtros
            Transform.translate(
              offset: const Offset(0, -110),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['día', 'semana', 'mes', 'año'].map((filter) {
                    bool isSelected = _selectedFilter == filter;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedFilter = filter),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xff368983) : Colors.transparent,
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

            // Gráfico de Pastel
            Transform.translate(
              offset: const Offset(0, -90),
              child: Container(
                height: 220,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                margin: const EdgeInsets.only(bottom: 60),
                child: PieChart(generatePieChartData()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceItem({
    required IconData icon,
    required String title,
    required String amount,
    required bool isIncome,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 13,
          backgroundColor: const Color.fromARGB(255, 85, 145, 141),
          child: Icon(
            icon,
            color: Colors.white,
            size: 19,
          ),
        ),
        const SizedBox(width: 7),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Color.fromARGB(225, 216, 216, 216),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '\$ $amount',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 17,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}