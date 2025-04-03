// lib/screens/student/extracurriculars_page.dart
import 'package:flutter/material.dart';

import 'activities_list.dart';


class ExtracurricularsPage extends StatelessWidget {
  const ExtracurricularsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actividades Extracurriculares'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Forzar recarga si es necesario
            },
          ),
        ],
      ),
      body: const StudentActivitiesScreen(), // ¡Esta es la clave!
    );
  }
}