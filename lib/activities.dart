import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ActivitiesPage extends StatelessWidget {
  ActivitiesPage({Key? key}) : super(key: key);
  final CollectionReference activities =
  FirebaseFirestore.instance.collection('activities');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actividades Extracurriculares'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: activities.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar datos'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.requireData;
          return ListView.builder(
            itemCount: data.size,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(data.docs[index]['nombre']),
                subtitle: Text(data.docs[index]['descripcion']),
              );
            },
          );
        },
      ),
    );
  }
}