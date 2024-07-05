import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Material {
  String nombre;
  double costo;

  Material({required this.nombre, required this.costo});
}

class MateriaPrimaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Materia Prima'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Materia').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          var materiales = snapshot.data!.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return Material(
              nombre: data['nombre'] ?? '',
              costo: (data['costo'] ?? 0.0).toDouble(),
            );
          }).toList();

          return Padding(
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
                  onPressed: () {
                    _mostrarFormularioAgregarMaterial(context);
                  },
                  child: Text('Agregar Nuevo Material'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _mostrarFormularioAgregarMaterial(BuildContext context) {
    final _nombreController = TextEditingController();
    final _costoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar Nuevo Material'),
        content: Form(
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
            onPressed: () {
              _agregarMaterial(context, _nombreController.text, _costoController.text);
            },
            child: Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _agregarMaterial(BuildContext context, String nombre, String costo) {
    if (nombre.isNotEmpty && costo.isNotEmpty) {
      double costoDouble = double.parse(costo);
      FirebaseFirestore.instance.collection('Materia').add({
        'nombre': nombre,
        'costo': costoDouble,
      }).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Material agregado correctamente')),
        );
        Navigator.of(context).pop();
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al agregar el material: $error')),
        );
      });
    }
  }
}
