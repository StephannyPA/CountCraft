import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  _PerfilPageState createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  String _name = '';
  String _email = '';
  String _imageURL = 'https://via.placeholder.com/150'; // Placeholder URL
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

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
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
        if (userDoc.exists) {
          print('Documento del usuario encontrado: ${userDoc.data()}');
          setState(() {
            _name = userDoc['Nombre'];
            _email = userDoc['Correo'];
            _imageURL = userDoc['Imagen'] ?? 'https://via.placeholder.com/150';
            _emailController.text = _email;
            _nameController.text = _name;
            _addressController.text = userDoc['Direccion'] ?? '';
            _phoneController.text = userDoc['Celular'] ?? '';
          });
        } else {
          print('Documento del usuario no encontrado');
        }
      } catch (e) {
        print('Error al cargar los datos del usuario: $e');
      }
    }
  }

  Future<void> _saveUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        String? imageURL;
        if (_imageFile != null) {
          imageURL = await _uploadImageToStorage(_imageFile!);
        }

        await FirebaseFirestore.instance.collection('Users').doc(user.uid).update({
          'Nombre': _nameController.text,
          'Correo': _emailController.text,
          'Direccion': _addressController.text,
          'Celular': _phoneController.text,
          if (imageURL != null) 'Imagen': imageURL,
        });
        setState(() {
          _name = _nameController.text;
          _email = _emailController.text;
          if (imageURL != null) _imageURL = imageURL;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Datos actualizados correctamente')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar los datos: $e')),
        );
        print('Error al guardar los datos del usuario: $e');
      }
    }
  }

  Future<void> _pickImage() async {
    print('Iniciando selección de imagen');
    await _requestPermissions();
    print('Permisos solicitados');
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    print('Resultado de pickImage: $pickedFile');
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      print('Imagen seleccionada: ${pickedFile.path}');
    } else {
      print('No se seleccionó ninguna imagen');
    }
  }

  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.photos,
      Permission.storage,
    ].request();

    if (statuses[Permission.photos]!.isDenied || statuses[Permission.storage]!.isDenied) {
      // Manejar el caso cuando los permisos son denegados
      print('Permisos denegados');
    }
  }

  Future<String> _uploadImageToStorage(File imageFile) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        TaskSnapshot uploadTask = await FirebaseStorage.instance
            .ref('profile_images/${user.uid}')
            .putFile(imageFile);
        return await uploadTask.ref.getDownloadURL();
      } catch (e) {
        print('Error al cargar la imagen: $e');
        return 'https://via.placeholder.com/150';
      }
    }
    return 'https://via.placeholder.com/150';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              CircleAvatar(
                radius: 50,
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile!)
                    : NetworkImage(_imageURL) as ImageProvider,
              ),
              TextButton(
                onPressed: _pickImage,
                child: const Text('Cambiar foto'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Correo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Dirección',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Celular',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveUserData,
                child: const Text('Guardar'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
