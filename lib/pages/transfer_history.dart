import 'package:flutter/material.dart';
import '../Servicios/gestor_finanzas.dart';
import '../Modelos/transaccion.dart';
import 'detalle_transfer.dart';
import 'principal_pages.dart';
import 'form_gastos.dart';
import 'form_ingresos.dart';
import 'estadisticas.dart';

// Notificador global para cambios en transacciones
final ValueNotifier<bool> transaccionesActualizadas = ValueNotifier(false);

class Transferhistory extends StatefulWidget {
  const Transferhistory({super.key});

  @override
  State<Transferhistory> createState() => _TransferhistoryState();
}

class _TransferhistoryState extends State<Transferhistory> {
  final GestorFinanzas _gestorFinanzas = GestorFinanzas();
  String _filtroActual = 'Todas';
  String _searchQuery = '';
  DateTimeRange? _selectedDateRange;

  late final VoidCallback _transaccionesListener;

  @override
  void initState() {
    super.initState();
    _cargarTransacciones();
    // Escuchar cambios globales para refrescar automáticamente
    _transaccionesListener = () {
      setState(() {
        _filtroActual = 'Todas';
      });
      _cargarTransacciones();
    };
    transaccionesActualizadas.addListener(_transaccionesListener);
  }

  @override
  void dispose() {
    transaccionesActualizadas.removeListener(_transaccionesListener);
    super.dispose();
  }

  Future<void> _cargarTransacciones() async {
    await _gestorFinanzas.cargarTransacciones();
    if (!mounted) return;
    setState(() {
      // Solo forzamos la reconstrucción, el filtrado se hace en _getFilteredTransacciones
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
      if (!mounted) return false;
      setState(() {}); // Fuerza la reconstrucción para reflejar los cambios
      // Notificar a la pantalla principal y estadísticas para recargar los datos
      PrincipalPage.globalKey.currentState?.cargarTransacciones();
      EstadisticasPage.globalKey.currentState?.cargarDatos();
      transaccionesActualizadas.value = !transaccionesActualizadas.value;
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
      if (!mounted) return;
      setState(() {
        _filtrarTransacciones();
      });
      // Notificar a la pantalla principal y estadísticas para recargar los datos
      PrincipalPage.globalKey.currentState?.cargarTransacciones();
      EstadisticasPage.globalKey.currentState?.cargarDatos();
      transaccionesActualizadas.value = !transaccionesActualizadas.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fondoHeader = isDark ? theme.scaffoldBackgroundColor : const Color(0xFF368983);
    final fondoCard = isDark ? theme.cardColor : Colors.white;
    final fondoBalance = isDark ? theme.scaffoldBackgroundColor : const Color(0xFF368983);
    final colorPrimario = isDark ? theme.colorScheme.primary : Colors.white;
    final colorSecundario = isDark ? const Color(0xFF232D36) : Colors.white;
    final colorPillActiva = isDark ? theme.colorScheme.primary : const Color(0xFF368983);
    final colorPillInactiva = isDark ? Colors.transparent : Colors.white;
    final colorTextoPillActiva = Colors.white;
    final colorTextoPillInactiva = isDark ? theme.colorScheme.primary : const Color(0xFF368983);
    final colorIconoBusqueda = isDark ? theme.colorScheme.primary : Colors.white;
    final colorBotonFecha = isDark ? theme.cardColor : Colors.white;
    final colorIconoFecha = isDark ? theme.colorScheme.primary : const Color(0xFF368983);

    return Scaffold(
      backgroundColor: fondoBalance,
      body: SafeArea(
        child: Column(
          children: [
            // Header compacto sólido
            Container(
              width: double.infinity,
              color: fondoHeader,
              padding: const EdgeInsets.only(top: 18, left: 20, right: 20, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Historial de Transferencias',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorPrimario,
                      letterSpacing: 0.2,
                    ) ?? TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorPrimario),
                  ),
                ],
              ),
            ),
            // Buscador con fondo blanco y borde redondeado
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorBotonFecha,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Buscar transacción...',
                          hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black38),
                          prefixIcon: Icon(Icons.search, color: colorIconoBusqueda),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: colorBotonFecha,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.date_range, color: colorIconoFecha),
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
            // Pills con fondo sólido y borde, sin degradado
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 18, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['Todas', 'Ingresos', 'Gastos'].map((filtro) {
                  final activo = _filtroActual == filtro;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _filtroActual = filtro;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            // Degradado visible solo en light mode y cuando está activo
                            gradient: activo && !isDark
                                ? const LinearGradient(
                                    colors: [Color(0xFF25D366), Color(0xFF128C7E)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: activo
                                ? (isDark ? colorPillActiva : null)
                                : colorPillInactiva,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: colorPillActiva, width: 1.2),
                            boxShadow: activo
                                ? [
                                    BoxShadow(
                                      color: colorPillActiva.withOpacity(0.13),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              filtro.toUpperCase(),
                              style: TextStyle(
                                color: activo ? colorTextoPillActiva : colorTextoPillInactiva,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            // Contenido principal
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: fondoCard,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  children: [
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
                                color: isDark ? theme.colorScheme.surface : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                onTap: () async {
                                  await Navigator.push<bool>(
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
                                  await _cargarTransacciones();
                                  setState(() {});
                                },
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: colorSecundario,
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
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                subtitle: Text(
                                  '${transaccion.fecha.day}/${transaccion.fecha.month}/${transaccion.fecha.year}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isDark ? Colors.white70 : Colors.grey[600],
                                  ),
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
                                            ? (isDark ? const Color(0xFF25D366) : Colors.green)
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
