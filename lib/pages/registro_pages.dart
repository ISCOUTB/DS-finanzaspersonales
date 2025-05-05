import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PageRegistro extends StatefulWidget {
  const PageRegistro({super.key});

  @override
  State<PageRegistro> createState() => _PageRegistroState();
}

class _PageRegistroState extends State<PageRegistro> {
  final _nameController = TextEditingController();
  bool _canContinue = false;

  @override
  void initState() {
    super.initState();
    // Añadir listener para detectar cambios en el texto
    _nameController.addListener(() {
      setState(() {
        _canContinue = _nameController.text.isNotEmpty;
      });
    });
  }

  Future<void> _saveNameAndNavigate() async {
    if (_nameController.text.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', _nameController.text);
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Imagen principal
                Center(
                  child: Image.asset(
                    'images/inicio.jpg',
                    height: 300,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Text('Error al cargar la imagen: $error');
                    },
                  ),
                ),
                const SizedBox(height: 40),
                // Título principal
                Text(
                  'Spend Smarter\nSave More',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(225, 47, 125, 121),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 40),
                // Solo el campo de nombre
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: '¿Cómo te llamas?',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: Color.fromARGB(225, 47, 125, 121),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Botón de siguiente
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _canContinue ? _saveNameAndNavigate : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(225, 47, 125, 121),
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Siguiente',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.removeListener(() {}); // Remover el listener
    _nameController.dispose();
    super.dispose();
  }
}
