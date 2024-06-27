import 'package:flutter/material.dart';

class Material {
  String nombre;
  double costo;

  Material({required this.nombre, required this.costo});
}

class MateriaPrimaPage extends StatefulWidget {
  const MateriaPrimaPage({super.key});

  @override
  _MateriaPrimaPageState createState() => _MateriaPrimaPageState();
}

class _MateriaPrimaPageState extends State<MateriaPrimaPage> {
  List<Material> materiales = [
    Material(nombre: 'Hilo Rojo', costo: 2.50),
    Material(nombre: 'Hilo Azul', costo: 3.00),
    Material(nombre: 'Hilo Verde', costo: 2.75),
  ];

  final _nombreController = TextEditingController();
  final _costoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _agregarMaterial() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        materiales.add(Material(
          nombre: _nombreController.text,
          costo: double.parse(_costoController.text),
        ));
      });
      _nombreController.clear();
      _costoController.clear();
      Navigator.of(context).pop();
    }
  }

  void _mostrarFormularioAgregarMaterial() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Nuevo Material'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre del Material'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el nombre del material';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _costoController,
                decoration: const InputDecoration(labelText: 'Costo'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el costo';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor, ingrese un costo válido';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: _agregarMaterial,
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Materia Prima'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: materiales.length,
                itemBuilder: (context, index) {
                  final material = materiales[index];
                  return Card(
                    child: ListTile(
                      title: Text(material.nombre),
                      subtitle: Text('Costo: \$${material.costo.toStringAsFixed(2)}'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _mostrarFormularioAgregarMaterial,
              child: const Text('Agregar Nuevo Material'),
            ),
          ],
        ),
      ),
    );
  }
}
