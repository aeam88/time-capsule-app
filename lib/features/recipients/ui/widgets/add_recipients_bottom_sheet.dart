import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/recipients_bloc.dart';
import '../../bloc/recipients_event.dart';

class AddRecipientsBottomSheet extends StatefulWidget {
  final String capsuleId;

  const AddRecipientsBottomSheet({super.key, required this.capsuleId});

  @override
  State<AddRecipientsBottomSheet> createState() => _AddRecipientsBottomSheetState();
}

class _AddRecipientsBottomSheetState extends State<AddRecipientsBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final List<String> _emails = [];

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _addEmail() {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text.trim().toLowerCase();
    if (!_emails.contains(email)) {
      setState(() {
        _emails.add(email);
        _emailController.clear();
      });
    }
  }

  void _removeEmail(String email) {
    setState(() => _emails.remove(email));
  }

  void _submit() {
    if (_emails.isEmpty) return;
    context.read<RecipientsBloc>().add(
          AddRecipients(capsuleId: widget.capsuleId, emails: _emails),
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Agregar Destinatarios',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Máximo 10 por vez. Se omiten emails duplicados.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'ejemplo@correo.com',
                          prefixIcon: const Icon(Icons.email_outlined),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa un email';
                          }
                          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegex.hasMatch(value.trim())) {
                            return 'Email inválido';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => _addEmail(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _addEmail,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                if (_emails.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _emails.map((email) {
                      return Chip(
                        label: Text(email),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => _removeEmail(email),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _emails.isEmpty ? null : _submit,
                  child: Text('Agregar ${_emails.length} destinatario(s)'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void showAddRecipientsBottomSheet(BuildContext context, String capsuleId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => BlocProvider.value(
      value: context.read<RecipientsBloc>(),
      child: AddRecipientsBottomSheet(capsuleId: capsuleId),
    ),
  );
}
