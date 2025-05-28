import 'package:flutter/material.dart';
import '../Modelos/transaccion.dart';
import 'form_gastos.dart';
import 'form_ingresos.dart';

class TransactionDetail extends StatelessWidget {
  final Transaccion transaccion;
  final Future<bool> Function()? onEdit;
  final Future<void> Function()? onDelete;

  const TransactionDetail({
    super.key,
    required this.transaccion,
    this.onEdit,
    this.onDelete,
  });

  Future<bool> _editarTransaccion(
    BuildContext context,
    Transaccion transaccion,
  ) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) {
          if (transaccion.tipo == 'ingreso') {
            return FormIngresos(transaccion: transaccion);
          } else {
            return FormGastos(transaccion: transaccion);
          }
        },
      ),
    );

    if (result == true) {
      // Regresa a la pantalla anterior y notifica que hubo cambios
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop(true);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Transferencia'),
        actions: [
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final result = await _editarTransaccion(context, transaccion);
                if (result == true) {
                  // Ya se hace pop en _editarTransaccion, así que no es necesario hacer otro pop aquí
                  // Si quieres mostrar un mensaje, puedes hacerlo antes del pop
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   const SnackBar(
                  //     content: Text('Transacción actualizada exitosamente'),
                  //   ),
                  // );
                }
              },
            ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await onDelete!();
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
                color: const Color(0xff368983).withValues(alpha: (51)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  transaccion.categoria.icono,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              transaccion.tipo == 'ingreso' ? 'Ingreso' : 'Egreso',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              '\$${transaccion.monto.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color:
                    transaccion.tipo == 'ingreso' ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 30),
            _buildDetailRow(
              'Estado',
              transaccion.tipo == 'ingreso' ? 'Ingreso' : 'Egreso',
            ),
            _buildDetailRow('De', transaccion.categoria.nombre),
            _buildDetailRow(
              'Fecha',
              '${transaccion.fecha.day.toString().padLeft(2, '0')}/${transaccion.fecha.month.toString().padLeft(2, '0')}/${transaccion.fecha.year}',
            ),
            if (transaccion.descripcion != null &&
                transaccion.descripcion!.isNotEmpty)
              _buildDetailRow('Descripción', transaccion.descripcion!),
            const Spacer(),
            // ...aquí puedes agregar botones adicionales si lo necesitas...
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