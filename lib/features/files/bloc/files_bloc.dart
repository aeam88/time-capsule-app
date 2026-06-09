import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/api_exception.dart';
import '../data/repositories/files_repository.dart';
import 'files_event.dart';
import 'files_state.dart';

class FilesBloc extends Bloc<FilesEvent, FilesState> {
  final FilesRepository repository;

  FilesBloc({required this.repository}) : super(const FilesInitial()) {
    on<LoadFiles>(_onLoadFiles);
    on<UploadFile>(_onUploadFile);
    on<DeleteFile>(_onDeleteFile);
    on<_UpdateUploadProgress>(_onUpdateUploadProgress);
  }

  Future<void> _onLoadFiles(
    LoadFiles event,
    Emitter<FilesState> emit,
  ) async {
    emit(const FilesLoading());
    try {
      final files = await repository.getFiles(event.capsuleId);
      emit(FilesLoaded(files: files));
    } on ApiException catch (e) {
      emit(FilesError(message: e.message));
    } catch (e) {
      emit(FilesError(message: 'Error inesperado: $e'));
    }
  }

  Future<void> _onUploadFile(
    UploadFile event,
    Emitter<FilesState> emit,
  ) async {
    emit(FileUploadProgress(progress: 0.0, fileName: event.fileName));
    try {
      await repository.uploadFile(
        capsuleId: event.capsuleId,
        filePath: event.filePath,
        fileName: event.fileName,
        onSendProgress: (sent, total) {
          if (total > 0) {
            final progress = sent / total;
            add(_UpdateUploadProgress(
              progress: progress,
              fileName: event.fileName,
            ));
          }
        },
      );
      emit(const FileOperationSuccess(message: 'Archivo subido exitosamente'));
      add(LoadFiles(capsuleId: event.capsuleId));
    } on ApiException catch (e) {
      emit(FilesError(message: e.message));
    } catch (e) {
      emit(FilesError(message: 'Error inesperado: $e'));
    }
  }

  void _onUpdateUploadProgress(
    _UpdateUploadProgress event,
    Emitter<FilesState> emit,
  ) {
    emit(FileUploadProgress(
      progress: event.progress,
      fileName: event.fileName,
    ));
  }

  Future<void> _onDeleteFile(
    DeleteFile event,
    Emitter<FilesState> emit,
  ) async {
    try {
      await repository.deleteFile(
        capsuleId: event.capsuleId,
        fileId: event.fileId,
      );
      emit(const FileOperationSuccess(message: 'Archivo eliminado exitosamente'));
      add(LoadFiles(capsuleId: event.capsuleId));
    } on ApiException catch (e) {
      emit(FilesError(message: e.message));
    } catch (e) {
      emit(FilesError(message: 'Error inesperado: $e'));
    }
  }
}

class _UpdateUploadProgress extends FilesEvent {
  final double progress;
  final String fileName;

  const _UpdateUploadProgress({
    required this.progress,
    required this.fileName,
  });

  @override
  List<Object?> get props => [progress, fileName];
}
