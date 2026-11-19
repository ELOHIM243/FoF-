
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../storage/local_storage.dart';

class AppState extends ChangeNotifier {
  final LocalStorage _storage;
  final SupabaseClient _supabase = Supabase.instance.client;

  StreamSubscription<AuthState>? _authSubscription;

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
    _loadPreferences();

    _updateSession(_supabase.auth.currentSession);

    _authSubscription =
        _supabase.auth.onAuthStateChange.listen((data) {
      _updateSession(data.session);
    });
  }

  void _loadPreferences() {
    _locale = Locale(_storage.localeCode);

    final theme = _storage.themeModeStr;
    _themeMode = theme == 'light'
        ? ThemeMode.light
        : theme == 'dark'
            ? ThemeMode.dark
            : ThemeMode.system;
  }

  void _updateSession(Session? session) {
    _isLoggedIn = session != null;

    final email = session?.user.email ?? '';
    _userName = email.isNotEmpty ? email : '';
    _userPhone = '';

    notifyListeners();
  }

  // Compatibilité avec l'ancien écran de profil.
  // Cette méthode ne crée pas de session artificielle.
  Future<void> login(String name, String phone) async {
    if (_supabase.auth.currentUser == null) {
      throw StateError('Aucun utilisateur Supabase connecté.');
    }

    _userName = name;
    _userPhone = phone;
    notifyListeners();
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await _storage.setLocaleCode(locale.languageCode);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _storage.setThemeMode(mode.name);
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
