import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ValueNotifier<ThemeMode> {
  static const String _key = 'sonexa_theme_mode';

  ThemeController._internal()
      : super(ThemeMode.dark);

  static final ThemeController instance =
      ThemeController._internal();

  ThemeMode get themeMode => value;

  bool get isDark => value == ThemeMode.dark;

  bool get isLight => value == ThemeMode.light;

  bool get isSystem => value == ThemeMode.system;

  String get appearanceName {
    switch (value) {
      case ThemeMode.dark:
        return 'Dark';

      case ThemeMode.light:
        return 'Light';

      case ThemeMode.system:
        return 'System Default';
    }
  }

  Future<void> load() async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    final String savedMode =
        prefs.getString(_key) ?? 'dark';

    switch (savedMode) {
      case 'light':
        value = ThemeMode.light;
        break;

      case 'system':
        value = ThemeMode.system;
        break;

      case 'dark':
      default:
        value = ThemeMode.dark;
        break;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    value = mode;

    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    String modeName;

    switch (mode) {
      case ThemeMode.dark:
        modeName = 'dark';
        break;

      case ThemeMode.light:
        modeName = 'light';
        break;

      case ThemeMode.system:
        modeName = 'system';
        break;
    }

    await prefs.setString(
      _key,
      modeName,
    );
  }

  Future<void> setDarkMode(bool darkMode) async {
    await setThemeMode(
      darkMode
          ? ThemeMode.dark
          : ThemeMode.light,
    );
  }

  Future<void> toggle() async {
    if (value == ThemeMode.dark) {
      await setThemeMode(
        ThemeMode.light,
      );
    } else {
      await setThemeMode(
        ThemeMode.dark,
      );
    }
  }
}