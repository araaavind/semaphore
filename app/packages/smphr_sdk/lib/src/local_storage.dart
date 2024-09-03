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
  late final SharedPreferencesWithCache _prefsWithCache;

  SharedPreferencesLocalStorage({required this.persistSessionKey});

  final String persistSessionKey;

  @override
  Future<void> initialize() async {
    _prefsWithCache = await SharedPreferencesWithCache.create(
      cacheOptions: SharedPreferencesWithCacheOptions(),
    );
  }

  @override
  Future<bool> hasSession() async {
    return _prefsWithCache.containsKey(persistSessionKey);
  }

  @override
  Future<String?> getSession() async {
    return _prefsWithCache.getString(persistSessionKey);
  }

  @override
  Future<void> removeSession() async {
    await _prefsWithCache.remove(persistSessionKey);
  }

  @override
  Future<void> persistSession(String persistSessionString) {
    return _prefsWithCache.setString(persistSessionKey, persistSessionString);
  }
}
