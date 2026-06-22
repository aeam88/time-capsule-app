import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/api_exception.dart';
import '../models/capsule_model.dart';

class CapsulesResult {
  final List<Capsule> capsules;
  final String? nextCursor;
  final bool hasMore;

  const CapsulesResult({
    required this.capsules,
    this.nextCursor,
    required this.hasMore,
  });
}

class CapsulesRepository {
  final Dio dio;

  CapsulesRepository({required this.dio});

  Future<CapsulesResult> getCapsules({
    String? status,
    String? search,
    String? cursor,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
      };
      if (status != null) queryParams['status'] = status;
      if (search != null) queryParams['search'] = search;
      if (cursor != null) queryParams['cursor'] = cursor;

      final response = await dio.get(
        ApiConstants.capsules,
        queryParameters: queryParams,
      );

      final data = response.data;
      final capsules = (data['data'] as List)
          .map((json) => Capsule.fromJson(json))
          .toList();

      return CapsulesResult(
        capsules: capsules,
        nextCursor: data['nextCursor'],
        hasMore: data['hasMore'] ?? false,
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException(
        message: e.message ?? 'Error al obtener cápsulas',
      );
    }
  }

  Future<Capsule> getCapsuleById(String id) async {
    try {
      final response = await dio.get(ApiConstants.capsuleById(id));
      return Capsule.fromJson(response.data);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException(
        message: e.message ?? 'Error al obtener cápsula',
      );
    }
  }

  Future<List<Capsule>> getSharedCapsules() async {
    try {
      final response = await dio.get(ApiConstants.sharedCapsules);
      final data = response.data;
      final list = data is List ? data : data['data'] as List? ?? [];
      return list.map((json) => Capsule.fromJson(json)).toList();
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException(
        message: e.message ?? 'Error al obtener cápsulas compartidas',
      );
    }
  }

  Future<Capsule> createCapsule({
    required String title,
    String? description,
    required DateTime unlockDate,
    bool isEncrypted = true,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.capsules,
        data: {
          'title': title,
          'description':? description,
          'unlockDate': unlockDate.toUtc().toIso8601String(),
          'isEncrypted': isEncrypted,
        },
      );
      return Capsule.fromJson(response.data);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException(
        message: e.message ?? 'Error al crear cápsula',
      );
    }
  }

  Future<Capsule> updateCapsule({
    required String id,
    String? title,
    String? description,
    DateTime? unlockDate,
    String? status,
  }) async {
    try {
      final response = await dio.patch(
        ApiConstants.capsuleById(id),
        data: {
          'title':? title,
          'description':? description,
          'unlockDate':? unlockDate?.toUtc().toIso8601String(),
          'status':? status,
        },
      );
      return Capsule.fromJson(response.data);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException(
        message: e.message ?? 'Error al actualizar cápsula',
      );
    }
  }

  Future<void> deleteCapsule(String id) async {
    try {
      await dio.delete(ApiConstants.capsuleById(id));
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException(
        message: e.message ?? 'Error al eliminar cápsula',
      );
    }
  }

  Future<Capsule> lockCapsule(String id) async {
    try {
      final response = await dio.post(ApiConstants.capsuleLock(id));
      return Capsule.fromJson(response.data);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException(
        message: e.message ?? 'Error al bloquear cápsula',
      );
    }
  }

  Future<Capsule> unlockCapsule(String id) async {
    try {
      final response = await dio.post(ApiConstants.capsuleUnlock(id));
      return Capsule.fromJson(response.data);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException(
        message: e.message ?? 'Error al desbloquear cápsula',
      );
    }
  }
}
