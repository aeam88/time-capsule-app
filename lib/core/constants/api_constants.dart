import 'dart:io';

class ApiConstants {
  ApiConstants._();

  static final String baseUrl = _getBaseUrl();

  static String _getBaseUrl() {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api/v1';
    }
    return 'http://localhost:3000/api/v1';
  }

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String profile = '/auth/profile';

  // Capsules
  static const String capsules = '/capsules';
  static const String sharedCapsules = '/capsules/shared';

  static String capsuleById(String id) => '/capsules/$id';
  static String capsuleLock(String id) => '/capsules/$id/lock';
  static String capsuleUnlock(String id) => '/capsules/$id/unlock';

  // Files
  static String capsuleFiles(String id) => '/capsules/$id/files';
  static String capsuleFile(String capsuleId, String fileId) =>
      '/capsules/$capsuleId/files/$fileId';

  // Recipients
  static String capsuleRecipients(String id) => '/capsules/$id/recipients';
  static String capsuleRecipient(String capsuleId, String recipientId) =>
      '/capsules/$capsuleId/recipients/$recipientId';

  // Storage
  static const String storageUpload = '/storage/upload';
  static String storageDownload(String key) => '/storage/download/$key';
  static String storageDelete(String key) => '/storage/$key';

  // Settings
  static const String settings = '/settings';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration uploadTimeout = Duration(seconds: 120);
}
