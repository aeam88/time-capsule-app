import 'package:equatable/equatable.dart';
import '../../capsules/data/models/file_asset_model.dart';

abstract class FilesState extends Equatable {
  const FilesState();

  @override
  List<Object?> get props => [];
}

class FilesInitial extends FilesState {
  const FilesInitial();
}

class FilesLoading extends FilesState {
  const FilesLoading();
}

class FilesLoaded extends FilesState {
  final List<FileAsset> files;

  const FilesLoaded({required this.files});

  @override
  List<Object?> get props => [files];
}

class FilesError extends FilesState {
  final String message;

  const FilesError({required this.message});

  @override
  List<Object?> get props => [message];
}

class FileUploadProgress extends FilesState {
  final double progress;
  final String fileName;

  const FileUploadProgress({
    required this.progress,
    required this.fileName,
  });

  @override
  List<Object?> get props => [progress, fileName];
}

class FileOperationSuccess extends FilesState {
  final String message;

  const FileOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}
