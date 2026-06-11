import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/api_exception.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

class AuthRepository {
  final Dio dio;

  AuthRepository({required this.dio});

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );
      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromResponse(
        e.response?.statusCode ?? 500,
        e.response?.data,
      );
    }
  }

  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.register,
        data: {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
        },
      );
      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromResponse(
        e.response?.statusCode ?? 500,
        e.response?.data,
      );
    }
  }

  Future<void> logout(String refreshToken) async {
    try {
      await dio.post(
        ApiConstants.logout,
        data: {'refreshToken': refreshToken},
      );
    } on DioException catch (e) {
      throw ApiException.fromResponse(
        e.response?.statusCode ?? 500,
        e.response?.data,
      );
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await dio.post(
        ApiConstants.forgotPassword,
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw ApiException.fromResponse(
        e.response?.statusCode ?? 500,
        e.response?.data,
      );
    }
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await dio.post(
        ApiConstants.resetPassword,
        data: {
          'token': token,
          'newPassword': newPassword,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromResponse(
        e.response?.statusCode ?? 500,
        e.response?.data,
      );
    }
  }

  Future<UserModel> getProfile() async {
    try {
      final response = await dio.get(ApiConstants.profile);
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromResponse(
        e.response?.statusCode ?? 500,
        e.response?.data,
      );
    }
  }

  Future<UserModel> updateProfile({
    String? firstName,
    String? lastName,
  }) async {
    try {
      final response = await dio.patch(
        ApiConstants.profile,
        data: {
          'firstName':? firstName,
          'lastName':? lastName,
        },
      );
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromResponse(
        e.response?.statusCode ?? 500,
        e.response?.data,
      );
    }
  }
}
