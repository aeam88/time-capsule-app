import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/shimmer_widget.dart';
import '../../bloc/capsules_bloc.dart';
import '../../bloc/capsules_event.dart';
import '../../bloc/capsules_state.dart';
import '../../data/models/capsule_model.dart';

class SharedCapsulesScreen extends StatefulWidget {
  const SharedCapsulesScreen({super.key});

  @override
  State<SharedCapsulesScreen> createState() => _SharedCapsulesScreenState();
}

class _SharedCapsulesScreenState extends State<SharedCapsulesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CapsulesBloc>().add(const LoadSharedCapsules());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cápsulas Compartidas'),
      ),
      body: BlocBuilder<CapsulesBloc, CapsulesState>(
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
                    onPressed: () => context.read<CapsulesBloc>().add(const LoadSharedCapsules()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is CapsulesLoaded) {
            if (state.capsules.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'Sin cápsulas compartidas',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Las cápsulas desbloqueadas donde seas destinatario\naparecerán aquí',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<CapsulesBloc>().add(const LoadSharedCapsules());
                await context.read<CapsulesBloc>().stream.firstWhere(
                      (s) => s is CapsulesLoaded || s is CapsulesError,
                    );
              },
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                itemCount: state.capsules.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final capsule = state.capsules[index];
                  return _buildSharedCapsuleCard(context, capsule);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSharedCapsuleCard(BuildContext context, Capsule capsule) {
    return GestureDetector(
      onTap: () => context.push('/capsules/${capsule.id}'),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.withAlpha(51)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withAlpha(128)),
                    ),
                    child: const Text(
                      'Compartida',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (capsule.description != null && capsule.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  capsule.description!,
                  style: TextStyle(color: Colors.grey.shade600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    'Desbloqueo: ${capsule.unlockDate.day}/${capsule.unlockDate.month}/${capsule.unlockDate.year}',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                  const Spacer(),
                  if (capsule.fileCount > 0) ...[
                    Icon(Icons.attach_file, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 2),
                    Text(
                      '${capsule.fileCount} archivos',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
