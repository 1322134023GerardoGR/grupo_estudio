import 'package:flutter/material.dart';

class ExtracurricularsPage extends StatelessWidget {
  const ExtracurricularsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extracurriculares'),
      ),
      body: Center(
        child: Text('Lista de actividades extracurriculares'),
      ),
    );
  }
}