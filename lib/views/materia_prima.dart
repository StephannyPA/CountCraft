import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raymisa/views/reporte.dart';

class Material {
  String nombre;
  double costo;

  Material({required this.nombre, required this.costo});
}

class MateriaPrimaPage extends StatefulWidget {
  const MateriaPrimaPage({Key? key}) : super(key: key);

  @override
  _MateriaPrimaPageState createState() => _MateriaPrimaPageState();
}

class _MateriaPrimaPageState extends State<MateriaPrimaPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Material> materiales = [];

  final _nombreController = TextEditingController();
  final _costoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _cargarMateriales();
  }

  void _cargarMateriales() {
    _firestore.collection('Materia').get().then((querySnapshot) {
      setState(() {
        materiales = querySnapshot.docs.map((doc) {
          return Material(
            nombre: doc['nombre'],
            costo: doc['costo'],
          );
        }).toList();
      });
    });
  }

  void _agregarMaterial() {
    if (_formKey.currentState!.validate()) {
      var nuevoMaterial = Material(
        nombre: _nombreController.text,
        costo: double.parse(_costoController.text),
      );

      _firestore.collection('Materia').add({
        'nombre': nuevoMaterial.nombre,
        'costo': nuevoMaterial.costo,
      }).then((value) {
        setState(() {
          materiales.add(nuevoMaterial);
        });
        _nombreController.clear();
        _costoController.clear();
        Navigator.of(context).pop(); // Cerrar diálogo
      }).catchError((error) {
        print("Error al agregar material: $error");
        // Mostrar mensaje de error al usuario o manejar de otra manera
      });
    }
  }

  void _mostrarFormularioAgregarMaterial() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar Nuevo Material'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre del Material'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el nombre del material';
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
            onPressed: _agregarMaterial,
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
        title: Text('Materia Prima'),
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
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _mostrarFormularioAgregarMaterial,
              child: Text('Agregar Nuevo Material'),
            ),
          ],
        ),
      ),
    );
  }
}
