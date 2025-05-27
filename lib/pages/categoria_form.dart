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
    }
  }

  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      final newCategory = Categoria(
        nombre: _nameController.text,
        tipo: _selectedType,
        icono: _selectedIcon,
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
        title: const Text(
          'Crear Categoría',
          style: TextStyle(color: Colors.white),
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
                    _buildLabel('Nombre de la Categoría'),
                    _buildNameField(),
                    const SizedBox(height: 20),
                    _buildLabel('Tipo de Categoría'),
                    _buildTypeDropdown(),
                    const SizedBox(height: 20),
                    _buildLabel('Ícono'),
                    _buildIconDropdown(),
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
                        backgroundColor: const Color.fromARGB(225, 47, 125, 121),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Crear',
                        style: TextStyle(color: Colors.white),
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
                        style: TextStyle(color: Color.fromARGB(225, 47, 125, 121)),
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
          return 'Por favor ingresa un nombre';
        }
        return null;
      },
    );
  }

  Widget _buildTypeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedType,
        dropdownColor: Colors.white,
        style: const TextStyle(color: Colors.black87),
        decoration: const InputDecoration(border: InputBorder.none),
        items: ['ingreso', 'gastos'].map((type) {
          return DropdownMenuItem<String>(
            value: type,
            child: Text(
              type == 'ingreso' ? 'Ingreso' : 'Gastos',
              style: const TextStyle(color: Colors.black87),
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

  Widget _buildIconDropdown() {
    // Elimina duplicados
    final iconosUnicos = _iconOptions.toSet().toList();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedIcon,
        dropdownColor: Colors.white,
        style: const TextStyle(color: Colors.black87, fontSize: 20),
        decoration: const InputDecoration(border: InputBorder.none),
        items: iconosUnicos.map((icon) {
          return DropdownMenuItem<String>(
            value: icon,
            child: Text(icon, style: const TextStyle(fontSize: 20)),
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
}