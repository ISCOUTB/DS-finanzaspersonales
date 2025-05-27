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
  String _searchQuery = '';

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
    final esPredefinida = CategoriaService.esCategoriaPredefinda(categoria.nombre);
    if (esPredefinida) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pueden modificar las categorías predefinidas'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar o eliminar'),
          content: Text('¿Qué deseas hacer con la categoría "${categoria.nombre}"?'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context, false); // Solo cerrar
                final editResult = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoriaForm(categoria: categoria),
                  ),
                );
                if (editResult == true) _loadCategorias();
              },
              child: const Text('Editar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true); // Eliminar
              },
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
    if (result == true) {
      final eliminado = CategoriaService.eliminarCategoria(categoria.nombre);
      if (eliminado) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Categoría eliminada exitosamente')),
        );
        _loadCategorias();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo eliminar la categoría'), backgroundColor: Colors.red),
        );
      }
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
    final categoriasFiltradas = _categorias.where((c) =>
      c.nombre.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar categoría...',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF368983)),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: categoriasFiltradas.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final categoria = categoriasFiltradas[index];
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