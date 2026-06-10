import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/api_exception.dart';
import '../models/recipient_model.dart';

class AddRecipientsResult {
  final int addedCount;
  final int skippedCount;

  const AddRecipientsResult({required this.addedCount, required this.skippedCount});
}

class RecipientsRepository {
  final Dio dio;

  RecipientsRepository({required this.dio});

  Future<List<Recipient>> getRecipients(String capsuleId) async {
    try {
      final response = await dio.get(ApiConstants.capsuleRecipients(capsuleId));
      final data = response.data;
      final list = data is List ? data : data['data'] as List? ?? [];
      return list.map((json) => Recipient.fromJson(json)).toList();
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException(
        message: e.message ?? 'Error al obtener destinatarios',
      );
    }
  }

  Future<AddRecipientsResult> addRecipients({
    required String capsuleId,
    required List<String> emails,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.capsuleRecipients(capsuleId),
        data: {'emails': emails},
      );
      final data = response.data;
      final addedCount = (data['added'] as List?)?.length ?? 0;
      final skippedCount = (data['skipped'] as List?)?.length ?? 0;
      return AddRecipientsResult(addedCount: addedCount, skippedCount: skippedCount);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException(
        message: e.message ?? 'Error al agregar destinatarios',
      );
    }
  }

  Future<void> removeRecipient({
    required String capsuleId,
    required String recipientId,
  }) async {
    try {
      await dio.delete(ApiConstants.capsuleRecipient(capsuleId, recipientId));
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException(
        message: e.message ?? 'Error al eliminar destinatario',
      );
    }
  }

  Future<void> removeAllRecipients(String capsuleId) async {
    try {
      await dio.delete(ApiConstants.capsuleRecipients(capsuleId));
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException(
        message: e.message ?? 'Error al eliminar destinatarios',
      );
    }
  }
}
