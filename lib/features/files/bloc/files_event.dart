import 'package:equatable/equatable.dart';

abstract class FilesEvent extends Equatable {
  const FilesEvent();

  @override
  List<Object?> get props => [];
}

class LoadFiles extends FilesEvent {
  final String capsuleId;

  const LoadFiles({required this.capsuleId});

  @override
  List<Object?> get props => [capsuleId];
}

class UploadFile extends FilesEvent {
  final String capsuleId;
  final String filePath;
  final String fileName;

  const UploadFile({
    required this.capsuleId,
    required this.filePath,
    required this.fileName,
  });

  @override
  List<Object?> get props => [capsuleId, filePath, fileName];
}

class DeleteFile extends FilesEvent {
  final String capsuleId;
  final String fileId;

  const DeleteFile({
    required this.capsuleId,
    required this.fileId,
  });

  @override
  List<Object?> get props => [capsuleId, fileId];
}
