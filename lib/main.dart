import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/side_menu.dart';
import 'pages/registro_pages.dart';
import 'pages/transfer_history.dart';
import 'pages/principal_pages.dart';
import 'pages/estadisticas.dart';
import 'Servicios/database_helper.dart';
import 'pages/user_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().database;

  final prefs = await SharedPreferences.getInstance();
  final hasUser = prefs.getString('userName') != null; //mirar si existe un usuario registrado

  runApp(MyApp(initialRoute: hasUser ? '/home' : '/login'));
}

class MyApp extends StatefulWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finanzas Personales',
      debugShowCheckedModeBanner: false,
      initialRoute: widget.initialRoute,
      routes: {
        '/login': (context) => const PageRegistro(),
        '/home': (context) => MyHomePage(title: 'Finanse Tracker',),
      },
      theme: ThemeData(
        brightness: Brightness.light,
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
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<PrincipalPageState> _principalKey = PrincipalPage.globalKey;
  final GlobalKey<EstadisticasPageState> _estadisticasKey = EstadisticasPage.globalKey;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedIndex = 0;

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return PrincipalPage(key: GlobalKey<PrincipalPageState>());
      case 1:
        return EstadisticasPage(key: GlobalKey<EstadisticasPageState>());
      case 2:
        return const Transferhistory();
      default:
        return PrincipalPage(key: GlobalKey<PrincipalPageState>());
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      EstadisticasPage.globalKey.currentState?.cargarDatos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          color: Theme.of(context).iconTheme.color,
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Text(
          widget.title,
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            color: Theme.of(context).iconTheme.color,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserProfilePage(),
                ),
              ).then((_) {
                setState(() {});
              });
            },
          ),
        ],
      ),
      drawer: const SideMenu(),
      endDrawer: const SideMenu(),
      body: _getPage(_selectedIndex), // <-- Cambia aquí para reconstruir la página al cambiar de índice
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF368983),
        selectedItemColor: const Color(0xFFBEC6A0),
        unselectedItemColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Principal'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Estadísticas'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Registros'),
        ],
      ),
    );
  }
}
