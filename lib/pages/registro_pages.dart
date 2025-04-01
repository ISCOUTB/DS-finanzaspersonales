import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PageRegistro extends StatefulWidget {
  const PageRegistro({super.key});

  @override
  State<PageRegistro> createState() => _PageRegistroState();
}

// jorge
// comentario nuevo
class _PageRegistroState extends State<PageRegistro> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                Color(0xFFEEF1DA),
                Color(0xFFD5E5D5),
                Color(0xFF6A9C89),
                Color(0xFF1F7D53),
                Color(0xFF255F38),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    //logo
                    Icon(
                      Icons.account_circle, 
                      size: 200, 
                      color: const Color(0xFF255F38)
                      ),
                    const SizedBox(width: 20),
                    
                    //hello
                    Text(
                      'Hola de nuevo',
                      style: GoogleFonts.bebasNeue(
                        fontSize: 48,
                        color: const Color(0xFF255F38),
                      ), 
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Bienvenido de vuelta',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(width: 20),
                      
                    // Email TextField
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Container(
                        width: 300, // Ajusta el ancho según necesites
                        height: 50, // Ajusta la altura según necesites
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F7D53),
                          border: Border.all(
                            color: Colors.white,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: TextField(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Correo electrónico',
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                      
                      
                    //password textfield
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Container(
                        width: 300, // Ajusta el ancho según necesites
                        height: 50, // Ajusta la altura según necesites
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F7D53),
                          border: Border.all(
                            color: Colors.white,
                            ),
                          borderRadius: BorderRadius.circular(15)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: TextField(
                            obscureText: true,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Contraseña',
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                      
                      
                    //sign in button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: SizedBox(
                        width: 300, // Ajusta el ancho del botón
                        height: 50, // Ajusta la altura del botón
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0E5A33), // Color de fondo
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/home');
                          },
                          child: const Text(
                            'Iniciar sesión',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                      
                      
                    //not remember password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: const [
                        Text(
                          '¿Aún no tiene una cuenta?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF255F38),
                          ),
                        ),
                        Text(
                          'Regístrate aquí',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.greenAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
      ),
    );
  }
}