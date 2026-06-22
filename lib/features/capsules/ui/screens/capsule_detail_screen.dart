import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../bloc/capsules_bloc.dart';
import '../../bloc/capsules_event.dart';
import '../../bloc/capsules_state.dart';
import '../../data/models/capsule_model.dart';
import '../../../files/bloc/files_bloc.dart';
import '../../../files/bloc/files_event.dart';
import '../../../files/data/repositories/files_repository.dart';
import '../../../files/ui/widgets/file_list_section.dart';
import '../../../recipients/bloc/recipients_bloc.dart';
import '../../../recipients/bloc/recipients_event.dart';
import '../../../recipients/data/repositories/recipients_repository.dart';
import '../../../recipients/ui/widgets/recipient_list_section.dart';
import '../../../../shared/widgets/countdown_timer.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../../injection_container.dart';

class CapsuleDetailScreen extends StatefulWidget {
  final String capsuleId;

  const CapsuleDetailScreen({super.key, required this.capsuleId});

  @override
  State<CapsuleDetailScreen> createState() => _CapsuleDetailScreenState();
}

class _CapsuleDetailScreenState extends State<CapsuleDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CapsulesBloc>().add(LoadCapsuleDetail(capsuleId: widget.capsuleId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CapsulesBloc, CapsulesState>(
      listener: (context, state) {
        if (state is CapsuleOperationSuccess) {
          AppToast.show(context, message: state.message, type: ToastType.success);
          context.read<CapsulesBloc>().add(const LoadCapsules());
          context.go('/capsules');
        } else if (state is CapsulesError) {
          AppToast.show(context, message: state.message, type: ToastType.error);
        }
      },
      builder: (context, state) {
        if (state is CapsulesLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Cargando...')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is CapsuleDetailLoaded) {
          return _buildDetail(context, state.capsule);
        }

        if (state is CapsulesError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text(state.message)),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Cápsula')),
          body: const Center(child: Text('Cargando...')),
        );
      },
    );
  }

  Widget _buildDetail(BuildContext context, Capsule capsule) {
    final statusColor = _getStatusColor(capsule.statusString);
    final dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => FilesBloc(
            repository: FilesRepository(
              dio: InjectionContainer().apiClient.dio,
            ),
          )..add(LoadFiles(capsuleId: widget.capsuleId)),
        ),
        BlocProvider(
          create: (_) => RecipientsBloc(
            repository: RecipientsRepository(
              dio: InjectionContainer().apiClient.dio,
            ),
          )..add(LoadRecipients(capsuleId: widget.capsuleId)),
        ),
      ],
      child: _DetailBody(
        capsule: capsule,
        capsuleId: widget.capsuleId,
        statusColor: statusColor,
        dateTimeFormat: dateTimeFormat,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'UNLOCKED':
        return Colors.green;
      case 'LOCKED':
        return Colors.red;
      case 'DRAFT':
        return Colors.orange;
      case 'ARCHIVED':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }
}

class _DetailBody extends StatelessWidget {
  final Capsule capsule;
  final String capsuleId;
  final Color statusColor;
  final DateFormat dateTimeFormat;

