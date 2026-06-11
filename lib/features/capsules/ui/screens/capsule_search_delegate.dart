import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/capsules_bloc.dart';
import '../../bloc/capsules_event.dart';
import '../../bloc/capsules_state.dart';
import '../../data/models/capsule_model.dart';

class CapsuleSearchDelegate extends SearchDelegate<String?> {
  @override
  String get searchFieldLabel => 'Buscar cápsulas...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isEmpty) {
      return const Center(child: Text('Escribe para buscar'));
    }

    context.read<CapsulesBloc>().add(SearchCapsules(query: query.trim()));

    return BlocBuilder<CapsulesBloc, CapsulesState>(
      builder: (context, state) {
        if (state is CapsulesLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is CapsulesLoaded) {
          if (state.capsules.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Sin resultados para "$query"',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ],
              ),
            );
          }
          return _buildResultsList(context, state.capsules);
        }

        return const SizedBox.shrink();
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.trim().isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey.shade200),
            const SizedBox(height: 16),
            Text(
              'Busca por título o descripción',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return buildResults(context);
  }

  Widget _buildResultsList(BuildContext context, List<Capsule> capsules) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: capsules.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final capsule = capsules[index];
        final statusColor = _getStatusColor(capsule.statusString);
        return ListTile(
          onTap: () {
            close(context, null);
            context.push('/capsules/${capsule.id}');
          },
          title: Text(
            capsule.title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: capsule.description != null && capsule.description!.isNotEmpty
              ? Text(
                  capsule.description!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              capsule.statusString,
              style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
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
