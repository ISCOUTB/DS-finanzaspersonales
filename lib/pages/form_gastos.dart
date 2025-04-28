import 'package:flutter/material.dart';
import '../Modelos/categoria.dart';
import '../Modelos/transaccion.dart';
import '../Modelos/CategoriaService.dart';
import '../Servicios/gestor_finanzas.dart';
import 'package:uuid/uuid.dart';

class FormGastos extends StatefulWidget {
  const FormGastos({Key? key}) : super(key: key);

  @override
  State<FormGastos> createState() => _FormGastosState();
}

class _FormGastosState extends State<FormGastos> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _nameController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isPaid = false;
  
  List<Categoria> _categorias = [];
  
  late Categoria _selectedCategory;

  @override
  void initState() {
    super.initState();
    _categorias = CategoriaService.getCategoriasGastos();
    _selectedCategory = _categorias.first;
  }

  void _saveTransaction() async {
  if (_formKey.currentState!.validate()) {
    final transaction = Transaccion(
      id: const Uuid().v4(),
      tipo: 'gastos',
      monto: double.parse(_amountController.text),
      fecha: _selectedDate,
      categoria: _selectedCategory,
      descripcion: _nameController.text,
    );

    await GestorFinanzas().agregarTransaccion(transaction);
    Navigator.pop(context, transaction);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Planificar un gasto',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Categoría'),
                  _buildCategoryDropdown(),
                  const SizedBox(height: 20),
                  _buildLabel('Cantidad'),
                  _buildAmountRow(),
                  const SizedBox(height: 20),
                  _buildLabel('Fecha'),
                  _buildDatePicker(),
                  const SizedBox(height: 20),
                  _buildLabel('Nombre'),
                  _buildNameField(),
                  const SizedBox(height: 150), // Espacio para los botones
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? -100 : 16,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: MediaQuery.of(context).viewInsets.bottom > 0 ? 0 : 1,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveTransaction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text('Crear'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonFormField<Categoria>(
        value: _selectedCategory,
        dropdownColor: const Color(0xFF2A2A2A),
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(border: InputBorder.none),
        items: _categorias.map((categoria) {
          return DropdownMenuItem<Categoria>(
            value: categoria,
            child: Row(
              children: [
                Text(categoria.icono),
                const SizedBox(width: 10),
                Text(categoria.nombre),
              ],
            ),
          );
        }).toList(),
        onChanged: (Categoria? value) {
          if (value != null) {
            setState(() => _selectedCategory = value);
          }
        },
      ),
    );
  }

  Widget _buildAmountRow() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _amountController,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF2A2A2A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa un monto';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'COP',
            style: TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(width: 10),
        Switch(
          value: _isPaid,
          onChanged: (bool value) {
            setState(() => _isPaid = value);
          },
          activeColor: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          setState(() => _selectedDate = picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
              style: const TextStyle(color: Colors.white),
            ),
            const Icon(Icons.calendar_today, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa una descripción';
        }
        return null;
      },
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return months[month - 1];
  }
}