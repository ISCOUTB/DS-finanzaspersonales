import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/pages/user_page.dart';
import '../lib/widgets/profile_avatar.dart';

void main() {
  testWidgets('UserProfilePage muestra nombre, avatar y botones principales', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: UserProfilePage(),
      ),
    );
    // Verifica que el nombre de usuario por defecto esté
    expect(find.text('Usuario'), findsOneWidget);
    // Verifica que el avatar esté presente
    expect(find.byType(ProfileAvatar), findsOneWidget);
    // Verifica que los botones estén presentes
    expect(find.text('Editar Perfil'), findsOneWidget);
    expect(find.text('Eliminar Información de la Cuenta'), findsOneWidget);
    expect(find.text('Modo oscuro'), findsOneWidget);
  });

  testWidgets('UserProfilePage abre diálogo de editar nombre', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: UserProfilePage(),
      ),
    );
    await tester.tap(find.text('Editar Perfil'));
    await tester.pumpAndSettle();
    // Verifica que el diálogo de editar nombre aparece
    expect(find.text('Editar Nombre'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Guardar'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
  });

  testWidgets('UserProfilePage abre diálogo de eliminar cuenta', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: UserProfilePage(),
      ),
    );
    await tester.tap(find.text('Eliminar Información de la Cuenta'));
    await tester.pumpAndSettle();
    // Verifica que el diálogo de confirmación aparece
    expect(find.text('Confirmar Eliminación'), findsOneWidget);
    expect(find.textContaining('¿Estás seguro'), findsOneWidget);
    expect(find.text('Eliminar'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
  });

  testWidgets('UserProfilePage muestra y cambia el switch de modo oscuro', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.light,
        home: UserProfilePage(),
      ),
    );
    final switchFinder = find.byType(Switch);
    expect(switchFinder, findsOneWidget);
    // Cambia el switch
    await tester.tap(switchFinder);
    await tester.pump();
  });
}
