import 'package:flutter/material.dart';

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
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Perfil'),
            subtitle: const Text('Editar perfil'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PerfilPage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Privacidad'),
            subtitle: const Text('Configuración de privacidad'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrivacidadPage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notificaciones'),
            subtitle: const Text('Configuración de notificaciones'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificacionesPage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Idioma'),
            subtitle: const Text('Seleccionar idioma'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const IdiomaPage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Sobre la app'),
            subtitle: const Text('Información sobre la aplicación'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SobreAppPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Ejemplo de las páginas individuales de configuración:

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

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
            const TextField(
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            const TextField(
              decoration: InputDecoration(labelText: 'Correo electrónico'),
            ),
            ElevatedButton(
              onPressed: () {
                // Lógica para guardar la información del perfil
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}

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
              'Versión 1.0.0',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Esta es una aplicación para la gestión de procesos y muestras de indumentaria.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
