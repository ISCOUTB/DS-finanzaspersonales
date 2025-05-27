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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Eliminado: No recargar categorías aquí para evitar sobrescribir el estado y replicar la lógica de ingresos
    // setState(() {
    //   _categorias = CategoriaService.getCategoriasGastos();
    //   _updateSelectedCategoryIfNeeded();
    // });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fondo = isDark ? const Color(0xFF121B22) : const Color.fromARGB(225, 47, 125, 121);
    final cardColor = isDark ? theme.cardColor : Colors.white;
    final labelColor = isDark ? Colors.white : Colors.black87;
    final buttonColor = isDark ? const Color(0xFF25D366) : const Color.fromARGB(225, 47, 125, 121);
    final cancelColor = isDark ? const Color(0xFF25D366) : const Color.fromARGB(225, 47, 125, 121);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: fondo,
      appBar: AppBar(
        backgroundColor: fondo,
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
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: const BorderRadius.all(Radius.circular(30)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    _buildLabel('Categoría', labelColor),
                    _buildCategoryDropdown(isDark, cardColor, labelColor),
                    const SizedBox(height: 20),
                    _buildLabel('Cantidad', labelColor),
                    _buildAmountRow(isDark, cardColor, labelColor),
                    const SizedBox(height: 20),
                    _buildLabel('Fecha', labelColor),
                    _buildDatePicker(isDark, cardColor, labelColor),
                    const SizedBox(height: 20),
                    _buildLabel('Nombre', labelColor),
                    _buildNameField(isDark, cardColor, labelColor),
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
                        backgroundColor: buttonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        widget.transaccion != null ? 'Modificar' : 'Crear',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          color: cancelColor,
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

  Widget _buildLabel(String text, Color? color) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 15,
        color: color,
      ),
    );
  }

  Widget _buildCategoryDropdown(bool isDark, Color cardColor, Color labelColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF232D36) : Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
      ),
      child: DropdownButtonFormField<Categoria>(
        value: _selectedCategory,
        dropdownColor: cardColor,
        style: TextStyle(color: labelColor),
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
            setState(() {
              _selectedCategory = value;
            });
          }
        },
      ),
    );
  }

  Widget _buildAmountRow(bool isDark, Color cardColor, Color labelColor) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _amountController,
            style: TextStyle(color: labelColor),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark ? const Color(0xFF232D36) : Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
              ),
              hintText: '0.00',
              hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black38),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa un monto';
              }
              final num? parsed = num.tryParse(value);
              if (parsed == null || parsed <= 0) {
                return 'Ingresa un monto válido y mayor a 0';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF232D36) : Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
          ),
          child: Text('COP', style: TextStyle(color: labelColor)),
        ),
      ],
    );
  }

  Widget _buildDatePicker(bool isDark, Color cardColor, Color labelColor) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF232D36) : Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
      ),
      child: InkWell(
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            builder: (context, child) {
              return Theme(
                data: isDark ? ThemeData.dark() : ThemeData.light(),
                child: child!,
              );
            },
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
                style: TextStyle(color: labelColor, fontSize: 16),
              ),
              Icon(Icons.calendar_today, color: labelColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameField(bool isDark, Color cardColor, Color labelColor) {
    return TextFormField(
      controller: _nameController,
      style: TextStyle(color: labelColor),
      decoration: InputDecoration(
        filled: true,
        fillColor: isDark ? const Color(0xFF232D36) : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
        ),
        hintText: widget.transaccion != null ? 'Nombre' : 'Descripción',
        hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black38),
      ),
      validator: (value) {
        if (value != null && value.length > 100) {
          return 'Máximo 100 caracteres';
        }
        return null;
      },
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
