import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ThemeCubit() : super(ThemeMode.light) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final theme = await _storage.read(key: 'theme_mode');
    if (theme == 'dark') {
      emit(ThemeMode.dark);
    } else if (theme == 'system') {
      emit(ThemeMode.system);
    } else {
      emit(ThemeMode.light);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    emit(mode);
    await _storage.write(key: 'theme_mode', value: mode.name);
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }
}
