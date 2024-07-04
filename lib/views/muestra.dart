import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Muestra extends StatefulWidget {
  const Muestra({Key? key}) : super(key: key);

  @override
  _MuestraState createState() => _MuestraState();
}

class _MuestraState extends State<Muestra> {
  Map<String, List<String>> seleccionPorColeccion = {};
  List<String> tiposPrenda = ['Camisa', 'Pantalón', 'Chaqueta', 'Falda'];
  List<String> coleccionesCompletadas = []; // Lista para almacenar colecciones completadas

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Colección de Prendas'),
        centerTitle: true,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('Orden').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final List<String> nombresColecciones = snapshot.data!.docs
              .map((doc) => doc['Coleccion'] as String)
              .toList();

          return ListView.builder(
            itemCount: nombresColecciones.length,
            padding: EdgeInsets.all(16.0),
            itemBuilder: (context, index) {
              String coleccion = nombresColecciones[index];
              if (coleccionesCompletadas.contains(coleccion)) {
                return Container(); // Si la colección está completada, no mostrar el Card
              }
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetalleColeccion(
                        coleccion: coleccion,
                        seleccionPorColeccion: seleccionPorColeccion,
                        tiposPrenda: tiposPrenda,
                        onSeleccionesCambiadas: (List<String> seleccion) {
                          setState(() {
                            seleccionPorColeccion[coleccion] = seleccion;
                          });
                        },
                        onCompletarColeccion: () {
                          setState(() {
                            coleccionesCompletadas.add(coleccion); // Agregar la colección a la lista de completadas
                          });
                        },
                      ),
                    ),
                  );
                },
                child: Card(
                  elevation: 3.0,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      coleccion,
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class DetalleColeccion extends StatefulWidget {
  final String coleccion;
  final Map<String, List<String>> seleccionPorColeccion;
  final List<String> tiposPrenda;
  final ValueChanged<List<String>> onSeleccionesCambiadas;
  final Function onCompletarColeccion;

  DetalleColeccion({
    required this.coleccion,
    required this.seleccionPorColeccion,
    required this.tiposPrenda,
    required this.onSeleccionesCambiadas,
    required this.onCompletarColeccion,
  });

  @override
  _DetalleColeccionState createState() => _DetalleColeccionState();
}

class _DetalleColeccionState extends State<DetalleColeccion> {
  List<String> seleccionActual = [];
  Map<String, bool> checksActivados = {};
  Map<String, Color> iconColors = {};
  bool botonHabilitado = false;

  @override
  void initState() {
    super.initState();
    seleccionActual.addAll(widget.seleccionPorColeccion[widget.coleccion] ?? []);
    widget.tiposPrenda.forEach((tipoPrenda) {
      checksActivados[tipoPrenda] = true;
      iconColors[tipoPrenda] = Colors.blue;
    });
    _loadPrendasFromFirebase(); // Cargar tipos de prendas desde Firebase al inicializar
  }

  void _loadPrendasFromFirebase() async {
    // Obtener los tipos de prendas desde Firebase
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Orden')
          .where('Coleccion', isEqualTo: widget.coleccion)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<String> prendas = [];
        for (var doc in querySnapshot.docs) {
          List<dynamic> prendasData = doc['Prendas'];
          prendasData.forEach((prenda) {
            prendas.add(prenda['nombre']); // Agregar solo el nombre de la prenda
          });
        }

        setState(() {
          widget.tiposPrenda.clear(); // Limpiar la lista existente
          widget.tiposPrenda.addAll(prendas); // Agregar los tipos de prendas desde Firebase
        });
      }
    } catch (e) {
      print('Error al obtener tipos de prendas: $e');
    }
  }

  void _abrirFormulario(String tipoPrenda) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormularioDetallePrenda(
          tipoPrenda: tipoPrenda,
          onGuardar: (detallesPrenda) {
            setState(() {
              seleccionActual.add(tipoPrenda);
              checksActivados[tipoPrenda] = true;
              iconColors[tipoPrenda] = Colors.green;
              _verificarHabilitarBoton();
              widget.onSeleccionesCambiadas(seleccionActual);
            });
          },
          onCancel: () {
            setState(() {
              seleccionActual.remove(tipoPrenda);
              checksActivados[tipoPrenda] = false;
              iconColors[tipoPrenda] = Colors.blue;
              _verificarHabilitarBoton();
              widget.onSeleccionesCambiadas(seleccionActual);
            });
          },
        ),
      ),
    );
  }

  void _verificarHabilitarBoton() {
    bool todosVerdes = iconColors.values.every((color) => color == Colors.green);
    setState(() {
      botonHabilitado = todosVerdes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de ${widget.coleccion}'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: widget.tiposPrenda.map((tipoPrenda) {
                return ListTile(
                  title: Text(tipoPrenda),
                  onTap: () {
                    _abrirFormulario(tipoPrenda);
                  },
                  trailing: checksActivados[tipoPrenda]!
                      ? Icon(Icons.check_circle, color: iconColors[tipoPrenda])
                      : Icon(Icons.check_circle, color: Colors.yellow),
                );
              }).toList(),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: botonHabilitado ? () {
                widget.onCompletarColeccion();
                Navigator.pop(context);
              } : null,
              child: Text('Completar Colección'),
            ),
          ),
        ],
      ),
    );
  }
}

