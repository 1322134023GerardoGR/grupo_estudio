import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grupo_estudio/screens/auth/register.dart';
import 'package:grupo_estudio/services/auth_service.dart';

import '../activities/extracurriculars_page.dart';
import '../admin/admin_page.dart'; // Asegúrate de tener esta ruta correcta

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _auth = AuthService();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);

    try {
      // 1. Limpia espacios en el correo
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      debugPrint('Intento de login con: $email'); // Debug

      // 2. Autenticación
      User? user = await _auth.signIn(email, password);

      if (user != null) {
        // 3. Verificar si existe en Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        debugPrint('Documento de usuario: ${userDoc.exists}'); // Debug

        if (!userDoc.exists) {
          throw Exception('El usuario no está registrado en el sistema');
        }

        // 4. Redirigir según rol
        final role = userDoc.get('role') ?? 'alumno';
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => role == 'admin' ? AdminPage() : ExtracurricularsPage(),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error de login: ${e.toString()}'); // Debug detallado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_mapErrorToMessage(e))),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _mapErrorToMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'Usuario no registrado o correo incorrecto';
        case 'wrong-password':
          return 'Contraseña incorrecta';
        case 'invalid-email':
          return 'Formato de correo inválido';
        default:
          return 'Error de autenticación: ${error.message}';
      }
    }
    return error.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Correo',
                hintText: 'ejemplo@dominio.com',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Iniciar sesión'),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterPage()),
              ),
              child: const Text('¿No tienes cuenta? Regístrate'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}