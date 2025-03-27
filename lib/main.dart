import 'package:flutter/material.dart';
import 'pages/registro_pages.dart';
void main() {
  runApp(const MyApp());
}

// comentario jorge
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finanzas Personales',
      initialRoute: '/login',
      routes: {
        '/login': (context) => const PageRegistro(),
        //'/home': (context) => const HomePage(),
      },
      theme: ThemeData(
        // Configuración del tema global
        //colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF708871), // Color de fondo de la barra
          selectedItemColor: Color(0xFFBEC6A0), // Color del ítem seleccionado
          unselectedItemColor: Colors.white, // Color de los ítems no seleccionados
        ),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0; // Índice de la pestaña seleccionada

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Cambiar el índice seleccionado
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFBEC6A0), // Color de fondo de la barra
        leading: IconButton(
          icon: const Icon(Icons.menu), // Botón de navegación en la izquierda
          color: const Color(0xFF708871),
          onPressed: () {
            //print('Botón de navegación presionado');
          },
        ),
        title: const Text(
          'Finanse Tracker',
          style: TextStyle(color: Color(0xFF708871)),
        ),
        centerTitle: false, // Centrar el título
        actions: [
          IconButton(
            icon: const Icon(Icons.person), // Icono de persona en la derecha
            color: const Color(0xFF708871),
            onPressed: () {
              //print('Icono de persona presionado');
            },
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFF98D4AF), // Color de fondo personalizado
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
        width: 130, // Ancho personalizado
        height: 65, // Alto personalizado
        child: FloatingActionButton(
          backgroundColor: const Color(0xFFBEC6A0), // Color de fondo
          onPressed: (){},
          tooltip: 'Increment',
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // Esquinas redondeadas
          ),
          child: const Icon(Icons.add, color: Color(0xFF708871), size: 40), // Botón flotante con el icono de más (+)
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 59, 145, 103), // Color de fondo de la barra
        selectedItemColor: const Color.fromARGB(255, 59, 145, 103), // Color del ítem seleccionado
        unselectedItemColor: const Color(0xFFBEC6A0), // Color de los ítems no seleccionados
        currentIndex: _selectedIndex, // Índice del ítem seleccionado
        onTap: _onItemTapped, // Manejar el cambio de pestaña
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home), // Ícono de "Principal"
            label: 'Principal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart), // Ícono de "Estadísticas"
            label: 'Estadísticas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list), // Ícono de "Registros"
            label: 'Registros',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz), // Ícono de "Más"
            label: 'Más',
          ),
        ],
      ),
    );
  }
}