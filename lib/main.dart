import 'package:flutter/material.dart';
import 'pages/icon_user.dart';
import 'pages/registro_pages.dart';
import 'pages/TransferHistory.dart';
//import 'pages/principal_pages.dart';
import 'pages/principal_pages2.dart';  
import 'pages/statistics.dart';
import 'pages/form_ingresos.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finanzas Personales',
      initialRoute: '/login',
      routes: {
        '/login': (context) => const PageRegistro(),
        '/home': (context) => const MyHomePage(title: 'Flutter Demo Home Page'),
      },
      theme: ThemeData(
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF708871),
          selectedItemColor: Color(0xFFBEC6A0),
          unselectedItemColor: Colors.white,
        ),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  // Lista de páginas para el cuerpo dinámico
  final List<Widget> _pages = [
    const PrincipalPage(), // Página principal
    Statistics(), // Página de estadísticas
    const Transferhistory(), // Página de registros (TransferHistory)
    Center(child: Text('Más opciones')), // Página de más opciones
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Cambia el índice seleccionado
    });
  }

  // Agrega esta función dentro de la clase _MyHomePageState
// Agrega esta función dentro de la clase _MyHomePageState
void _showTransactionDialog() {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return Container(
        height: 280,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Botón de Gastos
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3D59),
                minimumSize: const Size(double.infinity, 70),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () {
                // Aquí irá la lógica para agregar gastos
                Navigator.pop(context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const [
                  Icon(Icons.trending_down, color: Colors.red, size: 30),
                  SizedBox(width: 20),
                  Text(
                    'Gastos',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Botón de Ingresos
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3D59),
                minimumSize: const Size(double.infinity, 70),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () {
                Navigator.pop(context); // Cierra el modal
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FormIngresos(),
                  ),
                ).then((transaccion) {
                  // Aquí puedes manejar la transacción creada
                  if (transaccion != null) {
                    // Implementa la lógica para guardar la transacción
                    print('Nueva transacción creada: ${transaccion.descripcion}');
                  }
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const [
                  Icon(Icons.trending_up, color: Colors.green, size: 30),
                  SizedBox(width: 20),
                  Text(
                    'Ingresos',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Fila de botones circulares
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF1E3D59),
                  child: IconButton(
                    icon: const Icon(Icons.account_balance, color: Colors.white),
                    onPressed: () {
                      // Aquí irá la lógica para transferencias bancarias
                      Navigator.pop(context);
                    },
                  ),
                ),
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          color: const Color(0xFF708871),
          onPressed: () {},
        ),
        title: const Text(
          'Finanse Tracker',
          style: TextStyle(color: Color(0xFF708871)),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            color: const Color(0xFF708871),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      endDrawer: const UserMenu(),
      body: IndexedStack(
        index: _selectedIndex, // Muestra la página correspondiente al índice seleccionado
        children: _pages,
      ),
      floatingActionButton: SizedBox(
        width: 130,
        height: 65,
        child: FloatingActionButton(
          backgroundColor: const Color(0xFFBEC6A0),
          onPressed: _showTransactionDialog,
          tooltip: '',
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(Icons.add, color: Color(0xFF708871), size: 40),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 59, 145, 103),
        selectedItemColor: const Color.fromARGB(255, 59, 145, 103),
        unselectedItemColor: const Color(0xFFBEC6A0),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Principal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Estadísticas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Registros',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'Más',
          ),
        ],
      ),
    );
  }
}