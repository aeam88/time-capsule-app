import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../capsules/data/models/file_asset_model.dart';

class FilesRepository {
  final Dio dio;

  FilesRepository({required this.dio});

  static const _allowedMimeTypes = [
    'image/jpeg',
    'image/png',
    'image/gif',
    'image/webp',
    'video/mp4',
    'video/quicktime',
    'video/webm',
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'text/plain',
  ];

  Future<List<FileAsset>> getFiles(String capsuleId) async {
    try {
      final response = await dio.get(ApiConstants.capsuleFiles(capsuleId));
      final data = response.data;
      final filesList = data is List ? data : data['data'] as List? ?? [];
      return filesList
          .map((json) => FileAsset.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException(
        message: e.message ?? 'Error al obtener archivos',
      );
    }
  }

  Future<FileAsset> uploadFile({
    required String capsuleId,
    required String filePath,
    required String fileName,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final extension = fileName.split('.').last.toLowerCase();
      final mimeType = _getMimeType(extension);

      if (!_allowedMimeTypes.contains(mimeType)) {
        throw ApiException(
          message: 'Tipo de archivo no permitido: $extension',
        );
      }

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
      });

      final response = await dio.post(
        ApiConstants.capsuleFiles(capsuleId),
        data: formData,
        onSendProgress: onSendProgress,
        options: Options(
          receiveTimeout: ApiConstants.uploadTimeout,
          sendTimeout: ApiConstants.uploadTimeout,
        ),
      );

      return FileAsset.fromJson(response.data as Map<String, dynamic>);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException(
        message: e.message ?? 'Error al subir archivo',
      );
    }
  }

  Future<void> deleteFile({
    required String capsuleId,
    required String fileId,
  }) async {
    try {
      await dio.delete(ApiConstants.capsuleFile(capsuleId, fileId));
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException(
        message: e.message ?? 'Error al eliminar archivo',
      );
    }
  }

  String _getMimeType(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'webm':
        return 'video/webm';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }
}
