import 'package:flutter/material.dart';
import 'package:raymisa/widgets/login.dart';

class ConnectionStatusPage extends StatelessWidget {
  final bool isConnected;

  const ConnectionStatusPage({super.key, required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection Status'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              isConnected
                  ? 'Conexión establecida correctamente'
                  : 'No se pudo establecer la conexión',
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text('Volver al inicio de sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
