import 'package:flutter/material.dart';
import '../Servicios/gestor_finanzas.dart';
import '../Modelos/transaccion.dart';
import 'detalle_transfer.dart';
import 'principal_pages.dart';
import 'form_gastos.dart';
import 'form_ingresos.dart';

class Transferhistory extends StatefulWidget {
  const Transferhistory({super.key});

  @override
  State<Transferhistory> createState() => _TransferhistoryState();
}

class _TransferhistoryState extends State<Transferhistory> {
  final GestorFinanzas _gestorFinanzas = GestorFinanzas();
  String _filtroActual = 'Todas';
  List<Transaccion> _transacciones = [];
  String _searchQuery = '';
  DateTimeRange? _selectedDateRange;

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
    List<Transaccion> transaccionesFiltradas;

    switch (_filtroActual) {
      case 'Ingresos':
        transaccionesFiltradas =
            _gestorFinanzas.transacciones
                .where((t) => t.tipo == 'ingreso')
                .toList();
        break;
      case 'Gastos':
        transaccionesFiltradas =
            _gestorFinanzas.transacciones
                .where((t) => t.tipo == 'egreso')
                .toList();
        break;
      default:
        transaccionesFiltradas = _gestorFinanzas.transacciones;
    }

    // Ordenar las transacciones por fecha en orden descendente
    transaccionesFiltradas.sort((a, b) => b.fecha.compareTo(a.fecha));

    return transaccionesFiltradas;
  }

  List<Transaccion> _getFilteredTransacciones() {
    List<Transaccion> filtered = _filtrarTransacciones();
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((t) =>
        t.categoria.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        t.monto.toString().contains(_searchQuery) ||
        (t.descripcion ?? '').toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    if (_selectedDateRange != null) {
      filtered = filtered.where((t) =>
        t.fecha.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
        t.fecha.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)))
      ).toList();
    }
    return filtered;
  }

  Future<bool> _editarTransaccion(Transaccion transaccion) async {
  final result = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (context) {
        if (transaccion.tipo == 'ingreso') {
          return FormIngresos(transaccion: transaccion); // Navega al formulario de ingresos
        } else {
          return FormGastos(transaccion: transaccion); // Navega al formulario de gastos
        }
      },
    ),
  );

  if (result == true) {
    await _cargarTransacciones(); // Recarga las transacciones si se editó algo
    return true;
  }
  return false;
}

  Future<void> _eliminarTransaccion(Transaccion transaccion) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar transacción'),
        content: const Text('¿Estás seguro de que deseas eliminar esta transacción?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
    if (confirm == true) {
      // Usa el método eliminarTransaccion del gestor para eliminar correctamente en BD y en memoria
      await _gestorFinanzas.eliminarTransaccion(transaccion.id);
      setState(() {
        _transacciones = _filtrarTransacciones();
      });
      // Notificar a la pantalla principal para recargar los datos
      PrincipalPage.globalKey.currentState?.cargarTransacciones();
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
                children: [
                  const Text(
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
            // Buscador y filtro de fechas
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar transacción...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.date_range, color: Color.fromARGB(225, 47, 125, 121)),
                    tooltip: 'Filtrar por fecha',
                    onPressed: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        initialDateRange: _selectedDateRange,
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDateRange = picked;
                        });
                      }
                    },
                  ),
                  if (_selectedDateRange != null)
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.red),
                      tooltip: 'Quitar filtro de fecha',
                      onPressed: () {
                        setState(() {
                          _selectedDateRange = null;
                        });
                      },
                    ),
                ],
              ),
            ),
            // Contenido principal
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    // Filtros
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children:
                            ['Todas', 'Ingresos', 'Gastos'].map((filtro) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _filtroActual = filtro;
                                // _transacciones = _filtrarTransacciones(); // Ya no es necesario, usamos _getFilteredTransacciones()
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    _filtroActual == filtro
                                        ? const Color.fromARGB(
                                            225,
                                            47,
                                            125,
                                            121,
                                          )
                                        : Colors.grey.withAlpha(26),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                filtro,
                                style: TextStyle(
                                  color:
                                      _filtroActual == filtro
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
                    // Lista de transacciones con animación
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: ListView.builder(
                          key: ValueKey(_getFilteredTransacciones().length),
                          itemCount: _getFilteredTransacciones().length,
                          itemBuilder: (context, index) {
                            final transaccion = _getFilteredTransacciones()[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                onTap: () async {
                                  final result = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (detailContext) =>
                                          TransactionDetail(
                                        transaccion: transaccion,
                                        onEdit: () async {
                                          return await _editarTransaccion(transaccion);
                                        },
                                        onDelete: () async {
                                          await _eliminarTransaccion(transaccion);
                                          Navigator.of(detailContext).pop(false);
                                        },
                                      ),
                                    ),
                                  );
                                  if (result == true) {
                                    await _cargarTransacciones();
                                  }
                                },
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                      225,
                                      47,
                                      125,
                                      121,
                                    ).withOpacity(0.2),
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
                                    color: Colors.black87,
                                  ),
                                ),
                                subtitle: Text(
                                  '${transaccion.fecha.day}/${transaccion.fecha.month}/${transaccion.fecha.year}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${transaccion.tipo == 'ingreso' ? '+' : '-'} \$${transaccion.monto.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: transaccion.tipo == 'ingreso'
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
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
