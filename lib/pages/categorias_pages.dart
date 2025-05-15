import 'package:flutter/material.dart';
import '../Modelos/categoria.dart';
import '../Modelos/categoria_service.dart';
import 'categoria_form.dart';

class CategoriasPage extends StatefulWidget {
  const CategoriasPage({super.key});

  @override
  State<CategoriasPage> createState() => _CategoriasPageState();
}

class _CategoriasPageState extends State<CategoriasPage> {
  List<Categoria> _categorias = [];

  @override
  void initState() {
    super.initState();
    _loadCategorias();
  }

  void _loadCategorias() {
    setState(() {
      _categorias = CategoriaService.getCategorias();
    });
  }

  void _editCategoria(Categoria categoria) async {
    // Verificar si es una categoría predefinida
    if (CategoriaService.esCategoriaPredefinda(categoria.nombre)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pueden modificar las categorías predefinidas'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoriaForm(categoria: categoria),
      ),
    );

    if (result == true) {
      _loadCategorias();
    }
  }

  void _createCategoria() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CategoriaForm(),
      ),
    );

    if (result == true) {
      _loadCategorias();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(225, 47, 125, 121),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(225, 47, 125, 121),
        elevation: 0,
        title: const Text(
          'Categorías',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _categorias.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final categoria = _categorias[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Text(
                        categoria.icono,
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(categoria.nombre),
                      subtitle: Text(
                        categoria.tipo == 'ingreso' ? 'Ingreso' : 'Gasto',
                        style: TextStyle(
                          color: categoria.tipo == 'ingreso'
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editCategoria(categoria),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(225, 47, 125, 121),
        onPressed: _createCategoria,
        child: const Icon(Icons.add),
      ),
    );
  }
}