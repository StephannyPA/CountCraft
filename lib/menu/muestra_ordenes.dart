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
              var coleccion = orden['Coleccion']?.toString() ?? '';
              var prendas = orden['Prendas'] as List;

              return ExpansionTile(
                title: Card(
                  elevation: 3.0,
                  margin: EdgeInsets.all(10.0),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      coleccion,
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                children: prendas.map<Widget>((prenda) {
                  var idPrenda = prenda['id'] ?? uuid.v4();
                  prenda['id'] = idPrenda;
                  var tipoPrenda = prenda['tipo']?.toString() ?? '';
                  var modeloPrenda = prenda['modelo']?.toString() ?? '';
                  var estado = prenda['estado']?.toString() ?? 'azul';
                  var tiempo = prenda['tiempo']?.toString() ?? '';
                  var costo = prenda['costo']?.toString() ?? '';

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
                                'tiempo': tiempo,
                                'costo': costo,
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
                    subtitle: Row(
                      children: [
                        if (tiempo.isNotEmpty) Chip(label: Text('Tiempo: $tiempo')),
                        if (costo.isNotEmpty) Chip(label: Text('Costo: $costo')),
                      ],
                    ),
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
//estados
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
      children: _procesosSeleccionados.map((proceso) {
        return GestureDetector(
          onTap: () => _showDialog(context, proceso),
          child: Chip(label: Text(proceso)),
        );
      }).toList(),
    );
  }

  Widget _buildSelectedColorChips() {
    return Wrap(
      spacing: 8.0,
      children: _coloresSeleccionados.map((color) {
        return GestureDetector(
          onTap: () => _showDialog(context, color),
          child: Chip(label: Text(color)),
        );
      }).toList(),
    );
  }

  void _showDialog(BuildContext context, String selectedValue) {
    final _formKeyDialog = GlobalKey<FormState>();
    TextEditingController tiempoController = TextEditingController();
    TextEditingController costoController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalles del proceso'),
          content: Form(
            key: _formKeyDialog,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Valor seleccionado: $selectedValue'),
                TextFormField(
                  controller: tiempoController,
                  decoration: InputDecoration(
                    labelText: 'Tiempo',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if ((value == null || value.isEmpty) &&
                        (costoController.text.isEmpty)) {
                      return 'Ingrese al menos un valor (tiempo o costo)';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: costoController,
                  decoration: InputDecoration(
                    labelText: 'Costo',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if ((value == null || value.isEmpty) &&
                        (tiempoController.text.isEmpty)) {
                      return 'Ingrese al menos un valor (tiempo o costo)';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (_formKeyDialog.currentState!.validate()) {
                  String tiempo = tiempoController.text;
                  String costo = costoController.text;

                  // Actualizar Firestore con los datos ingresados
                  await FirebaseFirestore.instance.collection('Detalles').add({
                    'procesoOColor': selectedValue,
                    'tiempo': tiempo,
                    'costo': costo,
                    'prenda': widget.modeloPrenda, // Agregar nombre de la prenda principal
                    'timestamp': FieldValue.serverTimestamp(),
                  });

                  Navigator.pop(context, {'tiempo': tiempo, 'costo': costo});
                }
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          if (_procesosSeleccionados.contains(selectedValue)) {
            _procesosSeleccionados.remove(selectedValue);
            _procesosSeleccionados.add('$selectedValue - Tiempo: ${value['tiempo']} - Costo: ${value['costo']}');
          } else if (_coloresSeleccionados.contains(selectedValue)) {
            _coloresSeleccionados.remove(selectedValue);
            _coloresSeleccionados.add('$selectedValue - Tiempo: ${value['tiempo']} - Costo: ${value['costo']}');
          }
        });
      }
    });
  }
}
