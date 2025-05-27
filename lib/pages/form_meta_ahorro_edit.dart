import 'package:flutter/material.dart';
import '../Modelos/categoria_service.dart';

class FormMetaAhorroEdit extends StatefulWidget {
  final String categoriaNombre;
  final double objetivo;
  final double acumulado;
  final Function(String, double, double) onSave;
  final Function()? onDelete;
  const FormMetaAhorroEdit({Key? key, required this.categoriaNombre, required this.objetivo, required this.acumulado, required this.onSave, this.onDelete}) : super(key: key);

  @override
  State<FormMetaAhorroEdit> createState() => _FormMetaAhorroEditState();
}

class _FormMetaAhorroEditState extends State<FormMetaAhorroEdit> {
  final _formKey = GlobalKey<FormState>();
  final _metaController = TextEditingController();
  final _acumuladoController = TextEditingController();
  String? _selectedCategoria;
  List categorias = [];

  @override
  void initState() {
    super.initState();
    categorias = CategoriaService.getCategoriasGastos();
    _selectedCategoria = widget.categoriaNombre;
    _metaController.text = widget.objetivo.toStringAsFixed(0);
    _acumuladoController.text = widget.acumulado.toStringAsFixed(0);
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
            const Text('Editar Meta de Ahorro', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF368983))),
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
              controller: _acumuladoController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Ahorro actual (COP)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                prefixIcon: const Icon(Icons.account_balance_wallet, color: Color(0xFF368983)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return null;
                if (double.tryParse(value) == null || double.parse(value) < 0) {
                  return 'Ingrese un monto válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF368983),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate() && _selectedCategoria != null) {
                        widget.onSave(
                          _selectedCategoria!,
                          double.parse(_metaController.text),
                          double.parse(_acumuladoController.text),
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Guardar Cambios', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                if (widget.onDelete != null)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                    ),
                    onPressed: () {
                      widget.onDelete!();
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
