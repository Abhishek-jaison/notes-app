import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<bool> {
  static const _themeKey = 'isDarkMode';
  late final SharedPreferences _prefs;

  ThemeNotifier() : super(false) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _prefs = await SharedPreferences.getInstance();
    state = _prefs.getBool(_themeKey) ?? false;
  }

  Future<void> toggleTheme() async {
    state = !state;
    await _prefs.setBool(_themeKey, state);
  }
}
