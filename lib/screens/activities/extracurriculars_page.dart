// lib/screens/student/extracurriculars_page.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'activities_list.dart';


class ExtracurricularsPage extends StatelessWidget {
  const ExtracurricularsPage({super.key});
  Future<bool?> _showLogoutDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actividades Extracurriculares'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final shouldLogout = await _showLogoutDialog(context);
              if (shouldLogout == true) {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: const StudentActivitiesScreen(), // ¡Esta es la clave!
    );
  }
}