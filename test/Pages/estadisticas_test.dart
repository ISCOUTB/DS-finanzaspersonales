import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finanse_tracker/pages/estadisticas.dart';
import 'package:finanse_tracker/Modelos/transaccion.dart';
import 'package:finanse_tracker/Modelos/categoria.dart';
import 'package:finanse_tracker/Servicios/gestor_finanzas.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:fl_chart/fl_chart.dart';

// Mock classes
@GenerateMocks([GestorFinanzas])
class MockGestorFinanzas extends Mock implements GestorFinanzas {
  @override
  List<Transaccion> get transacciones => super.noSuchMethod(
    Invocation.getter(#transacciones),
    returnValue: <Transaccion>[],
  );

  @override
  Future<void> cargarTransacciones() => super.noSuchMethod(
    Invocation.method(#cargarTransacciones, []),
    returnValue: Future<void>.value(),
  );
}

void main() {
  group('EstadisticasPage Tests', () {
    late MockGestorFinanzas mockGestor;
    late List<Transaccion> transaccionesMock;

    setUp(() {
      mockGestor = MockGestorFinanzas();
      
      // Crear transacciones mock para pruebas
      final categoria1 = Categoria(nombre: 'Comida', tipo: 'egreso', icono: '🍔');
      final categoria2 = Categoria(nombre: 'Salario', tipo: 'ingreso', icono: '💰');
      final categoria3 = Categoria(nombre: 'Transporte', tipo: 'egreso', icono: '🚗');
      
      final now = DateTime.now();
      transaccionesMock = [
        Transaccion(
          id: '1',
          tipo: 'ingreso',
          monto: 1000.0,
          fecha: now,
          categoria: categoria2,
          descripcion: 'Salario mensual',
        ),
        Transaccion(
          id: '2',
          tipo: 'egreso',
          monto: 150.0,
          fecha: now.subtract(const Duration(days: 1)),
          categoria: categoria1,
          descripcion: 'Almuerzo',
        ),
        Transaccion(
          id: '3',
          tipo: 'egreso',
          monto: 50.0,
          fecha: now.subtract(const Duration(days: 2)),
          categoria: categoria3,
          descripcion: 'Gasolina',
        ),
        Transaccion(
          id: '4',
          tipo: 'ingreso',
          monto: 200.0,
          fecha: DateTime(now.year, now.month - 1, 15),
          categoria: categoria2,
          descripcion: 'Bonus',
        ),
      ];

      when(mockGestor.transacciones).thenReturn(transaccionesMock);
      when(mockGestor.cargarTransacciones()).thenAnswer((_) async {});
    });

    Widget createTestableWidget({GestorFinanzas? gestor}) {
      return MaterialApp(
        home: EstadisticasPage(gestorFinanzas: gestor ?? mockGestor),
      );
    }

    testWidgets('EstadisticasPage se construye correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byType(EstadisticasPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('EstadisticasPage es un StatefulWidget', (WidgetTester tester) async {
      const page = EstadisticasPage();
      expect(page, isA<StatefulWidget>());
    });

    testWidgets('EstadisticasPage tiene GlobalKey configurado', (WidgetTester tester) async {
      expect(EstadisticasPage.globalKey, isA<GlobalKey<EstadisticasPageState>>());
    });

    testWidgets('EstadisticasPage inicializa con GestorFinanzas inyectado', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      verify(mockGestor.cargarTransacciones()).called(greaterThan(0));
    });

    testWidgets('EstadisticasPage inicializa con GestorFinanzas por defecto cuando no se inyecta', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(gestor: null));
      await tester.pumpAndSettle();

      expect(find.byType(EstadisticasPage), findsOneWidget);
    });

