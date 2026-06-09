import 'package:equatable/equatable.dart';

enum ContentType { text, image, video, file }

class CapsuleContent extends Equatable {
  final String id;
  final ContentType type;
  final String encryptedData;
  final DateTime createdAt;

  const CapsuleContent({
    required this.id,
    required this.type,
    required this.encryptedData,
    required this.createdAt,
  });

  factory CapsuleContent.fromJson(Map<String, dynamic> json) {
    return CapsuleContent(
      id: json['id'] as String,
      type: _parseType(json['type'] as String),
      encryptedData: json['encryptedData'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static ContentType _parseType(String type) {
    switch (type) {
      case 'TEXT':
        return ContentType.text;
      case 'IMAGE':
        return ContentType.image;
      case 'VIDEO':
        return ContentType.video;
      case 'FILE':
        return ContentType.file;
      default:
        return ContentType.text;
    }
  }

  @override
  List<Object?> get props => [id, type, encryptedData, createdAt];
}
