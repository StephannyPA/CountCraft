import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

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
                  var idPrenda = prenda['id'] ?? uuid.v4();
                  prenda['id'] = idPrenda;
                  var tipoPrenda = prenda['tipo'] as String;
                  var modeloPrenda = prenda['modelo'] as String;
                  var estado = prenda['estado'] ?? 'azul';

                  return ListTile(
                    title: Text('$tipoPrenda - $modeloPrenda'),
                    onTap: estado == 'verde' ? null : () async {
                      var nuevoEstado = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FormularioDetallePrenda(modeloPrenda)),
                      );
                      if (nuevoEstado != null) {
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
  List<String> procesos = [];
  List<String> colores = [];
  String? _selectedProceso;
  String? _selectedColor;
  List<String> _procesosSeleccionados = [];
  List<String> _coloresSeleccionados = [];

  @override
  void initState() {
    super.initState();
    _fetchProcesos();
    _fetchColores();
  }

  void _fetchProcesos() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Proceso').get();
    setState(() {
      procesos = querySnapshot.docs.map((doc) => doc['nombre'] as String).toList();
    });
  }

  void _fetchColores() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Materia').get();
      setState(() {
        colores = querySnapshot.docs.map((doc) => doc['nombre'] as String).toList();
        print('Colores obtenidos: $colores'); // Debug: Verificar los colores obtenidos
      });
    } catch (e) {
      print('Error al obtener colores: $e'); // Debug: Verificar si hay algún error
    }
  }

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
                  'assets/images/default_image.png',
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
                      Navigator.of(context).pop('amarillo');
                    },
                    child: Text('Cancelar'),
                  ),
                  SizedBox(width: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.of(context).pop('verde');
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
              _procesosSeleccionados.add(value!);
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
              _coloresSeleccionados.add(value!);
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
