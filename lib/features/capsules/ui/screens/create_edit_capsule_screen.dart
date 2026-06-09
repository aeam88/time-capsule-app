import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../bloc/capsules_bloc.dart';
import '../../bloc/capsules_event.dart';
import '../../bloc/capsules_state.dart';
import '../../data/models/capsule_model.dart';

class CreateEditCapsuleScreen extends StatefulWidget {
  final Capsule? capsule;

  const CreateEditCapsuleScreen({super.key, this.capsule});

  bool get isEditing => capsule != null;

  @override
  State<CreateEditCapsuleScreen> createState() => _CreateEditCapsuleScreenState();
}

class _CreateEditCapsuleScreenState extends State<CreateEditCapsuleScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late DateTime _unlockDate;
  late bool _isEncrypted;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.capsule?.title ?? '');
    _descriptionController = TextEditingController(text: widget.capsule?.description ?? '');
    _unlockDate = widget.capsule?.unlockDate ?? DateTime.now().add(const Duration(days: 365));
    _isEncrypted = widget.capsule?.isEncrypted ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar Cápsula' : 'Nueva Cápsula'),
      ),
      body: BlocListener<CapsulesBloc, CapsulesState>(
        listener: (context, state) {
          if (state is CapsuleOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            context.go('/capsules');
          } else if (state is CapsulesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    hintText: 'Ej: Carta para mi futuro yo',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa un título';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción (opcional)',
                    hintText: 'Describe el contenido de la cápsula',
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Fecha de Desbloqueo'),
                    subtitle: Text(
                      DateFormat('dd/MM/yyyy').format(_unlockDate),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _selectDate,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: SwitchListTile(
                    secondary: const Icon(Icons.enhanced_encryption),
                    title: const Text('Contenido Cifrado'),
                    subtitle: const Text('Protege tu contenido con cifrado AES-256'),
                    value: _isEncrypted,
                    onChanged: (value) {
                      setState(() {
                        _isEncrypted = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 32),
                BlocBuilder<CapsulesBloc, CapsulesState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state is CapsulesLoading ? null : _onSubmit,
                      child: state is CapsulesLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(widget.isEditing ? 'Guardar Cambios' : 'Crear Cápsula'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _unlockDate,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date != null) {
      setState(() {
        _unlockDate = date;
      });
    }
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    if (widget.isEditing) {
      context.read<CapsulesBloc>().add(
            UpdateCapsule(
              capsuleId: widget.capsule!.id,
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
              unlockDate: _unlockDate,
            ),
          );
    } else {
      context.read<CapsulesBloc>().add(
            CreateCapsule(
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
              unlockDate: _unlockDate,
              isEncrypted: _isEncrypted,
            ),
          );
    }
  }
}
