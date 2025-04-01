import 'package:flutter/material.dart';
import 'pages/icon_user.dart'; // Importa el archivo del menú lateral
import 'pages/registro_pages.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Clave para controlar el Scaffold
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Asigna la clave al Scaffold
      appBar: AppBar(
        backgroundColor: const Color(0xFFBEC6A0),
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
              _scaffoldKey.currentState?.openEndDrawer(); // Abre el menú lateral
            },
          ),
        ],
      ),
      endDrawer: const UserMenu(), // Usa el widget del menú lateral
      body: Container(
        color: const Color(0xFF98D4AF),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(''),
              Text(
                '',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 130,
        height: 65,
        child: FloatingActionButton(
          backgroundColor: const Color(0xFFBEC6A0),
          onPressed: () {},
          tooltip: 'Increment',
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