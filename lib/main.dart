import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/side_menu.dart';
import 'pages/registro_pages.dart';
import 'pages/TransferHistory.dart';
//import 'pages/principal_pages.dart';
import 'pages/principal_pages2.dart';  
import 'pages/statistics.dart';
//import 'prueba/stats.dart';
import 'pages/form_ingresos.dart';
import 'pages/form_gastos.dart';
import 'Servicios/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().database;
  
  // Verificar si existe un usuario registrado
  final prefs = await SharedPreferences.getInstance();
  final hasUser = prefs.getString('userName') != null;

  runApp(MyApp(initialRoute: hasUser ? '/home' : '/login'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finanzas Personales',
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const PageRegistro(),
        '/home': (context) => const MyHomePage(title: 'Finanse Tracker'),
      },
      theme: ThemeData(
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF708871),
          selectedItemColor: Color(0xFFBEC6A0),
          unselectedItemColor: Colors.white,
        ),
      ),
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

  // Modifica la lista de páginas
  final List<Widget> _pages = [
    PrincipalPage(key: PrincipalPage.globalKey), // Usar la key global
    Statistics(),
    //Statistics(),
    Transferhistory(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Cambia el índice seleccionado
    });
  }

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
                  backgroundColor: const Color.fromARGB(225, 47, 125, 121),
                  minimumSize: const Size(double.infinity, 70),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FormGastos()),
                  );
                  if (result == true) {
                    // Actualizar usando la key global
                    PrincipalPage.globalKey.currentState?.cargarTransacciones();
                  }
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
                  backgroundColor: const Color.fromARGB(225, 47, 125, 121),
                  minimumSize: const Size(double.infinity, 70),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FormIngresos()),
                  );
                  if (result == true) {
                    // Actualizar usando la key global
                    PrincipalPage.globalKey.currentState?.cargarTransacciones();
                  }
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
                    backgroundColor: const Color.fromARGB(225, 47, 125, 121),
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
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
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
              
            },
          ),
        ],
      ),
      drawer: const SideMenu(),
      endDrawer: const SideMenu(),
      body: IndexedStack(
        index: _selectedIndex, // Muestra la página correspondiente al índice seleccionado
        children: _pages,
      ),
      floatingActionButton: SizedBox(
        width: 130,
        height: 65,
        child: FloatingActionButton(
          backgroundColor: const Color.fromARGB(225, 47, 125, 121),
          onPressed: _showTransactionDialog,
          tooltip: '',
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(Icons.add, color: Color.fromARGB(255, 246, 253, 250), size: 40),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(225, 47, 125, 121),
        selectedItemColor: const Color.fromARGB(255, 246, 253, 250),
        unselectedItemColor: const Color.fromARGB(145, 243, 245, 244),
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
        ],
      ),
    );
  }
}