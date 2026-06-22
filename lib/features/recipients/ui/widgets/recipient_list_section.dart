import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/recipients_bloc.dart';
import '../../bloc/recipients_event.dart';
import '../../bloc/recipients_state.dart';
import 'add_recipients_bottom_sheet.dart';

class RecipientListSection extends StatelessWidget {
  final String capsuleId;
  final bool canManage;

  const RecipientListSection({
    super.key,
    required this.capsuleId,
    required this.canManage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Destinatarios',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (canManage)
              IconButton.filledTonal(
                onPressed: () => showAddRecipientsBottomSheet(context, capsuleId),
                icon: const Icon(Icons.person_add_outlined, size: 20),
              ),
          ],
        ),
        const SizedBox(height: 8),
        BlocConsumer<RecipientsBloc, RecipientsState>(
          listener: (context, state) {
            if (state is RecipientsOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is RecipientsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },
          listenWhen: (prev, curr) => curr is RecipientsOperationSuccess || curr is RecipientsError,
          builder: (context, state) {
            if (state is RecipientsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final recipients = state is RecipientsLoaded
                ? state.recipients
                : state is RecipientsOperationSuccess
                    ? state.recipients
                    : null;

            if (recipients == null) {
              return const SizedBox.shrink();
            }

            if (recipients.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.people_outline, size: 40, color: Theme.of(context).textTheme.bodySmall?.color),
                        const SizedBox(height: 8),
                        Text(
                          'Sin destinatarios',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (canManage) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Agrega personas para que reciban la cápsula',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }

            return Card(
              child: Column(
                children: [
                  for (int i = 0; i < recipients.length; i++) ...[
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.secondary.withAlpha(30),
                        child: Text(
                          recipients[i].email[0].toUpperCase(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        recipients[i].email,
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: canManage
                          ? IconButton(
                              icon: Icon(Icons.delete_outline, size: 20, color: Colors.red.shade300),
                              onPressed: () => _confirmRemove(context, recipients[i].id, recipients[i].email),
                            )
                          : null,
                    ),
                    if (i < recipients.length - 1) const Divider(height: 1, indent: 56),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _confirmRemove(BuildContext context, String recipientId, String email) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar destinatario'),
        content: Text('¿Eliminar a $email de esta cápsula?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<RecipientsBloc>().add(
                    RemoveRecipient(capsuleId: capsuleId, recipientId: recipientId),
                  );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