  const _DetailBody({
    required this.capsule,
    required this.capsuleId,
    required this.statusColor,
    required this.dateTimeFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Cápsula'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value, capsule),
            itemBuilder: (context) => [
              if (capsule.status == CapsuleStatus.draft) ...[
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit_outlined),
                    title: Text('Editar'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'lock',
                  child: ListTile(
                    leading: Icon(Icons.lock_outline),
                    title: Text('Bloquear'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
              if (capsule.status == CapsuleStatus.locked)
                const PopupMenuItem(
                  value: 'unlock',
                  child: ListTile(
                    leading: Icon(Icons.lock_open_outlined),
                    title: Text('Desbloquear'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              if (capsule.status != CapsuleStatus.unlocked)
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete_outline, color: Colors.red),
                    title: Text('Eliminar', style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    capsule.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withAlpha(128)),
                  ),
                  child: Text(
                    capsule.statusString,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (capsule.description != null && capsule.description!.isNotEmpty) ...[
              Text(
                capsule.description!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
              ),
              const SizedBox(height: 24),
            ] else ...[
              const SizedBox(height: 8),
              Text(
                'Sin descripción',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontStyle: FontStyle.italic,
                    ),
              ),
              const SizedBox(height: 24),
            ],
            _buildInfoSection(context),
            const SizedBox(height: 24),
            _buildStatsSection(context),
            if (capsule.status == CapsuleStatus.locked) ...[
              const SizedBox(height: 24),
              CountdownTimer(targetDate: capsule.unlockDate),
            ],
            const SizedBox(height: 24),
            RecipientListSection(
              capsuleId: capsuleId,
              canManage: capsule.status == CapsuleStatus.draft,
            ),
            const SizedBox(height: 24),
            FileListSection(
              capsuleId: capsuleId,
              canUpload: capsule.status == CapsuleStatus.draft,
            ),
            const SizedBox(height: 32),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              icon: Icons.calendar_today,
              label: 'Fecha de desbloqueo',
              value: dateTimeFormat.format(capsule.unlockDate),
            ),
            if (capsule.unlockedAt != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                context,
                icon: Icons.lock_open,
                label: 'Desbloqueada el',
                value: dateTimeFormat.format(capsule.unlockedAt!),
              ),
            ],
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              icon: Icons.enhanced_encryption,
              label: 'Cifrado',
              value: capsule.isEncrypted ? 'Activado' : 'Desactivado',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              icon: Icons.access_time,
              label: 'Creada',
              value: dateTimeFormat.format(capsule.createdAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.secondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.folder_outlined,
            label: 'Archivos',
            count: capsule.fileCount,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.people_outline,
            label: 'Destinatarios',
            count: capsule.recipientCount,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int count,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (capsule.status == CapsuleStatus.draft) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => context.push('/capsules/${capsule.id}/edit'),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Editar'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showLockDialog(context),
              icon: const Icon(Icons.lock_outline),
              label: const Text('Bloquear'),
            ),
          ),
        ],
      );
    }

    if (capsule.status == CapsuleStatus.locked) {
      final canUnlock = capsule.unlockDate.isBefore(DateTime.now());
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: canUnlock ? () => _showUnlockDialog(context) : null,
          icon: const Icon(Icons.lock_open_outlined),
          label: Text(canUnlock ? 'Desbloquear' : 'Bloqueada hasta ${capsule.unlockDate.day}/${capsule.unlockDate.month}/${capsule.unlockDate.year}'),
        ),
      );
    }

    if (capsule.status == CapsuleStatus.unlocked) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _showArchiveDialog(context),
          icon: const Icon(Icons.archive_outlined),
          label: const Text('Archivar'),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _handleMenuAction(BuildContext context, String action, Capsule capsule) {
    switch (action) {
      case 'edit':
        context.push('/capsules/${capsule.id}/edit');
        break;
      case 'lock':
        _showLockDialog(context);
        break;
      case 'unlock':
        _showUnlockDialog(context);
        break;
      case 'delete':
        _showDeleteDialog(context);
        break;
    }
  }

  void _showLockDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Bloquear Cápsula'),
        content: const Text(
          'Una vez bloqueada, no podrás editar ni eliminar la cápsula hasta que sea desbloqueada. ¿Estás seguro?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CapsulesBloc>().add(LockCapsule(capsuleId: capsule.id));
            },
            child: const Text('Bloquear'),
          ),
        ],
      ),
    );
  }

  void _showUnlockDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Desbloquear Cápsula'),
        content: const Text(
          '¿Estás seguro de que deseas desbloquear esta cápsula? El contenido estará disponible inmediatamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CapsulesBloc>().add(UnlockCapsule(capsuleId: capsule.id));
            },
            child: const Text('Desbloquear'),
          ),
        ],
      ),
    );
  }

  void _showArchiveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Archivar Cápsula'),
        content: const Text(
          '¿Archivar esta cápsula? No aparecerá en tu lista principal.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CapsulesBloc>().add(ArchiveCapsule(capsuleId: capsule.id));
            },
            child: const Text('Archivar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Cápsula'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar esta cápsula? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CapsulesBloc>().add(DeleteCapsule(capsuleId: capsule.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
