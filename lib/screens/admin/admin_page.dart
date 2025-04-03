import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'activity_form.dart';
import 'user_management.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
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
  final CollectionReference _activities =
  FirebaseFirestore.instance.collection('activities');
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        actions: [
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
      body: _currentIndex == 0 ? _buildActivitiesPanel() : UserManagementPanel(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Actividades',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Usuarios',
          ),
        ],
        onTap: (index) => setState(() => _currentIndex = index),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ActivityForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildActivitiesPanel() {
    return StreamBuilder<QuerySnapshot>(
      stream: _activities.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar datos'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(data['nombre'] ?? 'Sin nombre'),
                subtitle: Text(data['descripcion'] ?? 'Sin descripción'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showActivityForm(context, doc),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteActivity(doc.id),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _deleteActivity(String id) async {
    try {
      await _activities.doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Actividad eliminada')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _showActivityForm(BuildContext context, [DocumentSnapshot? document]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ActivityForm(document: document),
      ),
    );
  }
}