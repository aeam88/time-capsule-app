import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/files_bloc.dart';
import '../../bloc/files_event.dart';
import '../../bloc/files_state.dart';
import '../../../capsules/data/models/file_asset_model.dart';
import 'file_tile.dart';
import 'file_upload_button.dart';

class FileListSection extends StatelessWidget {
  final String capsuleId;
  final bool canUpload;

  const FileListSection({
    super.key,
    required this.capsuleId,
    this.canUpload = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FilesBloc, FilesState>(
      listener: (context, state) {
        if (state is FileOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is FilesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Archivos',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (state is FilesLoaded)
                      Text(
                        '${state.files.length}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildContent(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, FilesState state) {
    if (state is FilesLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state is FilesError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
              const SizedBox(height: 8),
              Text(state.message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  context.read<FilesBloc>().add(LoadFiles(capsuleId: capsuleId));
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is FileUploadProgress) {
      return _buildUploadProgress(context, state);
    }

    if (state is FilesLoaded) {
      if (state.files.isEmpty) {
        return _buildEmpty(context);
      }
      return _buildFileList(context, state.files);
    }

    return _buildEmpty(context);
  }

  Widget _buildEmpty(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.folder_open, size: 48, color: Colors.grey.shade300),
        const SizedBox(height: 8),
        Text(
          'Sin archivos',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          'Sube imágenes, videos o documentos',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
        if (canUpload) ...[
          const SizedBox(height: 16),
          FileUploadButton(
            onFileSelected: (filePath, fileName) {
              context.read<FilesBloc>().add(
                    UploadFile(
                      capsuleId: capsuleId,
                      filePath: filePath,
                      fileName: fileName,
                    ),
                  );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildUploadProgress(BuildContext context, FileUploadProgress state) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: state.progress,
          backgroundColor: Colors.grey.shade200,
        ),
        const SizedBox(height: 8),
        Text(
          'Subiendo ${state.fileName}... ${(state.progress * 100).toInt()}%',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildFileList(BuildContext context, List<FileAsset> files) {
    return Column(
      children: [
        ...files.map((file) => FileTile(
              file: file,
              onDelete: canUpload ? () => _showDeleteDialog(context, file) : null,
              showDelete: canUpload,
            )),
        if (canUpload) ...[
          const Divider(),
          FileUploadButton(
            onFileSelected: (filePath, fileName) {
              context.read<FilesBloc>().add(
                    UploadFile(
                      capsuleId: capsuleId,
                      filePath: filePath,
                      fileName: fileName,
                    ),
                  );
            },
          ),
        ],
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, FileAsset file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Archivo'),
        content: Text('¿Eliminar "${file.fileName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<FilesBloc>().add(
                    DeleteFile(
                      capsuleId: capsuleId,
                      fileId: file.id,
                    ),
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
