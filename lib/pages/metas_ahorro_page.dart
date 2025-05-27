import 'package:flutter/material.dart';
import 'form_meta_ahorro.dart';
import 'form_meta_ahorro_edit.dart';
import '../Modelos/categoria_service.dart';
import '../Modelos/meta_ahorro.dart';

class MetasAhorroPage extends StatefulWidget {
  const MetasAhorroPage({Key? key}) : super(key: key);

  @override
  State<MetasAhorroPage> createState() => _MetasAhorroPageState();
}

class _MetasAhorroPageState extends State<MetasAhorroPage> {
  List<MetaAhorro> metas = [];

  @override
  void initState() {
    super.initState();
    // Ya no se carga desde base de datos, solo se inicializa la lista vacía o con datos de ejemplo si se desea
  }

  void _agregarMeta(String categoriaNombre, double objetivo, double acumulado) {
    final categoria = CategoriaService.getCategoriasGastos().firstWhere((c) => c.nombre == categoriaNombre);
    setState(() {
      metas.add(MetaAhorro(
        id: DateTime.now().millisecondsSinceEpoch, // id temporal en memoria
        nombre: categoria.nombre,
        objetivo: objetivo,
        acumulado: acumulado,
        icono: categoria.icono,
      ));
    });
  }

  void _editarMeta(int index, String categoriaNombre, double objetivo, double acumulado) {
    final categoria = CategoriaService.getCategoriasGastos().firstWhere((c) => c.nombre == categoriaNombre);
    setState(() {
      metas[index] = MetaAhorro(
        id: metas[index].id,
        nombre: categoria.nombre,
        objetivo: objetivo,
        acumulado: acumulado,
        icono: categoria.icono,
      );
    });
  }

  void _eliminarMeta(int index) {
    setState(() {
      metas.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metas de Ahorro'),
        backgroundColor: const Color(0xFF368983),
      ),
      body: metas.isEmpty
          ? const Center(
              child: Text('No tienes metas de ahorro. ¡Agrega una!', style: TextStyle(fontSize: 17, color: Color(0xFF368983))),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(18),
              itemCount: metas.length,
              itemBuilder: (context, index) {
                final meta = metas[index];
                final porcentaje = (meta.acumulado / meta.objetivo).clamp(0.0, 1.0);
                return GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (context) => Padding(
                        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: FormMetaAhorroEdit(
                          categoriaNombre: meta.nombre,
                          objetivo: meta.objetivo,
                          acumulado: meta.acumulado,
                          onSave: (cat, obj, acum) => _editarMeta(index, cat, obj, acum),
                          onDelete: () => _eliminarMeta(index),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFF368983).withOpacity(0.10)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(meta.icono, style: const TextStyle(fontSize: 28)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  meta.nombre,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF368983).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  '${(porcentaje * 100).toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    color: Color(0xFF368983),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: porcentaje),
                            duration: const Duration(milliseconds: 900),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, _) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: value,
                                  backgroundColor: Colors.grey[200],
                                  color: const Color(0xFF368983),
                                  minHeight: 12,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Acumulado: ${meta.acumulado.toStringAsFixed(0)} COP', style: const TextStyle(fontSize: 13)),
                              Text('Meta: ${meta.objetivo.toStringAsFixed(0)} COP', style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF368983),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (context) => Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: FormMetaAhorro(onSave: _agregarMeta),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Agregar Meta de Ahorro',
      ),
    );
  }
}
