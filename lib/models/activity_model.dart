import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String id;
  final String nombre;
  final String descripcion;
  final String categoria;
  final Horario horario;
  final String? imagenUrl;

  Activity({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.categoria,
    required this.horario,
    this.imagenUrl,
  });

  factory Activity.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Activity(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      categoria: data['categoria'] ?? 'clubes',
      horario: Horario.fromMap(data['horario'] ?? {}),
      imagenUrl: data['imagen'],
    );
  }
}

class Horario {
  final List<String> dias;
  final String horaInicio;
  final String horaFin;

  Horario({
    required this.dias,
    required this.horaInicio,
    required this.horaFin,
  });

  factory Horario.fromMap(Map<String, dynamic> map) {
    return Horario(
      dias: List<String>.from(map['dias'] ?? []),
      horaInicio: map['hora_inicio'] ?? '00:00',
      horaFin: map['hora_fin'] ?? '00:00',
    );
  }

  String get diasFormateados {
    if (dias.isEmpty) return 'Sin horario';
    return dias.join(', ');
  }
}