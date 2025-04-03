import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Iniciar sesión
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Verificar si el usuario existe en Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('Usuario no registrado en el sistema');
      }

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e.code);
    }
  }

  // Registrar usuario
  Future<User?> signUp(String email, String password, {String role = 'alumno'}) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Crear documento en Firestore
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e.code);
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Obtener usuario actual
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Manejo de errores
  String _handleAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'email-already-in-use':
        return 'El correo ya está registrado';
      case 'weak-password':
        return 'La contraseña es demasiado débil';
      case 'invalid-email':
        return 'Correo electrónico inválido';
      default:
        return 'Error desconocido';
    }
  }

  // Verificar si es admin
  Future<bool> isAdmin() async {
    User? user = _auth.currentUser;
    if (user == null) return false;

    DocumentSnapshot userDoc = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    return userDoc.exists && userDoc.get('role') == 'admin';
  }
}