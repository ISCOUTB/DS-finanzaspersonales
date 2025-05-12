import 'package:flutter/material.dart';
import '../Modelos/transaccion.dart';

class TransactionDetail extends StatelessWidget {
  final Transaccion transaccion;

  const TransactionDetail({super.key, required this.transaccion});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff368983),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Text(
                    'Transaction Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Icon(Icons.more_vert, color: Colors.white),
                ],
              ),
            ),

            // Contenido principal
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    // Ícono y monto
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xff368983).withValues(alpha: 51),
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
                      transaccion.tipo == 'ingreso' ? 'Income' : 'Expense',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '\$${transaccion.monto.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: transaccion.tipo == 'ingreso' 
                            ? Colors.green 
                            : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Detalles de la transacción
                    _buildDetailRow('Status', 
                      transaccion.tipo == 'ingreso' ? 'Income' : 'Expense'),
                    _buildDetailRow('From', transaccion.categoria.nombre),
                    _buildDetailRow('Time', 
                      '${transaccion.fecha.hour}:${transaccion.fecha.minute.toString().padLeft(2, '0')}'),
                    _buildDetailRow('Date', 
                      '${transaccion.fecha.day}/${transaccion.fecha.month}/${transaccion.fecha.year}'),
                    if (transaccion.descripcion != null)
                      _buildDetailRow('Description', transaccion.descripcion!),
                    
                    const Spacer(),
                    // Botón de descargar recibo
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff368983),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        // Implementar descarga de recibo
                      },
                      child: const Text('Download Receipt'),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}