import 'package:shared_preferences/shared_preferences.dart';

/// Handles persisting the user's preferred theme mode.
/// Wrapped in a tiny service so the page widget doesn't deal with the
/// SharedPreferences API directly.
class ThemePreferenceService {
  static const _key = 'isDarkMode';

  Future<bool> loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  Future<void> saveThemePreference(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, isDarkMode);
  }
}
