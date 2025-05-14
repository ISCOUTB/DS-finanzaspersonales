import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/side_menu.dart';
import 'pages/registro_pages.dart';
import 'pages/transfer_history.dart';
import 'pages/principal_pages.dart';
import 'pages/estadisticas.dart';
//import 'prueba/stats.dart';
import 'Servicios/database_helper.dart';
import 'pages/user_page.dart';


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
    EstadisticasPage(),
    Transferhistory(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Cambia el índice seleccionado
    });
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserProfilePage(),
                ),
              );
            },
          ),
        ],
      ),
      drawer: const SideMenu(),
      endDrawer: const SideMenu(),
      body: IndexedStack(
        index:
            _selectedIndex, // Muestra la página correspondiente al índice seleccionado
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(225, 47, 125, 121),
        selectedItemColor: const Color.fromARGB(255, 246, 253, 250),
        unselectedItemColor: const Color.fromARGB(145, 243, 245, 244),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Principal'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Estadísticas',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Registros'),
        ],
      ),
    );
  }
}
