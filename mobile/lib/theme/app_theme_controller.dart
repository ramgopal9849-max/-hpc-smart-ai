import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppThemeController {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static final ValueNotifier<ThemeMode> mode =
      ValueNotifier<ThemeMode>(ThemeMode.system);

  static Future<void> load() async {
    try {
      final saved = await _storage.read(key: 'hpc_app_theme');

      switch (saved) {
        case 'light':
          mode.value = ThemeMode.light;
          break;
        case 'dark':
          mode.value = ThemeMode.dark;
          break;
        default:
          mode.value = ThemeMode.system;
      }
    } catch (e) {
      debugPrint('Theme loading error: $e');
    }
  }

  static Future<void> setMode(ThemeMode newMode) async {
    mode.value = newMode;

    final value = switch (newMode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };

    try {
      await _storage.write(key: 'hpc_app_theme', value: value);
    } catch (e) {
      debugPrint('Theme saving error: $e');
    }
  }
}
