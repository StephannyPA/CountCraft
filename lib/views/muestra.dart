import 'package:flutter/material.dart';

class Muestra extends StatefulWidget {
  const Muestra({super.key});

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
        title: const Text('Registrar Colección de Prendas'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: 6, // Suponiendo que hay 6 colecciones
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, index) {
          String coleccion = 'Colección ${index + 1}';
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
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  coleccion,
                  style: const TextStyle(fontSize: 18.0),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class DetalleColeccion extends StatefulWidget {
  final String
  coleccion;
  final Map<String, List<String>> seleccionPorColeccion;
  final List<String> tiposPrenda;
  final ValueChanged<List<String>> onSeleccionesCambiadas;
  final VoidCallback onCompletarColeccion; // Cambiar a VoidCallback

  const DetalleColeccion({super.key,
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
  bool botonHabilitado = false; // Variable para controlar la habilitación del botón

  @override
  void initState() {
    super.initState();
    seleccionActual.addAll(widget.seleccionPorColeccion[widget.coleccion] ?? []);
    for (var tipoPrenda in widget.tiposPrenda) {
      checksActivados[tipoPrenda] = false; // Inicialmente, ningún check está activado
      iconColors[tipoPrenda] = Colors.blue;
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
              _verificarHabilitarBoton(); // Verificar si se habilita el botón
              widget.onSeleccionesCambiadas(seleccionActual);
            });
          },
          onCancel: () {
            setState(() {
              seleccionActual.remove(tipoPrenda);
              checksActivados[tipoPrenda] = false;
              iconColors[tipoPrenda] = Colors.blue;
              _verificarHabilitarBoton(); // Ver
              if (!seleccionActual.contains(tipoPrenda)) {
                checksActivados[tipoPrenda] = false;
                iconColors[tipoPrenda] = Colors.blue;
              }
              _verificarHabilitarBoton(); // Verificar si se habilita el botón
              widget.onSeleccionesCambiadas(seleccionActual);
            });
          },
        ),
      ),
    );
  }

  void _verificarHabilitarBoton() {
    // Verificar si todos los iconos están en verde
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
                      : const Icon(Icons.check_circle_outline, color: Colors.grey), // Cambiar a un círculo sin relleno si no está activado
                );
              }).toList(),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: botonHabilitado
                  ? () {
                widget.onCompletarColeccion();
                Navigator.pop(context);
              }
                  : null,
              child: const Text('Completar Colección'),
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
    super.key,
    required this.tipoPrenda,
    required this.onGuardar,
    required this.
    onCancel,
  });

  @override
  _FormularioDetallePrendaState createState() => _FormularioDetallePrendaState();
}

class _FormularioDetallePrendaState extends State<FormularioDetallePrenda> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _imagenController = TextEditingController();
  List<String> procesos = ['Bordado', 'Estampado', 'Teñido']; // Opciones de procesos
  List<String> colores = ['Rojo', 'Azul', 'Verde', 'Negro']; // Opciones de colores
  List<String> procesosSeleccionados = []; // Lista para almacenar procesos seleccionados
  List<String> coloresSeleccionados = []; // Lista para almacenar colores seleccionados
  String? _selectedProceso; // Variable para almacenar el proceso seleccionado
  String? selectedColor; // Variable para almacenar el color seleccionado


  void _mostrarMensaje(String seleccion) {
    TextEditingController costoController = TextEditingController();
    TextEditingController tiempoController = TextEditingController();

    final formKey = GlobalKey<FormState>(); // Nuevo GlobalKey para validar el formulario

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ingrese Costo y Tiempo para $seleccion'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: costoController,
                decoration: const InputDecoration(labelText: 'Costo'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    return null; // Si el valor no está vacío, es válido
                  } else if (tiempoController.text.isEmpty) {
                    return 'Debe ingresar al menos el Costo o el Tiempo'; // Mensaje de error si ambos están vacíos
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: tiempoController,
                decoration: const InputDecoration(labelText: 'Tiempo (horas)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    return null; // Si el valor no está vacío, es válido
                  } else if (costoController.text.isEmpty) {
                    return 'Debe ingresar al menos el Costo o el Tiempo'; // Mensaje de error si ambos están vacíos
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
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                String costo = costoController.text.trim();
                String tiempo = tiempoController.text.trim();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Costo: $costo, Tiempo: $tiempo horas')),
                );

                Navigator.of(context).pop(); // Cerrar el diálogo
              }
            },
            child: const Text('Guardar'),
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
      body: WillPopScope(
        onWillPop: () async {
          widget.onCancel();
          return true;
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ingrese los detalles de la prenda ${widget.tipoPrenda}:',
                  style: const TextStyle(fontSize: 16.0),
                ),

                const SizedBox(height: 40.0),
                // Centrar imagen por defecto
                Center(
                  child: Image.asset(
                    'assets/images/defecto.png', // Ruta de la imagen por defecto
                    height: 200, // Ajusta la altura de la imagen según sea necesario
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 40.0),
                //Selector de proceso
                DropdownButtonFormField<String>(
                  value: _selectedProceso,
                  hint: const Text('Seleccione el proceso'),
                  items: procesos.map((proceso) {
                    return DropdownMenuItem(
                      value: proceso,
                      child: Text(proceso),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedProceso = value!;
                      if (!procesosSeleccionados.contains(_selectedProceso!)) { // Evitar duplicados
                        procesosSeleccionados.add(_selectedProceso!);
                      }
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor seleccione el proceso';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                // Mostrar procesos seleccionados
                Wrap(
                  spacing: 8.0,
                  children: procesosSeleccionados.map((proceso) {
                    return GestureDetector(
                      onTap: () {
                        _mostrarMensaje(proceso); // Mostrar mensaje al presionar el proceso seleccionado
                      },
                      child: Chip(
                        label: Text(proceso),
                        onDeleted: () {
                          setState(() {
                            procesosSeleccionados.remove(proceso); // Eliminar el proceso seleccionado
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16.0),
                // Selector de color
                DropdownButton<String>(
                  isExpanded: true,
                  value: selectedColor,
                  hint: const Text('Seleccione el color'),
                  items: colores.map((color) {
                    return DropdownMenuItem(
                      value: color,
                      child: Text(color),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedColor = value!;
                      if (!coloresSeleccionados.contains(selectedColor!)) { // Evitar duplicados
                        coloresSeleccionados.add(selectedColor!);
                      }
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                // Mostrar colores seleccionados
                Wrap(
                  spacing: 8.0,
                  children: coloresSeleccionados.map((
                      color) {
                    return GestureDetector(
                      onTap: () {
                        _mostrarMensaje(color); // Mostrar mensaje al presionar el color seleccionado
                      },
                      child: Chip(
                        label: Text(color),
                        onDeleted: () {
                          setState(() {
                            coloresSeleccionados.remove(color); // Eliminar el color seleccionado
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        widget.onCancel();
                        Navigator.pop(context);
                      },
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final detallesPrenda =
                              'Detalles de ${widget.tipoPrenda}: Imagen por defecto, Procesos - ${procesosSeleccionados.join(', ')}, Colores - ${coloresSeleccionados.join(', ')}';
                          widget.onGuardar(detallesPrenda);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Guardar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _imagenController.dispose();
    super.dispose();
  }
}
