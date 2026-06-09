import 'package:equatable/equatable.dart';

enum CapsuleStatus { draft, locked, unlocked, archived }

class Capsule extends Equatable {
  final String id;
  final String title;
  final String? description;
  final CapsuleStatus status;
  final DateTime unlockDate;
  final DateTime? unlockedAt;
  final bool isEncrypted;
  final int contentCount;
  final int fileCount;
  final int recipientCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Capsule({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.unlockDate,
    this.unlockedAt,
    required this.isEncrypted,
    this.contentCount = 0,
    this.fileCount = 0,
    this.recipientCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Capsule.fromJson(Map<String, dynamic> json) {
    return Capsule(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: _parseStatus(json['status'] as String),
      unlockDate: DateTime.parse(json['unlockDate'] as String),
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
      isEncrypted: json['isEncrypted'] as bool? ?? true,
      contentCount: json['contents']?.length ?? 0,
      fileCount: json['files']?.length ?? 0,
      recipientCount: json['recipients']?.length ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  static CapsuleStatus _parseStatus(String status) {
    switch (status) {
      case 'DRAFT':
        return CapsuleStatus.draft;
      case 'LOCKED':
        return CapsuleStatus.locked;
      case 'UNLOCKED':
        return CapsuleStatus.unlocked;
      case 'ARCHIVED':
        return CapsuleStatus.archived;
      default:
        return CapsuleStatus.draft;
    }
  }

  String get statusString {
    switch (status) {
      case CapsuleStatus.draft:
        return 'DRAFT';
      case CapsuleStatus.locked:
        return 'LOCKED';
      case CapsuleStatus.unlocked:
        return 'UNLOCKED';
      case CapsuleStatus.archived:
        return 'ARCHIVED';
    }
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        status,
        unlockDate,
        unlockedAt,
        isEncrypted,
        contentCount,
        fileCount,
        recipientCount,
        createdAt,
        updatedAt,
      ];
}
