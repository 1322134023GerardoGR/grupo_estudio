import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityForm extends StatefulWidget {
  final DocumentSnapshot? document;

  const ActivityForm({super.key, this.document});

  @override
  State<ActivityForm> createState() => _ActivityFormState();
}

class _ActivityFormState extends State<ActivityForm> {
  final _formKey = GlobalKey<FormState>();
  final List<String> _days = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado'
  ];
  final List<String> _categories = ['clubes', 'deportes', 'voluntariado'];

  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  late TextEditingController _imageUrlController;
  List<String> _selectedDays = [];
  String _selectedCategory = 'clubes';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descController = TextEditingController();
    _startTimeController = TextEditingController(text: '15:00');
    _endTimeController = TextEditingController(text: '17:00');
    _imageUrlController = TextEditingController();

    if (widget.document != null) {
      final data = widget.document!.data() as Map<String, dynamic>;
      _nameController.text = data['nombre'] ?? '';
      _descController.text = data['descripcion'] ?? '';
      _selectedCategory = data['categoria'] ?? 'clubes';
      _imageUrlController.text = data['imagen'] ?? '';

      final horario = data['horario'] as Map<String, dynamic>? ?? {};
      _startTimeController.text = horario['hora_inicio'] ?? '15:00';
      _endTimeController.text = horario['hora_fin'] ?? '17:00';
      _selectedDays = List<String>.from(horario['dias'] ?? []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.document == null ? 'Nueva Actividad' : 'Editar Actividad'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre de la actividad'),
              validator: _validateField,
            ),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Descripción'),
              maxLines: 3,
              validator: _validateField,
            ),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categories
                  .map((category) => DropdownMenuItem(
                value: category,
                child: Text(category.toUpperCase()),
              ))
                  .toList(),
              onChanged: (value) => setState(() => _selectedCategory = value!),
              decoration: const InputDecoration(labelText: 'Categoría'),
            ),
            const SizedBox(height: 16),
            const Text('Días de la actividad:'),
            Wrap(
              spacing: 8,
              children: _days.map((day) {
                return FilterChip(
                  label: Text(day),
                  selected: _selectedDays.contains(day),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedDays.add(day);
                      } else {
                        _selectedDays.remove(day);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _startTimeController,
                    decoration: const InputDecoration(labelText: 'Hora inicio'),
                    keyboardType: TextInputType.datetime,
                    validator: _validateTime,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _endTimeController,
                    decoration: const InputDecoration(labelText: 'Hora fin'),
                    keyboardType: TextInputType.datetime,
                    validator: _validateTime,
                  ),
                ),
              ],
            ),
            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(labelText: 'URL de imagen (opcional)'),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Guardar Actividad'),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateField(String? value) {
    if (value == null || value.isEmpty) {
      return 'Este campo es obligatorio';
    }
    return null;
  }

  String? _validateTime(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingrese una hora';
    }
    if (!RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(value)) {
      return 'Formato HH:MM';
    }
    return null;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedDays.isNotEmpty) {
      try {
        final activityData = {
          'nombre': _nameController.text,
          'descripcion': _descController.text,
          'categoria': _selectedCategory,
          'imagen': _imageUrlController.text.isNotEmpty ? _imageUrlController.text : null,
          'horario': {
            'dias': _selectedDays,
            'hora_inicio': _startTimeController.text,
            'hora_fin': _endTimeController.text,
          },
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (widget.document == null) {
          activityData['createdAt'] = FieldValue.serverTimestamp();
          await FirebaseFirestore.instance
              .collection('activities')
              .add(activityData);
        } else {
          await FirebaseFirestore.instance
              .collection('activities')
              .doc(widget.document!.id)
              .update(activityData);
        }

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione al menos un día')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}