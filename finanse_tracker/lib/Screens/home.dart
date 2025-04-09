import 'package:flutter/material.dart';
import 'statistics.dart'; // Asegúrate de importar tu pantalla

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pantalla Principal')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Statistics()),
            );
          },
          child: Text('Ir a Estadísticas'),
        ),
      ),
    );
  }
}
