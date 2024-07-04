import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart'; // Para generar identificadores únicos

class MuestraOrdenes extends StatefulWidget {
  const MuestraOrdenes({Key? key}) : super(key: key);

  @override
  _MuestraOrdenesState createState() => _MuestraOrdenesState();
}

class _MuestraOrdenesState extends State<MuestraOrdenes> {
  final Uuid uuid = Uuid();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Muestra de Órdenes'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Orden').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          var ordenes = snapshot.data!.docs;
          // Filtrar las órdenes que no están completadas
          var ordenesFiltradas = ordenes.where((orden) {
            var prendas = orden['Prendas'] as List;
            return prendas.any((prenda) => prenda['estado'] != 'verde');
          }).toList();

          return ListView.builder(
            itemCount: ordenesFiltradas.length,
            itemBuilder: (context, index) {
              var orden = ordenesFiltradas[index];
              var coleccion = orden['Coleccion'];
              var prendas = orden['Prendas'] as List;

              return ExpansionTile(
                title: Card(
                  elevation: 3.0,
                  margin: EdgeInsets.all(10.0),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      '$coleccion',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                children: prendas.map<Widget>((prenda) {
                  // Asegurarse de que cada prenda tenga un identificador único
                  var idPrenda = prenda['id'] ?? uuid.v4();
                  prenda['id'] = idPrenda;
                  var tipoPrenda = prenda['tipo'] as String;
                  var modeloPrenda = prenda['modelo'] as String;
                  var estado = prenda['estado'] ?? 'azul'; // Estado inicial azul si no está definido

                  return ListTile(
                    title: Text('$tipoPrenda - $modeloPrenda'),
                    onTap: estado == 'verde' ? null : () async {
                      var nuevoEstado = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FormularioDetallePrenda(modeloPrenda)),
                      );
                      if (nuevoEstado != null) {
                        // Actualizar estado en Firestore
                        FirebaseFirestore.instance
                            .collection('Orden')
                            .doc(orden.id)
                            .update({
                          'Prendas': prendas.map((p) {
                            if (p['id'] == idPrenda) {
                              return {
                                ...p,
                                'estado': nuevoEstado,
                              };
                            }
                            return p;
                          }).toList(),
                        }).then((value) {
                          print("Estado actualizado en Firestore");
                        }).catchError((error) => print("Error al actualizar estado: $error"));

                        // Actualizar estado local solo si se guarda correctamente en Firestore
                        setState(() {
                          prenda['estado'] = nuevoEstado;
                        });
                      }
                    },
                    trailing: _buildIconoCheck(estado),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildIconoCheck(String estado) {
    switch (estado) {
      case 'azul':
        return Icon(Icons.check_circle, color: Colors.blue);
      case 'amarillo':
        return Icon(Icons.check_circle, color: Colors.yellow);
      case 'verde':
        return Icon(Icons.check_circle, color: Colors.green);
      default:
        return Icon(Icons.check_circle, color: Colors.blue);
    }
  }
}

class FormularioDetallePrenda extends StatefulWidget {
  final String modeloPrenda;

  FormularioDetallePrenda(this.modeloPrenda);

  @override
  _FormularioDetallePrendaState createState() => _FormularioDetallePrendaState();
}

class _FormularioDetallePrendaState extends State<FormularioDetallePrenda> {
  final _formKey = GlobalKey<FormState>();
  List<String> procesos = ['Bordado', 'Estampado', 'Teñido']; // Opciones de procesos
  List<String> colores = ['Rojo', 'Azul', 'Verde', 'Negro']; // Opciones de colores
  String? _selectedProceso; // Variable para almacenar el proceso seleccionado
  String? _selectedColor; // Variable para almacenar el color seleccionado
  List<String> _procesosSeleccionados = []; // Lista de procesos seleccionados
  List<String> _coloresSeleccionados = []; // Lista de colores seleccionados

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de Prenda - ${widget.modeloPrenda}'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ingrese los detalles de la prenda:',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 20.0),
              Center(
                child: Image.asset(
                  'assets/images/default_image.png', // Imagen por defecto
                  width: 200,
                  height: 200,
                ),
              ),
              SizedBox(height: 20.0),
              _buildProcesoSelector(),
              SizedBox(height: 10.0),
              _buildSelectedProcesoChips(),
              SizedBox(height: 20.0),
              _buildColorSelector(),
              SizedBox(height: 10.0),
              _buildSelectedColorChips(),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop('amarillo'); // Cancelar y regresar, estado amarillo
                    },
                    child: Text('Cancelar'),
                  ),
                  SizedBox(width: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Validar formulario
                        Navigator.of(context).pop('verde'); // Guardar y regresar, estado verde
                      }
                    },
                    child: Text('Guardar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProcesoSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _selectedProceso,
          hint: Text('Seleccionar proceso'),
          items: procesos.map((proceso) {
            return DropdownMenuItem(
              value: proceso,
              child: Text(proceso),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedProceso = value;
              _procesosSeleccionados.add(value!); // Agregar sin verificar duplicados
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Seleccione un proceso';
            }
            return null;
          },
        ),
        SizedBox(height: 10.0),
      ],
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _selectedColor,
          hint: Text('Seleccionar color'),
          items: colores.map((color) {
            return DropdownMenuItem(
              value: color,
              child: Text(color),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedColor = value;
              _coloresSeleccionados.add(value!); // Agregar sin verificar duplicados
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Seleccione un color';
            }
            return null;
          },
        ),
        SizedBox(height: 10.0),
      ],
    );
  }

  Widget _buildSelectedProcesoChips() {
    return Wrap(
      spacing: 8.0,
      children: _procesosSeleccionados.map((proceso) => Chip(label: Text(proceso))).toList(),
    );
  }

  Widget _buildSelectedColorChips() {
    return Wrap(
      spacing: 8.0,
      children: _coloresSeleccionados.map((color) => Chip(label: Text(color))).toList(),
    );
  }
}
