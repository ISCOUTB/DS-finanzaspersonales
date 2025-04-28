import 'package:flutter/material.dart';
import '../Modelos/transaccion.dart';
import '../Servicios/gestor_finanzas.dart';

class PrincipalPage extends StatefulWidget {
  const PrincipalPage({Key? key}) : super(key: key);

  @override
  State<PrincipalPage> createState() => _PrincipalPageState();
}

class _PrincipalPageState extends State<PrincipalPage> {
  String _selectedFilter = 'día';
  List<Transaccion> _transacciones = [];

  final _gestorFinanzas = GestorFinanzas();

  @override
  void initState() {
    super.initState();
    _cargarTransacciones();
  }

  Future<void> _cargarTransacciones() async {
    await _gestorFinanzas.cargarTransacciones();
    setState(() {
      _transacciones = _gestorFinanzas.transacciones;
    });
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

  @override
  Widget build(BuildContext context) {
    final balance = _calculateBalance();

    return Scaffold(
      body: Container(
        color: const Color(0xff368983),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['día', 'semana', 'mes', 'año'].map((filter) {
                    bool isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(
                          filter.toUpperCase(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: Colors.green,
                        onSelected: (bool selected) {
                          setState(() => _selectedFilter = filter);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Balance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '\$ ${balance['balance']?.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildCard(
                        title: 'Ingresos',
                        amount: '\$ ${balance['ingresos']?.toStringAsFixed(2)}',
                        color: Colors.green,
                        icon: Icons.arrow_upward,
                      ),
                      _buildCard(
                        title: 'Gastos',
                        amount: '-\$ ${balance['gastos']?.toStringAsFixed(2)}',
                        color: Colors.red,
                        icon: Icons.arrow_downward,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 150,
                      height: 150,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDFF6E4),
                        shape: BoxShape.circle,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${balance['ingresos']?.toStringAsFixed(2)} cop',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${balance['gastos']?.toStringAsFixed(2)} cop',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            amount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}