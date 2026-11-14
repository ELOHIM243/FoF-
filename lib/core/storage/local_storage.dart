import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  final SharedPreferences _prefs;
  LocalStorage(this._prefs);

  bool get isLoggedIn => _prefs.getBool('logged_in') ?? false;
  Future<void> setLoggedIn(bool v) => _prefs.setBool('logged_in', v);

  String get userName => _prefs.getString('user_name') ?? '';
  Future<void> setUserName(String v) => _prefs.setString('user_name', v);

  String get userPhone => _prefs.getString('user_phone') ?? '';
  Future<void> setUserPhone(String v) => _prefs.setString('user_phone', v);

  String get localeCode => _prefs.getString('locale') ?? 'fr';
  Future<void> setLocaleCode(String v) => _prefs.setString('locale', v);

  String get themeModeStr => _prefs.getString('theme_mode') ?? 'system';
  Future<void> setThemeMode(String v) => _prefs.setString('theme_mode', v);
}
