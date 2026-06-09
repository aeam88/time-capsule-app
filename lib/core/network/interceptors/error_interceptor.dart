import 'dart:developer';
import 'package:dio/dio.dart';
import '../../errors/api_exception.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;
    final data = err.response?.data;

    log('=== ERROR INTERCEPTOR ===');
    log('Type: ${err.type}');
    log('StatusCode: $statusCode');
    log('Error: ${err.error}');
    log('Message: ${err.message}');
    log('Response: $data');
    log('========================');

    if (statusCode != null) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: ApiException.fromResponse(statusCode, data),
          response: err.response,
          type: err.type,
        ),
      );
      return;
    }

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: ApiException(
              message: 'Tiempo de conexión agotado',
            ),
            type: err.type,
          ),
        );
        break;
      case DioExceptionType.connectionError:
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: ApiException(
              message: 'Error de conexión. Verifica que la API esté corriendo',
            ),
            type: err.type,
          ),
        );
        break;
      case DioExceptionType.badCertificate:
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: ApiException(message: 'Certificado SSL inválido'),
            type: err.type,
          ),
        );
        break;
      case DioExceptionType.cancel:
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: ApiException(message: 'Solicitud cancelada'),
            type: err.type,
          ),
        );
        break;
      case DioExceptionType.badResponse:
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: ApiException(
              message: 'Respuesta inválida del servidor',
            ),
            response: err.response,
            type: err.type,
          ),
        );
        break;
      case DioExceptionType.unknown:
        final errorMsg = err.error?.toString() ?? err.message ?? 'Error desconocido';
        log('UNKNOWN ERROR DETAIL: $errorMsg');
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: ApiException(message: errorMsg),
            type: err.type,
          ),
        );
        break;
    }
  }
}
