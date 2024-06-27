import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:raymisa/conexion/database_service.dart';
import 'package:raymisa/widgets/bottom_nav_bar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
 _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _connectionStatus = '';

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  void _checkConnection() async {
    final isConnected = await DatabaseService().connect();
    setState(() {
      _connectionStatus = isConnected ? 'Conexión a Firestore exitosa' : 'Error al conectar a Firestore';
    });
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final isConnected = await DatabaseService().connect();
      setState(() {
        _connectionStatus = isConnected ? 'Conectado correctamente' : 'No se pudo conectar';
      });
      if (isConnected) {
        try {
          UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );
          if (userCredential.user != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const BottomNavBar()), // Redirige al BottomNavBar
            );
          }
        } on FirebaseAuthException catch (e) {
          String errorMessage = 'Error desconocido';
          if (e.code == 'user-not-found') {
            errorMessage = 'Usuario no encontrado';
          } else if (e.code == 'wrong-password') {
            errorMessage = 'Contraseña incorrecta';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 30),
              Image.asset(
                'assets/images/logo.png',
                height: 200,
                width: 200,
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 50.0),
                      child: TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 50.0),
                      child: TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _login,
                      child: const Text('Login'),
                    ),
                    const SizedBox(height: 20),
                    Visibility(
                      visible: false,  // Hace que el widget no sea visible
                      child: Text(
                        _connectionStatus,
                        style: TextStyle(
                          color: _connectionStatus.contains('correctamente') ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

