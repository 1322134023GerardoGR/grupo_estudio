import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/activity_model.dart';
import 'activity_detail.dart';

class StudentActivitiesScreen extends StatelessWidget {
  const StudentActivitiesScreen({super.key});

  Future<List<Activity>> _fetchActivities() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('activities')
          .get();

      debugPrint('Documentos encontrados: ${snapshot.docs.length}'); // Debug

      return snapshot.docs.map((doc) => Activity.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching activities: $e'); // Debug
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actividades Disponibles'),
      ),
      body: FutureBuilder<List<Activity>>(
        future: _fetchActivities(),
        builder: (context, snapshot) {
          // Estados de carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            debugPrint('Error en FutureBuilder: ${snapshot.error}'); // Debug
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay actividades disponibles'));
          }

          final activities = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.sports_soccer),
                  title: Text(activity.nombre),
                  subtitle: Text(activity.categoria.toUpperCase()),
                  trailing: Text(
                    activity.horario.dias.join(', '),
                    style: const TextStyle(fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => ActivityDetailScreen(activity: activity),
                        transitionsBuilder: (_, animation, __, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}