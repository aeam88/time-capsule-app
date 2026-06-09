class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final dynamic data;

  ApiException({
    this.statusCode,
    required this.message,
    this.data,
  });

  @override
  String toString() => 'ApiException($statusCode): $message';

  factory ApiException.fromResponse(int statusCode, dynamic data) {
    String message;

    switch (statusCode) {
      case 400:
        message = _extractMessage(data) ?? 'Solicitud inválida';
        break;
      case 401:
        message = 'No autorizado. Por favor, inicia sesión nuevamente';
        break;
      case 403:
        message = 'No tienes permiso para realizar esta acción';
        break;
      case 404:
        message = 'Recurso no encontrado';
        break;
      case 409:
        message = _extractMessage(data) ?? 'Conflicto con el estado actual';
        break;
      case 429:
        message = 'Demasiadas solicitudes. Intenta más tarde';
        break;
      case 500:
        message = 'Error interno del servidor';
        break;
      default:
        message = _extractMessage(data) ?? 'Error desconocido ($statusCode)';
    }

    return ApiException(
      statusCode: statusCode,
      message: message,
      data: data,
    );
  }

  static String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String?;
    }
    return null;
  }
}
