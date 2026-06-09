import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_selector/file_selector.dart';

class FileUploadButton extends StatelessWidget {
  final Function(String filePath, String fileName) onFileSelected;
  final bool enabled;

  const FileUploadButton({
    super.key,
    required this.onFileSelected,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: enabled ? () => _showUploadOptions(context) : null,
      icon: const Icon(Icons.add_photo_alternate_outlined),
      label: const Text('Agregar Archivo'),
    );
  }

  void _showUploadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Seleccionar archivo',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galería'),
              subtitle: const Text('Imágenes y videos'),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Cámara'),
              subtitle: const Text('Tomar foto o video'),
              onTap: () {
                Navigator.pop(context);
                _pickFromCamera(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: const Text('Archivo'),
              subtitle: const Text('PDF, documentos, texto'),
              onTap: () {
                Navigator.pop(context);
                _pickFile(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        onFileSelected(image.path, image.name);
        return;
      }

      final video = await picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        onFileSelected(video.path, video.name);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar archivo: $e')),
        );
      }
    }
  }

  Future<void> _pickFromCamera(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        onFileSelected(image.path, image.name);
        return;
      }

      final video = await picker.pickVideo(source: ImageSource.camera);
      if (video != null) {
        onFileSelected(video.path, video.name);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al tomar foto: $e')),
        );
      }
    }
  }

  Future<void> _pickFile(BuildContext context) async {
    try {
      final typeGroup = XTypeGroup(
        label: 'documents',
        extensions: ['pdf', 'doc', 'docx', 'txt'],
      );

      final file = await openFile(acceptedTypeGroups: [typeGroup]);

      if (file case final file?) {
        onFileSelected(file.path, file.name);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar archivo: $e')),
        );
      }
    }
  }
}
