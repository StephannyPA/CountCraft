import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Prenda {
  final String tipo;
  String? modelo;

  Prenda(this.tipo, {this.modelo});
}

class Orden extends StatefulWidget {
  const Orden({super.key});

  @override
  _OrdenState createState() => _OrdenState();
}

class _OrdenState extends State<Orden> {
  static int _ordenCounter = 1;  // Contador estático para las órdenes
  final _formKey = GlobalKey<FormState>();
  final _nombreClienteController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _fechaEntregaController = TextEditingController();
  final _nombreColeccionController = TextEditingController(); // Nuevo controlador para el nombre de la colección
  String? _tipoPrenda;
  final List<String> _tiposPrenda = ['Camisa', 'Pantalón', 'Chaqueta', 'Falda'];
  final List<Prenda> _prendasSeleccionadas = [];

  @override
  void initState() {
    super.initState();
    _fechaEntregaController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  void _agregarPrenda(String prenda) {
    setState(() {
      _prendasSeleccionadas.add(Prenda(prenda));
      _tipoPrenda = null; // Limpiar la selección actual después de agregar
    });
  }

  void _mostrarPrenda(Prenda prenda) {
    final disenoController = TextEditingController();
    final formKeyDialog = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(prenda.tipo),
        content: SingleChildScrollView(
          child: Form(
            key: formKeyDialog,
            child: Column(
              children: <Widget>[
                Text('Ingrese el modelo para la prenda: ${prenda.tipo}'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: disenoController,
                  decoration: const InputDecoration(labelText: 'Modelo'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingrese el modelo';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          TextButton(
            onPressed: () {
              if (formKeyDialog.currentState!.validate()) {
                setState(() {
                  prenda.modelo = disenoController.text;
                });
                Navigator.of(context).pop();
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _fechaEntregaController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _generarOrden() {
    if (_formKey.currentState!.validate()) {
      final int ordenNumero = _ordenCounter++;
      final String nombreColeccion = _nombreColeccionController.text.trim();
      // Procesar la orden
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Orden generada con éxito: Orden$ordenNumero, Colección: $nombreColeccion')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generar Orden'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _nombreClienteController,
                decoration: const InputDecoration(labelText: 'Nombre del Cliente'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el nombre del cliente';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fechaEntregaController,
                decoration: InputDecoration(
                  labelText: 'Fecha',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombreColeccionController,
                decoration: const InputDecoration(labelText: 'Nombre de la Colección'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el nombre de la colección';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _tipoPrenda,
                decoration: const InputDecoration(labelText: 'Tipo de Prenda'),
                items: _tiposPrenda.map((String tipo) {
                  return DropdownMenuItem<String>(
                    value: tipo,
                    child: Text(tipo),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    _agregarPrenda(newValue);
                  }
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor, seleccione un tipo de prenda';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Prendas Seleccionadas:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                children: _prendasSeleccionadas.map((prenda) {
                  return GestureDetector(
                    onTap: () => _mostrarPrenda(prenda),
                    child: Chip(
                      label: Text(
                        prenda.modelo != null ? '${prenda.tipo} - ${prenda.modelo}' : prenda.tipo,
                      ),
                      onDeleted: () {
                        setState(() {
                          _prendasSeleccionadas.remove(prenda);
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _generarOrden,
                child: const Text('Generar Orden'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombreClienteController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _fechaEntregaController.dispose();
    _nombreColeccionController.dispose(); // Dispose del controlador de nombre de colección
    super.dispose();
  }
}
