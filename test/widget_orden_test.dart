import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raymisa/views/orden.dart';

void main() {
  testWidgets('Test básico de Orden widget', (WidgetTester tester) async {
    // Cargar el widget
    await tester.pumpWidget(
      MaterialApp(
        home: Orden(),
      ),
    );

    // Verifica que el AppBar tenga el texto correcto
    expect(find.widgetWithText(AppBar, 'Generar Orden'), findsOneWidget);

    // Verifica que el campo de entrada para nombre del cliente esté presente
    expect(find.byType(TextFormField), findsWidgets);

    // Verifica que el campo de entrada para fecha esté presente
    expect(find.byType(IconButton), findsOneWidget);

    // Verifica que el campo de entrada para nombre de la colección esté presente
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);

    // Verifica que el botón de generar orden esté presente
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