class FormularioDetallePrenda extends StatefulWidget {
  final String tipoPrenda;
  final Function(String) onGuardar;
  final Function() onCancel;

  const FormularioDetallePrenda({
    Key? key,
    required this.tipoPrenda,
    required this.onGuardar,
    required this.onCancel,
  }) : super(key: key);

  @override
  _FormularioDetallePrendaState createState() => _FormularioDetallePrendaState();
}

class _FormularioDetallePrendaState extends State<FormularioDetallePrenda> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _imagenController = TextEditingController();
  List<String> procesos = ['Bordado', 'Estampado', 'Teñido'];
  List<String> colores = ['Rojo', 'Azul', 'Verde', 'Negro'];
  String? _selectedProceso;
  String? _selectedColor;

  void _mostrarMensaje(String seleccion) {
    TextEditingController costoController = TextEditingController();
    TextEditingController tiempoController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ingrese Costo y Tiempo para $seleccion'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: costoController,
                decoration: InputDecoration(labelText: 'Costo'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    return null;
                  } else if (tiempoController.text.isEmpty) {
                    return 'Debe ingresar al menos el Costo o el Tiempo';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: tiempoController,
                decoration: InputDecoration(labelText: 'Tiempo (horas)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    return null;
                  } else if (costoController.text.isEmpty) {
                    return 'Debe ingresar al menos el Costo o el Tiempo';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                String detallesPrenda =
                    'Proceso: $_selectedProceso, Color: $_selectedColor, Costo: \$${costoController.text}, Tiempo: ${tiempoController.text} horas';
                widget.onGuardar(detallesPrenda);
                Navigator.of(context).pop();
              }
            },
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de ${widget.tipoPrenda}'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Seleccione un proceso para ${widget.tipoPrenda}:',
              style: TextStyle(fontSize: 18.0),
            ),
            DropdownButton<String>(
              value: _selectedProceso,
              icon: const Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              style: const TextStyle(color: Colors.deepPurple),
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedProceso = newValue;
                });
              },
              items: procesos.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20.0),
            Text(
              'Seleccione un color para ${widget.tipoPrenda}:',
              style: TextStyle(fontSize: 18.0),
            ),
            DropdownButton<String>(
              value: _selectedColor,
              icon: const Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              style: const TextStyle(color: Colors.deepPurple),
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedColor = newValue;
                });
              },
              items: colores.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20.0),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedProceso != null && _selectedColor != null) {
                    _mostrarMensaje(widget.tipoPrenda);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Debe seleccionar un proceso y un color.')),
                    );
                  }
                },
                child: Text('Guardar Detalles de ${widget.tipoPrenda}'),
              ),
            ),
            SizedBox(height: 20.0),
            Center(
              child: TextButton(
                onPressed: () {
                  widget.onCancel();
                  Navigator.pop(context);
                },
                child: Text('Cancelar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}