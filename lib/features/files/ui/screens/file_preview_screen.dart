import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../capsules/data/models/file_asset_model.dart';

class FilePreviewScreen extends StatelessWidget {
  final FileAsset file;

  const FilePreviewScreen({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          file.fileName,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          if (file.url != null) ...[
            IconButton(
              icon: const Icon(Icons.download_outlined),
              onPressed: () => _downloadFile(context),
            ),
            IconButton(
              icon: const Icon(Icons.open_in_browser),
              onPressed: () => _openInBrowser(context),
            ),
          ],
        ],
      ),
      body: _buildPreview(context),
    );
  }

  Widget _buildPreview(BuildContext context) {
    if (file.isImage && file.url != null) {
      return _buildImagePreview(context);
    }

    return _buildFilePlaceholder(context);
  }

  Widget _buildImagePreview(BuildContext context) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: CachedNetworkImage(
          imageUrl: file.url!,
          fit: BoxFit.contain,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                const Text('Error al cargar imagen'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilePlaceholder(BuildContext context) {
    final iconData = _getFileIcon();
    final iconColor = _getFileColor();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: iconColor.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(
              iconData,
              size: 60,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            file.fileName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            file.formattedSize,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 24),
          if (file.url != null)
            ElevatedButton.icon(
              onPressed: () => _openInBrowser(context),
              icon: const Icon(Icons.open_in_browser),
              label: const Text('Abrir en navegador'),
            ),
        ],
      ),
    );
  }

  IconData _getFileIcon() {
    if (file.isImage) return Icons.image_outlined;
    if (file.isVideo) return Icons.video_file_outlined;
    if (file.isPdf) return Icons.picture_as_pdf_outlined;
    return Icons.insert_drive_file_outlined;
  }

  Color _getFileColor() {
    if (file.isImage) return Colors.blue;
    if (file.isVideo) return Colors.purple;
    if (file.isPdf) return Colors.red;
    return Colors.orange;
  }

  Future<void> _openInBrowser(BuildContext context) async {
    if (file.url == null) return;
    final uri = Uri.parse(file.url!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se puede abrir el archivo')),
        );
      }
    }
  }

  Future<void> _downloadFile(BuildContext context) async {
    if (file.url == null) return;

    final uri = Uri.parse(file.url!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Descargando archivo...')),
        );
      }
    }
  }
}
