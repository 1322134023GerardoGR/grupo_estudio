import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/activity_model.dart';
import 'activity_detail.dart';

class ActivitiesHome extends StatelessWidget {
  const ActivitiesHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actividades'),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('activities')
            .orderBy('nombre') // Ordenar por nombre
            .snapshots(),
        builder: (context, snapshot) {
          // Manejo de estados
          if (snapshot.hasError) {
            debugPrint('Error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay actividades disponibles'));
          }

          // Procesar datos
          final activities = snapshot.data!.docs.map((doc) {
            return Activity.fromFirestore(doc);
          }).toList();

          // Agrupar por categoría
          final activitiesByCategory = <String, List<Activity>>{};
          for (var activity in activities) {
            activitiesByCategory.putIfAbsent(
                activity.categoria,
                    () => []
            ).add(activity);
          }

          return ListView(
            children: [
              for (final entry in activitiesByCategory.entries)
                _buildCategorySection(context, entry.key, entry.value),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategorySection(
      BuildContext context,
      String category,
      List<Activity> activities
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _getCategoryName(category),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: activities.length,
            itemBuilder: (context, index) {
              return _buildActivityCard(context, activities[index]);
            },
          ),
        ),
      ],
    );
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'clubes':
        return 'Clubes Estudiantiles';
      case 'deportes':
        return 'Deportes Universitarios';
      case 'voluntariado':
        return 'Programas de Voluntariado';
      default:
        return category.toUpperCase();
    }
  }

  Widget _buildActivityCard(BuildContext context, Activity activity) {
    return GestureDetector(
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
      child: Container(
        width: 180,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Parte superior con imagen
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    color: Colors.grey[200],
                  ),
                  child: activity.imagenUrl != null
                      ? Image.network(
                    activity.imagenUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => const Icon(Icons.error),
                  )
                      : const Icon(Icons.photo, size: 50),
                ),
              ),
              // Parte inferior con texto
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activity.horario.diasFormateados,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${activity.horario.horaInicio} - ${activity.horario.horaFin}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
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