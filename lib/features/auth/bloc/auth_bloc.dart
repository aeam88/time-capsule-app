import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/errors/api_exception.dart';
import '../data/repositories/auth_repository.dart';
import '../data/models/user_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthBloc({required this.authRepository})
      : super(const AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    on<UpdateProfileRequested>(_onUpdateProfile);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final token = await _storage.read(key: 'access_token');
      if (token != null) {
        final user = await authRepository.getProfile();
        emit(Authenticated(user: user));
      } else {
        emit(const Unauthenticated());
      }
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await _storage.deleteAll();
        emit(const Unauthenticated());
      } else {
        emit(AuthError(message: e.message));
      }
    } catch (_) {
      await _storage.deleteAll();
      emit(const Unauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final response = await authRepository.login(
        email: event.email,
        password: event.password,
      );
      await _storage.write(key: 'access_token', value: response.accessToken);
      await _storage.write(key: 'refresh_token', value: response.refreshToken);
      await _storage.write(
        key: 'user_data',
        value: response.user.toJson().toString(),
      );
      emit(Authenticated(user: response.user));
    } on ApiException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(AuthError(message: 'Error inesperado: $e'));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final response = await authRepository.register(
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
      );
      await _storage.write(key: 'access_token', value: response.accessToken);
      await _storage.write(key: 'refresh_token', value: response.refreshToken);
      await _storage.write(
        key: 'user_data',
        value: response.user.toJson().toString(),
      );
      emit(Authenticated(user: response.user));
    } on ApiException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(AuthError(message: 'Error inesperado: $e'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken != null) {
        await authRepository.logout(refreshToken);
      }
    } catch (_) {
      // Continue with logout even if API call fails
    } finally {
      await _storage.deleteAll();
      emit(const Unauthenticated());
    }
  }

  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await authRepository.forgotPassword(event.email);
      emit(const PasswordResetSent());
    } on ApiException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(AuthError(message: 'Error inesperado: $e'));
    }
  }

  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await authRepository.resetPassword(
        token: event.token,
        newPassword: event.newPassword,
      );
      emit(const PasswordResetSuccess());
    } on ApiException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(AuthError(message: 'Error inesperado: $e'));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = await authRepository.updateProfile(
        firstName: event.firstName,
        lastName: event.lastName,
      );
      emit(Authenticated(user: user));
    } on ApiException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(AuthError(message: 'Error inesperado: $e'));
    }
  }

  UserModel? get currentUser {
    final currentState = state;
    if (currentState is Authenticated) {
      return currentState.user;
    }
    return null;
  }
}
