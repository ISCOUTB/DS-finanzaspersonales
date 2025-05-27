import 'package:flutter/material.dart';
import '../Modelos/transaccion.dart';
import 'form_gastos.dart';
import 'form_ingresos.dart';
import '../Servicios/gestor_finanzas.dart';
import '../pages/transfer_history.dart'; // Para acceder a transaccionesActualizadas

class TransactionDetail extends StatefulWidget {
  final Transaccion transaccion;
  final Future<bool> Function()? onEdit;
  final Future<void> Function()? onDelete;

  const TransactionDetail({
    super.key,
    required this.transaccion,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<TransactionDetail> createState() => _TransactionDetailState();
}

class _TransactionDetailState extends State<TransactionDetail> {
  late Transaccion _transaccionActual;
  late final GestorFinanzas _gestorFinanzas;
  late final VoidCallback _notifierListener;

  @override
  void initState() {
    super.initState();
    _gestorFinanzas = GestorFinanzas();
    _transaccionActual = widget.transaccion;
    _notifierListener = () async {
      await _gestorFinanzas.cargarTransacciones();
      final actualizada = _gestorFinanzas.transacciones.firstWhere(
        (t) => t.id == _transaccionActual.id,
        orElse: () => _transaccionActual,
      );
      setState(() {
        _transaccionActual = actualizada;
      });
    };
    transaccionesActualizadas.addListener(_notifierListener);
  }

  @override
  void dispose() {
    transaccionesActualizadas.removeListener(_notifierListener);
    super.dispose();
  }

  Future<bool> _editarTransaccion(
    BuildContext context,
    Transaccion transaccion,
  ) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) {
          if (transaccion.tipo == 'ingreso') {
            return FormIngresos(
              transaccion: transaccion,
            ); // Navega al formulario de ingresos
          } else {
            return FormGastos(
              transaccion: transaccion,
            ); // Navega al formulario de gastos
          }
        },
      ),
    );

    if (result == true) {
      await _gestorFinanzas.cargarTransacciones();
      transaccionesActualizadas.value = !transaccionesActualizadas.value;
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final transaccion = _transaccionActual;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Transferencia'),
        actions: [
          if (widget.onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final result = await _editarTransaccion(context, _transaccionActual);
                if (result == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transacción actualizada exitosamente'),
                    ),
                  );
                  // Ya no es necesario cerrar la pantalla, se actualiza automáticamente
                }
              },
            ),
          if (widget.onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await widget.onDelete!();
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ícono y monto
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xff368983).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  _transaccionActual.categoria.icono,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              _transaccionActual.tipo == 'ingreso' ? 'Ingreso' : 'Egreso',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              '\$${_transaccionActual.monto.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color:
                    _transaccionActual.tipo == 'ingreso' ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 30),
            _buildDetailRow(
              'Estado',
              _transaccionActual.tipo == 'ingreso' ? 'Ingreso' : 'Egreso',
            ),
            _buildDetailRow('De', _transaccionActual.categoria.nombre),
            _buildDetailRow(
              'Fecha',
              '${_transaccionActual.fecha.day.toString().padLeft(2, '0')}/${_transaccionActual.fecha.month.toString().padLeft(2, '0')}/${_transaccionActual.fecha.year}',
            ),
            if (_transaccionActual.descripcion != null &&
                _transaccionActual.descripcion!.isNotEmpty)
              _buildDetailRow('Descripción', _transaccionActual.descripcion!),
            const Spacer(),
            // ...existing code for any buttons or actions...
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
