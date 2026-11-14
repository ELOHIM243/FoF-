import 'package:flutter/material.dart';
import '../storage/local_storage.dart';

class AppState extends ChangeNotifier {
  final LocalStorage _storage;
  AppState(this._storage);

  bool _isLoggedIn = false;
  String _userName = '';
  String _userPhone = '';
  Locale _locale = const Locale('fr');
  ThemeMode _themeMode = ThemeMode.system;

  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String get userPhone => _userPhone;
  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;
  LocalStorage get storage => _storage;

  void init() {
    _isLoggedIn = _storage.isLoggedIn;
    _userName = _storage.userName;
    _userPhone = _storage.userPhone;
    _locale = Locale(_storage.localeCode);
    final t = _storage.themeModeStr;
    _themeMode = t == 'light' ? ThemeMode.light : (t == 'dark' ? ThemeMode.dark : ThemeMode.system);
    notifyListeners();
  }

  Future<void> login(String name, String phone) async {
    _isLoggedIn = true;
    _userName = name;
    _userPhone = phone;
    await _storage.setLoggedIn(true);
    await _storage.setUserName(name);
    await _storage.setUserPhone(phone);
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    await _storage.setLoggedIn(false);
    notifyListeners();
  }

  Future<void> setLocale(Locale l) async {
    _locale = l;
    await _storage.setLocaleCode(l.languageCode);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode m) async {
    _themeMode = m;
    await _storage.setThemeMode(m.name);
    notifyListeners();
  }
}
