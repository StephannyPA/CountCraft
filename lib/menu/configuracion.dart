import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:raymisa/widgets/login.dart';
import 'package:raymisa/menu/perfil.dart'; // Asegúrate de importar la página de perfil correctamente

class Configuracion extends StatelessWidget {
  const Configuracion({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          _buildCustomListTile(
            context,
            icon: Icons.person,
            title: 'Perfil',
            subtitle: 'Editar perfil',
            page: const PerfilPage(),
          ),
          _buildDivider(),
          _buildCustomListTile(
            context,
            icon: Icons.lock,
            title: 'Privacidad',
            subtitle: 'Configuración de privacidad',
            page: const PrivacidadPage(),
          ),
          _buildDivider(),
          _buildCustomListTile(
            context,
            icon: Icons.notifications,
            title: 'Notificaciones',
            subtitle: 'Configuración de notificaciones',
            page: const NotificacionesPage(),
          ),
          _buildDivider(),
          _buildCustomListTile(
            context,
            icon: Icons.language,
            title: 'Idioma',
            subtitle: 'Seleccionar idioma',
            page: const IdiomaPage(),
          ),
          _buildDivider(),
          _buildCustomListTile(
            context,
            icon: Icons.info,
            title: 'Sobre la app',
            subtitle: 'Información sobre la aplicación',
            page: const SobreAppPage(),
          ),
          _buildDivider(),
          _buildCustomListTile(
            context,
            icon: Icons.logout,
            title: 'Cerrar sesión',
            subtitle: '',
            onTap: () => _signOut(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomListTile(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? page,
    void Function()? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
        onTap: onTap ?? () {
          if (page != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page),
            );
          }
        },
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: Colors.white24,
      thickness: 1.0,
      height: 20.0,
    );
  }

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
    );
  }
}

// Ejemplo de las páginas individuales de configuración:

class PrivacidadPage extends StatelessWidget {
  const PrivacidadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacidad'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            SwitchListTile(
              title: const Text('Perfil privado'),
              value: true,
              onChanged: (bool value) {
                // Lógica para cambiar la configuración de privacidad
              },
            ),
            SwitchListTile(
              title: const Text('Compartir ubicación'),
              value: false,
              onChanged: (bool value) {
                // Lógica para cambiar la configuración de privacidad
              },
            ),
          ],
        ),
      ),
    );
  }
}

class NotificacionesPage extends StatelessWidget {
  const NotificacionesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            SwitchListTile(
              title: const Text('Notificaciones push'),
              value: true,
              onChanged: (bool value) {
                // Lógica para cambiar la configuración de notificaciones
              },
            ),
            SwitchListTile(
              title: const Text('Notificaciones por correo'),
              value: false,
              onChanged: (bool value) {
                // Lógica para cambiar la configuración de notificaciones
              },
            ),
          ],
        ),
      ),
    );
  }
}

class IdiomaPage extends StatelessWidget {
  const IdiomaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Idioma'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            ListTile(
              title: const Text('Español'),
              trailing: const Icon(Icons.check),
              onTap: () {
                // Lógica para seleccionar el idioma español
              },
            ),
            ListTile(
              title: const Text('Inglés'),
              trailing: const Icon(null),
              onTap: () {
                // Lógica para seleccionar el idioma inglés
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SobreAppPage extends StatelessWidget {
  const SobreAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre la app'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Raymisa App',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Versión 1.0.0 - Última Actualización: Junio 2024',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Raymisa App es una aplicación diseñada para facilitar la gestión de procesos y muestras de indumentaria. Con una interfaz intuitiva y funciones avanzadas, esta app permite a los usuarios:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Raymisa App está diseñada pensando en la facilidad de uso y en proporcionar herramientas eficientes para la gestión de procesos y muestras de indumentaria. ¡Esperamos que disfrutes usando nuestra aplicación!',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
