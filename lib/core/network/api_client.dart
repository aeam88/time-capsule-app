import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';
import '../errors/api_exception.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';

class ApiClient {
  late final Dio _dio;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      AuthInterceptor(storage: _storage, dio: _dio),
      ErrorInterceptor(),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    ]);
  }

  Dio get dio => _dio;
  FlutterSecureStorage get storage => _storage;

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException(
        message: e.message ?? 'Error de conexión',
      );
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.post(path, data: data, queryParameters: queryParameters);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException(
        message: e.message ?? 'Error de conexión',
      );
    }
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.patch(path, data: data, queryParameters: queryParameters);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException(
        message: e.message ?? 'Error de conexión',
      );
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
  }) async {
    try {
      return await _dio.delete(path, data: data);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException(
        message: e.message ?? 'Error de conexión',
      );
    }
  }

  Future<Response> upload(
    String path, {
    required String filePath,
    required String fieldName,
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        ...?data,
        fieldName: await MultipartFile.fromFile(filePath),
      });
      return await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException(
        message: e.message ?? 'Error al subir archivo',
      );
    }
  }
}
