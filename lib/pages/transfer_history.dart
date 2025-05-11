import 'package:flutter/material.dart';
import '../Servicios/gestor_finanzas.dart';
import '../Modelos/transaccion.dart';
import 'detalle_transfer.dart';

class Transferhistory extends StatefulWidget {
  const Transferhistory({super.key});

  @override
  State<Transferhistory> createState() => _TransferhistoryState();
}

class _TransferhistoryState extends State<Transferhistory> {
  final GestorFinanzas _gestorFinanzas = GestorFinanzas();
  String _filtroActual = 'Todas';
  List<Transaccion> _transacciones = [];

  @override
  void initState() {
    super.initState();
    _cargarTransacciones();
  }

  Future<void> _cargarTransacciones() async {
    await _gestorFinanzas.cargarTransacciones();
    setState(() {
      _transacciones = _filtrarTransacciones();
    });
  }

  List<Transaccion> _filtrarTransacciones() {
    switch (_filtroActual) {
      case 'Ingresos':
        return _gestorFinanzas.transacciones
            .where((t) => t.tipo == 'ingreso')
            .toList();
      case 'Gastos':
        return _gestorFinanzas.transacciones
            .where((t) => t.tipo == 'gastos')
            .toList();
      default:
        return _gestorFinanzas.transacciones;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(225, 47, 125, 121),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Historial de Transferencias',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Contenido principal
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white, // Cambiado de negro a blanco
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    // Filtros
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: ['Todas', 'Ingresos', 'Gastos'].map((filtro) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _filtroActual = filtro;
                                _transacciones = _filtrarTransacciones();
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: _filtroActual == filtro
                                    ? const Color.fromARGB(225, 47, 125, 121)
                                    : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                filtro,
                                style: TextStyle(
                                  color: _filtroActual == filtro
                                      ? Colors.white
                                      : Colors.grey[800],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    // Lista de transacciones
                    Expanded(
                      child: ListView.builder(
                        itemCount: _transacciones.length,
                        itemBuilder: (context, index) {
                          final transaccion = _transacciones[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100, // Cambiado a gris muy claro
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TransactionDetail(
                                      transaccion: transaccion,
                                    ),
                                  ),
                                );
                              },
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(225, 47, 125, 121)
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Center(
                                  child: Text(
                                    transaccion.categoria.icono,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                              ),
                              title: Text(
                                transaccion.categoria.nombre,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87, // Cambiado a negro
                                ),
                              ),
                              subtitle: Text(
                                '${transaccion.fecha.day}/${transaccion.fecha.month}/${transaccion.fecha.year}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              trailing: Text(
                                '${transaccion.tipo == 'ingreso' ? '+' : '-'} \$${transaccion.monto.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: transaccion.tipo == 'ingreso'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ),
                          );
                        },
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
}
