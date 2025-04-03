
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Modo Oscuro'),
            value: Theme.of(context).brightness == Brightness.dark,
            onChanged: (value) {
              Provider.of<ThemeProvider>(context, listen: false)
                  .toggleTheme(value);
            },
          ),
        ],
      ),
    );
  }
}