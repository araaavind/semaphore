import 'package:app/features/feed/presentation/bloc/walls/walls_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A service class to manage user preferences
class UserPreferencesService {
  final SharedPreferencesWithCache _preferences;

  // Keys for storing preferences
  static const String _defaultWallSortKey = 'default_wall_sort';
  static const String _defaultWallViewKey = 'default_wall_view';

  UserPreferencesService(this._preferences);

  /// Sets the default wall sort option
  Future<void> setDefaultWallSort(WallSortOption sortOption) async {
    await _preferences.setString(_defaultWallSortKey, sortOption.name);
  }

  /// Gets the default wall sort option
  /// Returns null if no default is set
  WallSortOption? getDefaultWallSort() {
    final sortName = _preferences.getString(_defaultWallSortKey);
    if (sortName == null) return null;

    try {
      return WallSortOption.values.firstWhere(
        (option) => option.name.toLowerCase() == sortName.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Sets the default wall view option
  Future<void> setDefaultWallView(WallViewOption viewOption) async {
    await _preferences.setString(_defaultWallViewKey, viewOption.name);
  }

  /// Gets the default wall view option
  /// Returns null if no default is set
  WallViewOption? getDefaultWallView() {
    final viewName = _preferences.getString(_defaultWallViewKey);
    if (viewName == null) return null;

    try {
      return WallViewOption.values.firstWhere(
        (option) => option.name.toLowerCase() == viewName.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Clear all user preferences
  Future<void> clearAllPreferences() async {
    await _preferences.remove(_defaultWallSortKey);
    await _preferences.remove(_defaultWallViewKey);
  }
}
