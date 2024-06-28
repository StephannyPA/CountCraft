import 'package:flutter/material.dart';

class Proceso {
  String nombre;
  double costo;

  Proceso({required this.nombre, required this.costo});
}

class ProcesoPage extends StatefulWidget {
  const ProcesoPage({super.key});

  @override
  _ProcesoPageState createState() => _ProcesoPageState();
}

class _ProcesoPageState extends State<ProcesoPage> {
  List<Proceso> procesos = [
    Proceso(nombre: 'Corte', costo: 10.00),
    Proceso(nombre: 'Confección', costo: 20.00),
    Proceso(nombre: 'Plancha', costo: 5.00),
  ];

  final _nombreController = TextEditingController();
  final _costoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _agregarProceso() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        procesos.add(Proceso(
          nombre: _nombreController.text,
          costo: double.parse(_costoController.text),
        ));
      });
      _nombreController.clear();
      _costoController.clear();
      Navigator.of(context).pop();
    }
  }

  void _mostrarFormularioAgregarProceso() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar Nuevo Proceso'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre del Proceso'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el nombre del proceso';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _costoController,
                decoration: InputDecoration(labelText: 'Costo'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
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
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: _agregarProceso,
            child: Text('Agregar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Proceso'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: procesos.length,
                itemBuilder: (context, index) {
                  final proceso = procesos[index];
                  return Card(
                    child: ListTile(
                      title: Text(proceso.nombre),
                      subtitle: Text('Costo: \$${proceso.costo.toStringAsFixed(2)}'),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _mostrarFormularioAgregarProceso,
              child: Text('Agregar Nuevo Proceso'),
            ),
          ],
        ),
      ),
    );
  }
}
