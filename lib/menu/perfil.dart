import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  _PerfilPageState createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  String _name = '';
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print('UID del usuario: ${user.uid}'); // Imprimir UID del usuario
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          print('Documento encontrado'); // Confirmar que el documento existe
          setState(() {
            _name = userDoc['Nombre'] ?? 'Nombre no encontrado';
            _emailController.text = user.email ?? 'Correo no encontrado';
            _nameController.text = _name;
            print('Nombre: $_name'); // Imprimir nombre cargado
            print('Correo: ${_emailController.text}'); // Imprimir correo cargado
          });
        } else {
          print('Documento no existe');
        }
      } catch (e) {
        print('Error al cargar los datos del usuario: $e');
      }
    } else {
      print('Usuario no autenticado');
    }
  }

  Future<void> _saveUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'Nombre': _nameController.text,
          'Correo': _emailController.text,
        });
        setState(() {
          _name = _nameController.text;
        });
        print('Datos guardados correctamente'); // Confirmar que los datos se han guardado
      } catch (e) {
        print('Error al guardar los datos del usuario: $e');
      }
    } else {
      print('Usuario no autenticado');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Correo electrónico'),
              enabled: false,
            ),
            ElevatedButton(
              onPressed: _saveUserData,
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
