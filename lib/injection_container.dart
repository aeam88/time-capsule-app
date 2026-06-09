import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'core/network/api_client.dart';

class InjectionContainer {
  static final InjectionContainer _instance = InjectionContainer._internal();
  factory InjectionContainer() => _instance;
  InjectionContainer._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  ApiClient? _apiClient;

  FlutterSecureStorage get storage => _storage;

  ApiClient get apiClient {
    _apiClient ??= ApiClient();
    return _apiClient!;
  }

  Future<void> init() async {
    // Initialize any async dependencies here
    _apiClient = ApiClient();
  }

  Future<void> clear() async {
    await _storage.deleteAll();
    _apiClient = null;
  }
}
