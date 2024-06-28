import 'package:flutter/material.dart';
import 'package:raymisa/views/Procesos.dart';
import 'package:raymisa/views/reporte.dart'; // Asegúrate de que esta ruta sea correcta
import 'package:raymisa/views/materia_prima.dart'; // Asegúrate de que esta ruta sea correcta

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: const Text('Inventario'),
    ),
    body: ListView(
    padding: const EdgeInsets.all(16.0),
    children: [
    Card(
    child: ListTile(
    title: const Text('Procesos'),
    trailing: const Icon(Icons.arrow_forward),
    onTap: () {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const ProcesoPage()),
    );
    },
    ),
    ),
    Card(
    child: ListTile(
    title: const Text('Materia Prima'),
    trailing: const Icon(Icons.arrow_forward),
    onTap: () {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const MateriaPrimaPage()),
    );
    },
    ),
    ),
    ],
    ),
    );
  }
}
