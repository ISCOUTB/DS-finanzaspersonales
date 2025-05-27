import 'package:flutter/material.dart';
import '../Modelos/categoria_service.dart';

class FormMetaAhorro extends StatefulWidget {
  final Function(String, double, double) onSave;
  const FormMetaAhorro({Key? key, required this.onSave}) : super(key: key);

  @override
  State<FormMetaAhorro> createState() => _FormMetaAhorroState();
}

class _FormMetaAhorroState extends State<FormMetaAhorro> {
  final _formKey = GlobalKey<FormState>();
  final _metaController = TextEditingController();
  double _acumulado = 0;
  String? _selectedCategoria;
  List categorias = [];

  @override
  void initState() {
    super.initState();
    categorias = CategoriaService.getCategoriasGastos();
    if (categorias.isNotEmpty) {
      _selectedCategoria = categorias.first.nombre;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nueva Meta de Ahorro', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF368983))),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              value: _selectedCategoria,
              items: categorias.map<DropdownMenuItem<String>>((cat) {
                return DropdownMenuItem<String>(
                  value: cat.nombre,
                  child: Row(
                    children: [
                      Text(cat.icono, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      Text(cat.nombre, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategoria = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _metaController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Meta de ahorro (COP)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                prefixIcon: const Icon(Icons.savings, color: Color(0xFF368983)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese el monto de la meta';
                }
                if (double.tryParse(value) == null || double.parse(value) <= 0) {
                  return 'Ingrese un monto válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            TextFormField(
              initialValue: '0',
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Ahorro inicial (COP)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                prefixIcon: const Icon(Icons.account_balance_wallet, color: Color(0xFF368983)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _acumulado = double.tryParse(value) ?? 0;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) return null;
                if (double.tryParse(value) == null || double.parse(value) < 0) {
                  return 'Ingrese un monto válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF368983),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate() && _selectedCategoria != null) {
                    widget.onSave(_selectedCategoria!, double.parse(_metaController.text), _acumulado);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Guardar Meta', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
