import 'package:flutter/material.dart';
import '../Modelos/categoria.dart';
import '../Modelos/transaccion.dart';
import '../Modelos/categoria_service.dart';
import '../Servicios/gestor_finanzas.dart';
import 'package:uuid/uuid.dart';
import 'transfer_history.dart';

class FormGastos extends StatefulWidget {
  final Transaccion? transaccion;

  const FormGastos({super.key, this.transaccion});

  @override
  State<FormGastos> createState() => _FormGastosState();
}

class _FormGastosState extends State<FormGastos> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _nameController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  List<Categoria> _categorias = [];

  late Categoria _selectedCategory;

  @override
  void initState() {
    super.initState();
    _categorias = CategoriaService.getCategoriasGastos();

    // Precargar datos si se pasa una transacción
    if (widget.transaccion != null) {
      _amountController.text = widget.transaccion!.monto.toString();
      _nameController.text = widget.transaccion!.descripcion ?? '';
      _selectedDate = widget.transaccion!.fecha;

      // Verifica si la categoría de la transacción está en la lista
      if (_categorias.contains(widget.transaccion!.categoria)) {
        _selectedCategory = widget.transaccion!.categoria;
      } else {
        // Agrega la categoría temporalmente si no está en la lista
        _categorias.add(widget.transaccion!.categoria);
        _selectedCategory = widget.transaccion!.categoria;
      }
    } else {
      _selectedCategory = _categorias.first;
    }
  }

  void _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      final nuevaTransaccion = Transaccion(
        id: widget.transaccion?.id ?? const Uuid().v4(),
        tipo: 'egreso',
        monto: double.parse(_amountController.text),
        descripcion: _nameController.text,
        fecha: _selectedDate,
        categoria: _selectedCategory,
      );
      final gestor = GestorFinanzas(); // Singleton
      if (widget.transaccion != null) {
        await gestor.editarTransaccion(nuevaTransaccion.id, nuevaTransaccion);
      } else {
        await gestor.agregarTransaccion(nuevaTransaccion);
      }
      if (mounted) {
        transaccionesActualizadas.value = !transaccionesActualizadas.value;
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(225, 47, 125, 121),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(225, 47, 125, 121),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.transaccion != null ? 'Editar egreso' : 'Planificar un gasto',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(30)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 150),
                  ],
                ),
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
                        backgroundColor: const Color.fromARGB(
                          225,
                          47,
                          125,
                          121,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        widget.transaccion != null ? 'Modificar' : 'Crear',
                        style: const TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
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
                        style: TextStyle(
                          color: Color.fromARGB(225, 47, 125, 121),
                        ),
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
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonFormField<Categoria>(
        value: _selectedCategory,
        dropdownColor: Colors.white,
        style: const TextStyle(color: Colors.black87),
        decoration: const InputDecoration(border: InputBorder.none),
        items:
            _categorias.map((categoria) {
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
            style: const TextStyle(color: Colors.black87),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: const Text('COP', style: TextStyle(color: Colors.black87)),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: InkWell(
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
                style: const TextStyle(color: Colors.black87),
              ),
              Icon(Icons.calendar_today, color: Colors.grey[600]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
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
        style: TextStyle(
          color: Colors.grey[800],
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    return months[month - 1];
  }
}
