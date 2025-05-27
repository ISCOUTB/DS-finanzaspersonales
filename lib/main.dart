import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/side_menu.dart';
import 'pages/registro_pages.dart';
import 'pages/transfer_history.dart';
import 'pages/principal_pages.dart';
import 'pages/estadisticas.dart';
import 'Servicios/database_helper.dart';
import 'pages/user_page.dart';
import 'widgets/profile_avatar.dart';
import 'pages/metas_ahorro_page.dart';

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
        '/metas-ahorro': (context) => const MetasAhorroPage(),
      },
      theme: ThemeData(
        brightness: Brightness.light,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white, // Fondo blanco
          selectedItemColor: Color(0xFF368983), // Color principal para ítem seleccionado
          unselectedItemColor: Color(0xFFB0B0B0), // Gris para ítems no seleccionados
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

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  final GlobalKey<PrincipalPageState> _principalKey = PrincipalPage.globalKey;
  final GlobalKey<EstadisticasPageState> _estadisticasKey = EstadisticasPage.globalKey;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      PrincipalPage(key: _principalKey),
      EstadisticasPage(key: _estadisticasKey),
      Transferhistory(),
    ];
    // Escuchar cambios en transacciones y refrescar la UI
    transaccionesActualizadas.addListener(() {
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addObserver(this);
    // Forzar recarga de datos cada vez que se vuelve a esta pantalla
    _principalKey.currentState?.cargarTransacciones();
    _estadisticasKey.currentState?.cargarDatos();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {}); // Fuerza refresco del avatar al volver a la app
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
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ProfileAvatar(
              radius: 18,
              onTap: () {
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
          ),
        ],
      ),
      drawer: const SideMenu(),
      endDrawer: const SideMenu(),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: _FinanceBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class _FinanceBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  const _FinanceBottomNavBar({
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.home, 'label': 'Principal'},
      {'icon': Icons.bar_chart, 'label': 'Estadísticas'},
      {'icon': Icons.list, 'label': 'Registros'},
    ];
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final selected = selectedIndex == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => onItemTapped(i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Container(
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF368983)
                        : const Color(0xFFE8F5E9), // Verde muy claro para no seleccionados
                    borderRadius: BorderRadius.circular(22),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        items[i]['icon'] as IconData,
                        color: selected ? Colors.white : const Color(0xFF368983),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        items[i]['label'] as String,
                        style: TextStyle(
                          color: selected ? Colors.white : const Color(0xFF368983),
                          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