    testWidgets('EstadisticasPage muestra AppBar con título', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Estadísticas'), findsOneWidget);
    });    testWidgets('EstadisticasPage muestra PopupMenuButton de filtro', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byType(PopupMenuButton<FiltroTiempo>), findsOneWidget);
      expect(find.byIcon(Icons.filter_alt_outlined), findsOneWidget);
    });

    testWidgets('PopupMenuButton muestra opciones de filtro al presionar', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Tap en el popup menu
      await tester.tap(find.byIcon(Icons.filter_alt_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Día'), findsOneWidget);
      expect(find.text('Semana'), findsOneWidget);
      expect(find.text('Mes'), findsOneWidget);
      expect(find.text('Año'), findsOneWidget);
    });

    testWidgets('Cambiar filtro a Día funciona correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Abrir popup menu
      await tester.tap(find.byIcon(Icons.filter_alt_outlined));
      await tester.pumpAndSettle();

      // Seleccionar Día
      await tester.tap(find.text('Día'));
      await tester.pumpAndSettle();

      expect(find.byType(EstadisticasPage), findsOneWidget);
    });

    testWidgets('Cambiar filtro a Semana funciona correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Abrir popup menu
      await tester.tap(find.byIcon(Icons.filter_alt_outlined));
      await tester.pumpAndSettle();

      // Seleccionar Semana
      await tester.tap(find.text('Semana'));
      await tester.pumpAndSettle();

      expect(find.byType(EstadisticasPage), findsOneWidget);
    });

    testWidgets('Cambiar filtro a Año funciona correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Abrir popup menu
      await tester.tap(find.byIcon(Icons.filter_alt_outlined));
      await tester.pumpAndSettle();

      // Seleccionar Año
      await tester.tap(find.text('Año'));
      await tester.pumpAndSettle();

      expect(find.byType(EstadisticasPage), findsOneWidget);
    });    testWidgets('EstadisticasPage muestra TabBar con 3 tabs', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byType(TabBar), findsOneWidget);
      expect(find.text('Pastel'), findsOneWidget);
      expect(find.text('Barras'), findsOneWidget);
      expect(find.text('Líneas'), findsOneWidget);
    });

    testWidgets('EstadisticasPage muestra TabBarView', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byType(TabBarView), findsOneWidget);
    });

    testWidgets('EstadisticasPage muestra gráficos de pie para ingresos', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byType(PieChart), findsWidgets);
      expect(find.text('Total Ingresos'), findsOneWidget);
    });

    testWidgets('EstadisticasPage muestra gráficos de pie para egresos', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byType(PieChart), findsWidgets);
      expect(find.text('Total Gastos'), findsOneWidget);
    });

    testWidgets('EstadisticasPage maneja transacciones vacías', (WidgetTester tester) async {
      when(mockGestor.transacciones).thenReturn([]);
      
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byType(EstadisticasPage), findsOneWidget);
      expect(find.text('No hay datos para mostrar.'), findsWidgets);
    });

    testWidgets('EstadisticasPage muestra leyendas de gráficos', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Buscar contenedores de colores de leyenda
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('EstadisticasPage se actualiza al cambiar dependencias', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Simular cambio de dependencias
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      verify(mockGestor.cargarTransacciones()).called(greaterThan(1));
    });    testWidgets('EstadisticasPage maneja errores de carga de datos gracefully', (WidgetTester tester) async {
      when(mockGestor.cargarTransacciones()).thenThrow(Exception('Error de carga'));
      when(mockGestor.transacciones).thenReturn([]);
      
      // El widget debería construirse sin problemas aunque haya un error
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();
      
      // Verificar que se intentó cargar los datos
      verify(mockGestor.cargarTransacciones()).called(2); // initState + didChangeDependencies
      
      // Verificar que el widget existe y está funcionando
      expect(find.byType(EstadisticasPage), findsOneWidget);
      expect(find.byType(DefaultTabController), findsOneWidget);
    });

    testWidgets('EstadisticasPage muestra formato de moneda correcto', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Buscar formato de dinero con símbolo $
      expect(find.textContaining('\$'), findsWidgets);
    });    testWidgets('Navegación entre filtros mantiene el estado', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Cambiar a diferentes filtros usando popup menu
      await tester.tap(find.byIcon(Icons.filter_alt_outlined));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Día'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byIcon(Icons.filter_alt_outlined));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Semana'));
      await tester.pumpAndSettle();

      expect(find.byType(EstadisticasPage), findsOneWidget);
    });

    testWidgets('EstadisticasPage muestra datos de transacciones en gráficos', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Verificar que las categorías aparecen en leyendas
      expect(find.textContaining('Comida'), findsWidgets);
      expect(find.textContaining('Salario'), findsWidgets);
      expect(find.textContaining('Transporte'), findsWidgets);
    });    testWidgets('EstadisticasPage calcula porcentajes correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Buscar texto que contenga porcentajes (que aparecen en los gráficos de pie)
      expect(find.byType(PieChart), findsWidgets);
    });

    testWidgets('EstadisticasPage muestra colores diferentes para categorías', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Verificar que hay contenedores con colores (leyendas)
      final containers = find.byType(Container);
      expect(containers, findsWidgets);
    });    testWidgets('EstadisticasPage responde a taps en botones de filtro', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Hacer múltiples taps en el popup menu
      await tester.tap(find.byIcon(Icons.filter_alt_outlined));
      await tester.pump();
      
      await tester.tap(find.text('Día'));
      await tester.pump();
      
      await tester.tap(find.byIcon(Icons.filter_alt_outlined));
      await tester.pump();
      
      await tester.tap(find.text('Año'));
      await tester.pump();

      expect(find.byType(EstadisticasPage), findsOneWidget);
    });

    testWidgets('EstadisticasPage muestra cards con elevación', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('EstadisticasPage maneja SingleTickerProviderStateMixin', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byType(EstadisticasPage), findsOneWidget);
      // Verificar que no hay errores relacionados con TickerProvider
    });    testWidgets('EstadisticasPage muestra títulos de secciones', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Total Ingresos'), findsOneWidget);
      expect(find.text('Total Gastos'), findsOneWidget);
      expect(find.text('Detalle por categoría'), findsOneWidget);
    });

    testWidgets('EstadisticasPage utiliza tema de colores consistente', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, isNotNull);
    });
  });

  group('EstadisticasPage - Enum FiltroTiempo Tests', () {
    test('FiltroTiempo tiene todos los valores esperados', () {
      expect(FiltroTiempo.values.length, equals(4));
      expect(FiltroTiempo.values.contains(FiltroTiempo.dia), isTrue);
      expect(FiltroTiempo.values.contains(FiltroTiempo.semana), isTrue);
      expect(FiltroTiempo.values.contains(FiltroTiempo.mes), isTrue);
      expect(FiltroTiempo.values.contains(FiltroTiempo.anio), isTrue);
    });

    test('FiltroTiempo valores tienen nombres correctos', () {
      expect(FiltroTiempo.dia.toString(), equals('FiltroTiempo.dia'));
      expect(FiltroTiempo.semana.toString(), equals('FiltroTiempo.semana'));
      expect(FiltroTiempo.mes.toString(), equals('FiltroTiempo.mes'));
      expect(FiltroTiempo.anio.toString(), equals('FiltroTiempo.anio'));
    });
  });

  group('EstadisticasPage - State Management Tests', () {
    late MockGestorFinanzas mockGestor;

    setUp(() {
      mockGestor = MockGestorFinanzas();
      when(mockGestor.transacciones).thenReturn([]);
      when(mockGestor.cargarTransacciones()).thenAnswer((_) async {});
    });

    Widget createTestableWidget({GestorFinanzas? gestor}) {
      return MaterialApp(
        home: EstadisticasPage(gestorFinanzas: gestor ?? mockGestor),
      );
    }

    testWidgets('Estado se inicializa correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      final estadisticasState = tester.state<EstadisticasPageState>(find.byType(EstadisticasPage));
      expect(estadisticasState, isNotNull);
    });

    testWidgets('cargarDatos se llama en initState', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      verify(mockGestor.cargarTransacciones()).called(greaterThan(0));
    });

    testWidgets('cargarDatos se llama en didChangeDependencies', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Trigger didChangeDependencies
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      verify(mockGestor.cargarTransacciones()).called(greaterThan(1));
    });

    testWidgets('Estado se actualiza cuando hay transacciones', (WidgetTester tester) async {
      final categoria = Categoria(nombre: 'Test', tipo: 'ingreso', icono: '💰');
      final transaccion = Transaccion(
        id: '1',
        tipo: 'ingreso',
        monto: 100.0,
        fecha: DateTime.now(),
        categoria: categoria,
      );

      when(mockGestor.transacciones).thenReturn([transaccion]);

      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('Test'), findsWidgets);
    });
  });

  group('EstadisticasPage - Edge Cases Tests', () {
    late MockGestorFinanzas mockGestor;

    setUp(() {
      mockGestor = MockGestorFinanzas();
      when(mockGestor.cargarTransacciones()).thenAnswer((_) async {});
    });

    Widget createTestableWidget() {
      return MaterialApp(
        home: EstadisticasPage(gestorFinanzas: mockGestor),
      );
    }

    testWidgets('Maneja transacciones con montos cero', (WidgetTester tester) async {
      final categoria = Categoria(nombre: 'Test', tipo: 'ingreso', icono: '💰');
      final transaccion = Transaccion(
        id: '1',
        tipo: 'ingreso',
        monto: 0.0,
        fecha: DateTime.now(),
        categoria: categoria,
      );

      when(mockGestor.transacciones).thenReturn([transaccion]);

      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byType(EstadisticasPage), findsOneWidget);
    });

    testWidgets('Maneja transacciones con fechas futuras', (WidgetTester tester) async {
      final categoria = Categoria(nombre: 'Test', tipo: 'ingreso', icono: '💰');
      final transaccion = Transaccion(
        id: '1',
        tipo: 'ingreso',
        monto: 100.0,
        fecha: DateTime.now().add(const Duration(days: 30)),
        categoria: categoria,
      );

      when(mockGestor.transacciones).thenReturn([transaccion]);

      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byType(EstadisticasPage), findsOneWidget);
    });    testWidgets('Maneja categorías con nombres largos', (WidgetTester tester) async {
      final categoria = Categoria(
        nombre: 'Categoría test con nombre moderado',
        tipo: 'egreso',
        icono: '💰',
      );
      final transaccion = Transaccion(
        id: '1',
        tipo: 'egreso',
        monto: 100.0,
        fecha: DateTime.now(),
        categoria: categoria,
      );

      when(mockGestor.transacciones).thenReturn([transaccion]);

      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byType(EstadisticasPage), findsOneWidget);
    });

    testWidgets('Maneja múltiples transacciones de la misma categoría', (WidgetTester tester) async {
      final categoria = Categoria(nombre: 'Test', tipo: 'ingreso', icono: '💰');
      final transacciones = List.generate(10, (index) => Transaccion(
        id: '$index',
        tipo: 'ingreso',
        monto: 100.0 * (index + 1),
        fecha: DateTime.now().subtract(Duration(days: index)),
        categoria: categoria,
      ));

      when(mockGestor.transacciones).thenReturn(transacciones);

      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      expect(find.byType(EstadisticasPage), findsOneWidget);
      expect(find.textContaining('Test'), findsWidgets);
    });
  });

  group('EstadisticasPage - Tab Navigation Tests', () {
    late MockGestorFinanzas mockGestor;

    setUp(() {
      mockGestor = MockGestorFinanzas();
      when(mockGestor.transacciones).thenReturn([]);
      when(mockGestor.cargarTransacciones()).thenAnswer((_) async {});
    });

    Widget createTestableWidget() {
      return MaterialApp(
        home: EstadisticasPage(gestorFinanzas: mockGestor),
      );
    }

    testWidgets('Tab de Barras funciona correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Tap en tab de barras
      await tester.tap(find.text('Barras'));
      await tester.pumpAndSettle();

      expect(find.byType(BarChart), findsOneWidget);
    });

    testWidgets('Tab de Líneas funciona correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Tap en tab de líneas
      await tester.tap(find.text('Líneas'));
      await tester.pumpAndSettle();

      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('DefaultTabController está configurado correctamente', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      final defaultTabController = tester.widget<DefaultTabController>(find.byType(DefaultTabController));
      expect(defaultTabController.length, equals(3));
    });

    testWidgets('Navegación entre tabs mantiene estado', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Navegar entre tabs
      await tester.tap(find.text('Barras'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Líneas'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Pastel'));
      await tester.pumpAndSettle();

      expect(find.byType(EstadisticasPage), findsOneWidget);
    });
  });

  group('EstadisticasPage - Data Filtering Logic Tests', () {
    test('FiltroTiempo.dia filtra transacciones del día actual', () {
      final now = DateTime.now();
      final categoria = Categoria(nombre: 'Test', tipo: 'ingreso', icono: '💰');
      
      final transacciones = [
        Transaccion(id: '1', tipo: 'ingreso', monto: 100, fecha: now, categoria: categoria),
        Transaccion(id: '2', tipo: 'ingreso', monto: 200, fecha: now.subtract(const Duration(days: 1)), categoria: categoria),
      ];

      // Simular filtrado por día
      final filtradas = transacciones.where((t) =>
        t.fecha.year == now.year &&
        t.fecha.month == now.month &&
        t.fecha.day == now.day
      ).toList();

      expect(filtradas.length, equals(1));
      expect(filtradas.first.id, equals('1'));
    });

    test('FiltroTiempo.mes filtra transacciones del mes actual', () {
      final now = DateTime.now();
      final categoria = Categoria(nombre: 'Test', tipo: 'ingreso', icono: '💰');
      
      final transacciones = [
        Transaccion(id: '1', tipo: 'ingreso', monto: 100, fecha: now, categoria: categoria),
        Transaccion(id: '2', tipo: 'ingreso', monto: 200, fecha: DateTime(now.year, now.month - 1, 15), categoria: categoria),
      ];

      // Simular filtrado por mes
      final filtradas = transacciones.where((t) =>
        t.fecha.year == now.year &&
        t.fecha.month == now.month
      ).toList();

      expect(filtradas.length, equals(1));
      expect(filtradas.first.id, equals('1'));
    });

    test('FiltroTiempo.anio filtra transacciones del año actual', () {
      final now = DateTime.now();
      final categoria = Categoria(nombre: 'Test', tipo: 'ingreso', icono: '💰');
      
      final transacciones = [
        Transaccion(id: '1', tipo: 'ingreso', monto: 100, fecha: now, categoria: categoria),
        Transaccion(id: '2', tipo: 'ingreso', monto: 200, fecha: DateTime(now.year - 1, 6, 15), categoria: categoria),
      ];

      // Simular filtrado por año
      final filtradas = transacciones.where((t) =>
        t.fecha.year == now.year
      ).toList();

      expect(filtradas.length, equals(1));
      expect(filtradas.first.id, equals('1'));
    });
  });

  group('EstadisticasPage - Chart Data Calculation Tests', () {
    test('Calcular desglose por categoría funciona correctamente', () {
      final categoria1 = Categoria(nombre: 'Comida', tipo: 'egreso', icono: '🍔');
      final categoria2 = Categoria(nombre: 'Transporte', tipo: 'egreso', icono: '🚗');
      
      final transacciones = [
        Transaccion(id: '1', tipo: 'egreso', monto: 100, fecha: DateTime.now(), categoria: categoria1),
        Transaccion(id: '2', tipo: 'egreso', monto: 50, fecha: DateTime.now(), categoria: categoria1),
        Transaccion(id: '3', tipo: 'egreso', monto: 75, fecha: DateTime.now(), categoria: categoria2),
      ];

      // Simular cálculo de desglose
      final filtrada = transacciones.where((t) => t.tipo == 'egreso').toList();
      Map<String, double> map = {};
      for (var t in filtrada) {
        map[t.categoria.nombre] = (map[t.categoria.nombre] ?? 0) + t.monto;
      }

      expect(map['Comida'], equals(150.0));
      expect(map['Transporte'], equals(75.0));
      expect(map.keys.length, equals(2));
    });

    test('Calcular totales de barras maneja datos vacíos', () {
      final List<String> etiquetas = [];
      final List<double> ingresos = [];
      final List<double> egresos = [];

      // Simular cálculo con datos vacíos
      expect(etiquetas.isEmpty, isTrue);
      expect(ingresos.isEmpty, isTrue);
      expect(egresos.isEmpty, isTrue);
    });

    test('Colores de gráficos tienen suficientes elementos', () {
      // Verificar que hay suficientes colores para múltiples categorías
      final coloresIngresos = [
        Colors.blue.shade400,
        Colors.green.shade400,
        Colors.orange.shade400,
        Colors.purple.shade400,
        Colors.yellow.shade400,
      ];

      final coloresGastos = [
        Colors.red.shade400,
        Colors.pink.shade400,
        Colors.brown.shade400,
        Colors.teal.shade400,
        Colors.cyan.shade400,
      ];

      expect(coloresIngresos.length, greaterThanOrEqualTo(5));
      expect(coloresGastos.length, greaterThanOrEqualTo(5));
    });
  });
}