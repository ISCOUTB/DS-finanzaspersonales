import 'package:flutter/material.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 50),
              decoration: const BoxDecoration(
                color: Color.fromARGB(225, 47, 125, 121),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.category,
                    size: 80,
                    color: Colors.white,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Categorías",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(225, 47, 125, 121).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_upward,
                  color: Color.fromARGB(225, 47, 125, 121),
                ),
              ),
              title: const Text(
                'Categorías de Ingresos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                // Aquí irá la navegación a la página de categorías de ingresos
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(225, 47, 125, 121).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_downward,
                  color: Color.fromARGB(225, 47, 125, 121),
                ),
              ),
              title: const Text(
                'Categorías de Gastos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                // Aquí irá la navegación a la página de categorías de gastos
              },
            ),
          ],
        ),
      ),
    );
  }
}