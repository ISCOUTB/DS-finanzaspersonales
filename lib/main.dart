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

  static _MyAppState? of(BuildContext context) => context.findAncestorStateOfType<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final darkMode = prefs.getBool('darkMode');
    if (darkMode != null) {
      setState(() {
        _themeMode = darkMode ? ThemeMode.dark : ThemeMode.light;
      });
    }
  }

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
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF075E54),
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        cardColor: Colors.grey[200],
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121B22),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF202C33),
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        cardColor: Color(0xFF232D36),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF232D36),
          selectedItemColor: Color(0xFF25D366),
          unselectedItemColor: Color(0xFFB0B0B0),
        ),
        colorScheme: ColorScheme.dark(
          primary: Color(0xFF25D366),
          secondary: Color(0xFF075E54),
        ),
      ),
      themeMode: _themeMode,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorSelected = isDark ? const Color(0xFF25D366) : const Color(0xFF368983);
    final colorUnselected = isDark ? const Color(0xFF232D36) : const Color(0xFFE8F5E9);
    final colorIconSelected = Colors.white;
    final colorIconUnselected = isDark ? const Color(0xFF25D366) : const Color(0xFF368983);
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121B22) : Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
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
                    color: selected ? colorSelected : colorUnselected,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: colorSelected.withOpacity(0.18),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        items[i]['icon'] as IconData,
                        color: selected ? colorIconSelected : colorIconUnselected,
                        size: 28,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        items[i]['label'] as String,
                        style: TextStyle(
                          color: selected ? colorIconSelected : colorIconUnselected,
                          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 14,
                          letterSpacing: 0.2,
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
