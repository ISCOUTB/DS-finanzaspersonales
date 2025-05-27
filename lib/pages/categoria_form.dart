import 'package:flutter/material.dart';
import '../Modelos/categoria.dart';
import '../Modelos/categoria_service.dart';

class CategoriaForm extends StatefulWidget {
  final Categoria? categoria;

  const CategoriaForm({super.key, this.categoria});

  @override
  State<CategoriaForm> createState() => _CategoriaFormState();
}

class _CategoriaFormState extends State<CategoriaForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedType = 'ingreso';
  String _selectedIcon = '✨';
  double? _presupuestoMensual;
  final _presupuestoController = TextEditingController();

  final List<String> _iconOptions = [
    '💰', '💻', '📈', '🛒', '🏆', '🎁', '🏦', '🏠', '🧾', '📊', '🆘', '✨',
    '🍔', '🚗', '🏠', '💡', '📱', '🎓', '🏥', '🛡️', '🎮', '👕', '🐶', '🛍️',
    '✈️', '🛠️', '💳', '📄', '🏦', '❤️', '💇‍♂️', '📺', '🎉', '🖥️', '🚨'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.categoria != null) {
      _nameController.text = widget.categoria!.nombre;
      _selectedType = widget.categoria!.tipo;
      _selectedIcon = widget.categoria!.icono;
      _presupuestoMensual = widget.categoria!.presupuestoMensual;
      if (_presupuestoMensual != null) {
        _presupuestoController.text = _presupuestoMensual!.toString();
      }
    }
  }

  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      double? presupuesto;
      if (_selectedType == 'egreso' && _presupuestoController.text.isNotEmpty) {
        presupuesto = double.tryParse(_presupuestoController.text);
        if (presupuesto != null && presupuesto <= 0) presupuesto = null;
      }
      final newCategory = Categoria(
        nombre: _nameController.text,
        tipo: _selectedType,
        icono: _selectedIcon,
        presupuestoMensual: _selectedType == 'egreso' ? presupuesto : null,
      );

      bool success;
      if (widget.categoria != null) {
        // Actualizar categoría existente
        success = CategoriaService.actualizarCategoria(widget.categoria!, newCategory);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Categoría actualizada exitosamente')),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se puede modificar una categoría predefinida'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // Crear nueva categoría
        CategoriaService.agregarCategoria(newCategory);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Categoría creada exitosamente')),
        );
        Navigator.pop(context, true);
      }
    }
  }

  void _updateSelectedIconIfNeeded() {
    // Si el ícono seleccionado no está en la lista, selecciona el primero
    if (!_iconOptions.contains(_selectedIcon)) {
      _selectedIcon = _iconOptions.isNotEmpty ? _iconOptions.first : '';
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSelectedIconIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fondo = isDark ? const Color(0xFF121B22) : const Color.fromARGB(225, 47, 125, 121);
    final cardColor = isDark ? const Color(0xFF232D36) : Colors.white;
    // Fix: define non-nullable color variables directly from theme logic
    final Color inputFill = isDark ? const Color(0xFF232D36) : Colors.grey[100]!;
    final Color border = isDark ? Colors.grey[700]! : Colors.grey[300]!;
    final Color dropdown = isDark ? const Color(0xFF232D36) : Colors.white;
    final Color buttonColor = isDark ? const Color(0xFF25D366) : const Color.fromARGB(225, 47, 125, 121);
    final Color cancelColor = isDark ? const Color(0xFF25D366) : const Color.fromARGB(225, 47, 125, 121);
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
          widget.categoria != null ? 'Editar Categoría' : 'Crear Categoría',
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
                    _buildLabel('Nombre de la Categoría'),
                    _buildNameField(isDark, inputFill, border),
                    const SizedBox(height: 20),
                    _buildLabel('Tipo de Categoría'),
                    _buildTypeDropdown(isDark, inputFill, border, dropdown),
                    const SizedBox(height: 20),
                    _buildLabel('Ícono'),
                    _buildIconDropdown(isDark, inputFill, border, dropdown),
                    if (_selectedType == 'egreso') ...[
                      const SizedBox(height: 20),
                      _buildLabel('Presupuesto mensual (opcional)'),
                      _buildPresupuestoField(isDark, inputFill, border),
                    ],
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
                      onPressed: _saveCategory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        widget.categoria != null ? 'Guardar' : 'Crear',
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
                        style: TextStyle(color: cancelColor),
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

  Widget _buildLabel(String text) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildNameField(bool isDark, Color fillColor, Color borderColor) {
    return TextFormField(
      controller: _nameController,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borderColor),
        ),
        hintText: 'Ej: Sueldo',
        hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black38),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa un nombre';
        }
        return null;
      },
    );
  }

  Widget _buildTypeDropdown(bool isDark, Color fillColor, Color borderColor, Color dropdownBg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedType,
        dropdownColor: dropdownBg,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: const InputDecoration(border: InputBorder.none),
        items: ['ingreso', 'egreso'].map((type) {
          return DropdownMenuItem<String>(
            value: type,
            child: Text(
              type == 'ingreso' ? 'Ingreso' : 'Gasto',
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            ),
          );
        }).toList(),
        onChanged: (String? value) {
          if (value != null) {
            setState(() => _selectedType = value);
          }
        },
      ),
    );
  }

  Widget _buildIconDropdown(bool isDark, Color fillColor, Color borderColor, Color dropdownBg) {
    final iconosUnicos = _iconOptions.toSet().toList();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedIcon,
        dropdownColor: dropdownBg,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 20),
        decoration: const InputDecoration(border: InputBorder.none),
        items: iconosUnicos.map((icon) {
          return DropdownMenuItem<String>(
            value: icon,
            child: Text(icon, style: TextStyle(fontSize: 20, color: isDark ? Colors.white : Colors.black87)),
          );
        }).toList(),
        onChanged: (String? value) {
          if (value != null) {
            setState(() => _selectedIcon = value);
          }
        },
      ),
    );
  }

  Widget _buildPresupuestoField(bool isDark, Color fillColor, Color borderColor) {
    return TextFormField(
      controller: _presupuestoController,
      keyboardType: TextInputType.number,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borderColor),
        ),
        hintText: 'Ej: 500000',
        hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black38),
        suffixText: 'COP',
      ),
      validator: (value) {
        if (_selectedType == 'egreso' && value != null && value.isNotEmpty) {
          final parsed = double.tryParse(value);
          if (parsed == null || parsed <= 0) {
            return 'Ingresa un monto válido mayor a 0';
          }
        }
        return null;
      },
    );
  }
}