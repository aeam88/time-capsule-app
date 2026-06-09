import 'package:equatable/equatable.dart';

class FileAsset extends Equatable {
  final String id;
  final String fileName;
  final String mimeType;
  final int size;
  final String storageKey;
  final String? url;
  final DateTime createdAt;

  const FileAsset({
    required this.id,
    required this.fileName,
    required this.mimeType,
    required this.size,
    required this.storageKey,
    this.url,
    required this.createdAt,
  });

  factory FileAsset.fromJson(Map<String, dynamic> json) {
    return FileAsset(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      mimeType: json['mimeType'] as String,
      size: json['size'] as int,
      storageKey: json['storageKey'] as String,
      url: json['url'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  bool get isImage => mimeType.startsWith('image/');
  bool get isVideo => mimeType.startsWith('video/');
  bool get isPdf => mimeType == 'application/pdf';
  bool get isDocument => mimeType.contains('word') || mimeType == 'text/plain';

  @override
  List<Object?> get props => [id, fileName, mimeType, size, storageKey, url, createdAt];
}
