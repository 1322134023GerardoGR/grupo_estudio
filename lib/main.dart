// lib/main.dart
import 'package:flutter/material.dart';
import 'package:grupo_estudio/services/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/auth/auth_wrapper.dart';
import 'screens/settings/settings_screen.dart';
import 'providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion de Actividades',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      themeMode: Provider.of<ThemeProvider>(context).themeMode,
      home: const AuthWrapper(),
      routes: {
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}