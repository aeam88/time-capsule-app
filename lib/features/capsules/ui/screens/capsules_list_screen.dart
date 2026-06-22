import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/pill_filter_button.dart';
import '../../../../shared/widgets/shimmer_widget.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../auth/bloc/auth_state.dart';
import '../../bloc/capsules_bloc.dart';
import '../../bloc/capsules_event.dart';
import '../../bloc/capsules_state.dart';
import '../../data/models/capsule_model.dart';
import '../widgets/create_capsule_bottom_sheet.dart';
import 'capsule_search_delegate.dart';
import '../../../../app.dart';

class CapsulesListScreen extends StatefulWidget {
  const CapsulesListScreen({super.key});

  @override
  State<CapsulesListScreen> createState() => _CapsulesListScreenState();
}

class _CapsulesListScreenState extends State<CapsulesListScreen> with RouteAware {
  String _currentFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CapsulesBloc>().add(const LoadCapsules());
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    if (mounted) {
      context.read<CapsulesBloc>().add(const LoadCapsules());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Mis Cápsulas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline),
            onPressed: () => context.push('/capsules/shared'),
            tooltip: 'Compartidas',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CapsuleSearchDelegate(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildFilters(),
          const SizedBox(height: 24),
          Expanded(
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is Authenticated) {
                  return _buildContent(context, authState);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCreateCapsuleBottomSheet(context),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          PillFilterButton(
            label: 'All',
            isSelected: _currentFilter == 'All',
            onTap: () {
              setState(() => _currentFilter = 'All');
              context.read<CapsulesBloc>().add(
                const FilterCapsulesByStatus(status: null),
              );
            },
          ),
          const SizedBox(width: 8),
          PillFilterButton(
            label: 'Locked',
            isSelected: _currentFilter == 'Locked',
            onTap: () {
              setState(() => _currentFilter = 'Locked');
              context.read<CapsulesBloc>().add(
                const FilterCapsulesByStatus(status: 'LOCKED'),
              );
            },
          ),
          const SizedBox(width: 8),
          PillFilterButton(
            label: 'Unlocked',
            isSelected: _currentFilter == 'Unlocked',
            onTap: () {
              setState(() => _currentFilter = 'Unlocked');
              context.read<CapsulesBloc>().add(
                const FilterCapsulesByStatus(status: 'UNLOCKED'),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, Authenticated authState) {
    return BlocConsumer<CapsulesBloc, CapsulesState>(
      listener: (context, state) {
        if (state is CapsuleOperationSuccess) {
          AppToast.show(context, message: state.message, type: ToastType.success);
        } else if (state is CapsulesError) {
          AppToast.show(context, message: state.message, type: ToastType.error);
        }
      },
      listenWhen: (prev, curr) => curr is CapsuleOperationSuccess || curr is CapsulesError,
      builder: (context, state) {
        if (state is CapsulesLoading) {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: 5,
            itemBuilder: (context, index) => const CapsuleCardShimmer(),
          );
        }

        if (state is CapsulesError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(state.message, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<CapsulesBloc>().add(const LoadCapsules()),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        if (state is CapsulesLoaded) {
          if (state.capsules.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: EmptyStateWidget(
                icon: Icons.access_time_filled_rounded,
                title: '¡Hola, ${authState.user.firstName ?? 'Usuario'}!',
                subtitle:
                    'Crea tu primera cápsula del tiempo para guardar recuerdos',
                actionLabel: 'Crear Cápsula',
                onAction: () => showCreateCapsuleBottomSheet(context),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<CapsulesBloc>().add(const LoadCapsules());
              await context.read<CapsulesBloc>().stream.firstWhere(
                    (s) => s is CapsulesLoaded || s is CapsulesError,
                  );
            },
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: state.capsules.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final capsule = state.capsules[index];
                return _buildCapsuleCard(context, capsule);
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCapsuleCard(BuildContext context, Capsule capsule) {
    final statusColor = _getStatusColor(capsule.statusString);

    return Dismissible(
      key: Key(capsule.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => _showDeleteDialog(context, capsule),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: () => context.push('/capsules/${capsule.id}'),
      onLongPress: () => _showCapsuleOptions(context, capsule),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.withAlpha(51)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      capsule.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withAlpha(128)),
                    ),
                    child: Text(
                      capsule.statusString,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (capsule.description != null &&
                  capsule.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  capsule.description!,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ] else ...[
                const SizedBox(height: 8),
                Text(
                  'Sin descripción',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    'Desbloqueo: ${capsule.unlockDate.day}/${capsule.unlockDate.month}/${capsule.unlockDate.year}',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  if (capsule.fileCount > 0) ...[
                    Icon(Icons.attach_file, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 2),
                    Text(
                      '${capsule.fileCount}',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (capsule.recipientCount > 0) ...[
                    Icon(Icons.people_outline, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 2),
                    Text(
                      '${capsule.recipientCount}',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  void _showCapsuleOptions(BuildContext context, Capsule capsule) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                capsule.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Divider(height: 1),
            if (capsule.status == CapsuleStatus.draft) ...[
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Editar'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/capsules/${capsule.id}/edit');
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('Bloquear'),
                onTap: () {
                  Navigator.pop(context);
                  _showLockDialog(context, capsule);
                },
              ),
            ],
            if (capsule.status == CapsuleStatus.locked &&
                capsule.unlockDate.isBefore(DateTime.now())) ...[
              ListTile(
                leading: const Icon(Icons.lock_open_outlined),
                title: const Text('Desbloquear'),
                onTap: () {
                  Navigator.pop(context);
                  _showUnlockDialog(context, capsule);
                },
              ),
            ],
            if (capsule.status != CapsuleStatus.unlocked) ...[
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteDialog(context, capsule);
                },
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showLockDialog(BuildContext context, Capsule capsule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bloquear Cápsula'),
        content: const Text(
          'Una vez bloqueada, no podrás editar ni eliminar hasta que sea desbloqueada.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CapsulesBloc>().add(LockCapsule(capsuleId: capsule.id));
            },
            child: const Text('Bloquear'),
          ),
        ],
      ),
    );
  }

  void _showUnlockDialog(BuildContext context, Capsule capsule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desbloquear Cápsula'),
        content: const Text(
          '¿Estás seguro de desbloquear esta cápsula? El contenido estará disponible inmediatamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CapsulesBloc>().add(UnlockCapsule(capsuleId: capsule.id));
            },
            child: const Text('Desbloquear'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteDialog(BuildContext context, Capsule capsule) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Cápsula'),
        content: Text('¿Eliminar "${capsule.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
              context.read<CapsulesBloc>().add(DeleteCapsule(capsuleId: capsule.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
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
