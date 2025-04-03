import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserManagementPanel extends StatelessWidget {
  final CollectionReference _users =
  FirebaseFirestore.instance.collection('users');

  UserManagementPanel({super.key});

  Future<void> _toggleAdminStatus(String userId, bool currentStatus) async {
    await _users.doc(userId).update({'role': currentStatus ? 'alumno' : 'admin'});
  }


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _users.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar usuarios'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final isAdmin = data['role'] == 'admin';

            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(data['email'] ?? 'Sin email'),
                subtitle: Text('Rol: ${data['role'] ?? 'sin rol'}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: isAdmin,
                      onChanged: (value) => _toggleAdminStatus(doc.id, isAdmin),
                      activeColor: Colors.green,
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


}