import 'package:flutter/material.dart';
import 'categorias_pages.dart';
import 'presupuestos_categoria_page.dart' as presupuestos;

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Drawer(
      child: Container(
        color: isDark ? const Color(0xFF121B22) : Colors.white,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 50),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF202C33) : const Color.fromARGB(225, 47, 125, 121),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.category,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 10),
                  const Text(
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
                  color: isDark ? const Color(0xFF232D36) : const Color.fromARGB(225, 47, 125, 121).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.arrow_upward,
                  color: isDark ? const Color(0xFF25D366) : const Color.fromARGB(225, 47, 125, 121),
                ),
              ),
              title: const Text(
                'Gestionar Categorías',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CategoriasPage()),
                );
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF232D36) : const Color.fromARGB(225, 47, 125, 121).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.savings,
                  color: isDark ? const Color(0xFF25D366) : const Color.fromARGB(225, 47, 125, 121),
                ),
              ),
              title: const Text(
                'Metas de Ahorro',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/metas-ahorro');
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF232D36) : const Color.fromARGB(225, 47, 125, 121).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.pie_chart,
                  color: isDark ? const Color(0xFF25D366) : const Color.fromARGB(225, 47, 125, 121),
                ),
              ),
              title: const Text(
                'Presupuestos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const presupuestos.PresupuestosPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}