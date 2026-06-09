import 'package:flutter/material.dart';
import '../../../capsules/data/models/file_asset_model.dart';

class FileTile extends StatelessWidget {
  final FileAsset file;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool showDelete;

  const FileTile({
    super.key,
    required this.file,
    this.onTap,
    this.onDelete,
    this.showDelete = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: _buildIcon(context),
      title: Text(
        file.fileName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        file.formattedSize,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
      ),
      trailing: showDelete && onDelete != null
          ? IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 20),
              onPressed: onDelete,
            )
          : null,
      onTap: onTap,
    );
  }

  Widget _buildIcon(BuildContext context) {
    final color = _getIconColor();
    final icon = _getIcon();

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  IconData _getIcon() {
    if (file.isImage) return Icons.image_outlined;
    if (file.isVideo) return Icons.videocam_outlined;
    if (file.isPdf) return Icons.picture_as_pdf_outlined;
    if (file.isDocument) return Icons.description_outlined;
    return Icons.insert_drive_file_outlined;
  }

  Color _getIconColor() {
    if (file.isImage) return Colors.blue;
    if (file.isVideo) return Colors.purple;
    if (file.isPdf) return Colors.red;
    if (file.isDocument) return Colors.blue.shade700;
    return Colors.orange;
  }
}
