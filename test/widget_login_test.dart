import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raymisa/widgets/login.dart';

void main() {
  testWidgets('Prueba de la Página de Login', (WidgetTester tester) async {
    // Construir la aplicación
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    // Verificar los elementos de la interfaz inicial
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Correo'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);

    // Ingresar correo y contraseña
    await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');

    // Tocar el botón de login
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(); // Reconstruir el widget después de que el estado ha cambiado

    // Verificar el estado de conexión
    expect(find.text('Conectado correctamente'), findsNothing); // Cambiar según tu lógica de conexión

    // Simular éxito de conexión y login
    // Aquí deberías simular el comportamiento de FirebaseAuth
  });
}

