import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager {
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
  static const String _themeKey = "isDarkMode";

  static Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? false;
    themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  static Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (themeNotifier.value == ThemeMode.light) {
      themeNotifier.value = ThemeMode.dark;
      await prefs.setBool(_themeKey, true);
    } else {
      themeNotifier.value = ThemeMode.light;
      await prefs.setBool(_themeKey, false);
    }
  }

  static bool get isDark => themeNotifier.value == ThemeMode.dark;
}
