// lib/screens/auth/auth_wrapper.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../activities/extracurriculars_page.dart';
import 'login.dart';
import '../admin/admin_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user == null) {
            return const LoginPage();
          }
          // Verificar rol y redirigir
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                final role = userSnapshot.data!.get('role');
                return role == 'admin'
                    ? const AdminPage()
                    : const ExtracurricularsPage();
              }
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            },
          );
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}