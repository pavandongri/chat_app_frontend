import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// Wraps [SharedPreferences] for non-sensitive local prefs (e.g. theme mode).
class SharedPreferencesService {
  SharedPreferencesService(this._prefs);

  final SharedPreferences _prefs;

  String? get themeMode => _prefs.getString(StorageKeys.themeMode);

  Future<void> setThemeMode(String mode) =>
      _prefs.setString(StorageKeys.themeMode, mode);

  String? get cachedUserJson => _prefs.getString(StorageKeys.cachedUser);

  Future<void> setCachedUserJson(String json) =>
      _prefs.setString(StorageKeys.cachedUser, json);

  Future<void> clearCachedUser() => _prefs.remove(StorageKeys.cachedUser);
}
