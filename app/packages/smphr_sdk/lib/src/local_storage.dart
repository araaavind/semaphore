import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalStorage {
  const LocalStorage();

  /// Initialize the storage to persist session.
  Future<void> initialize();

  /// Check if there is a persisted session.
  Future<bool> hasSession();

  /// Get the access token from the current persisted session.
  Future<String?> getSession();

  /// Remove the current persisted session.
  Future<void> removeSession();

  /// Persist a session in the device.
  Future<void> persistSession(String persistSessionString);
}

class SharedPreferencesLocalStorage extends LocalStorage {
  late final SharedPreferences _prefs;

  SharedPreferencesLocalStorage({required this.persistSessionKey});

  final String persistSessionKey;

  @override
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<bool> hasSession() async {
    return _prefs.containsKey(persistSessionKey);
  }

  @override
  Future<String?> getSession() async {
    return _prefs.getString(persistSessionKey);
  }

  @override
  Future<void> removeSession() async {
    await _prefs.remove(persistSessionKey);
  }

  @override
  Future<void> persistSession(String persistSessionString) {
    return _prefs.setString(persistSessionKey, persistSessionString);
  }
}
