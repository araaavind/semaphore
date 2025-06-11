import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // Session tracking
  static DateTime? _sessionStart;

  /// Initialize analytics
  static Future<void> initialize() async {
    // Disable analytics in debug mode
    if (kDebugMode) {
      await _analytics.setAnalyticsCollectionEnabled(false);
      print('Analytics disabled in debug mode');
    } else {
      await _analytics.setAnalyticsCollectionEnabled(true);
    }
  }

  /// Start session tracking
  static void startSession() {
    _sessionStart = DateTime.now();
  }

  /// End session and log time in app
  static Future<void> endSession() async {
    if (_sessionStart != null) {
      final duration = DateTime.now().difference(_sessionStart!);
      await _logEvent('session_duration', {
        'duration_minutes': duration.inMinutes,
        'duration_seconds': duration.inSeconds,
      });
      _sessionStart = null;
    }
  }

  // Authentication events
  static Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  static Future<void> logLogout() async {
    await _logEvent('logout');
  }

  // Feed management events
  static Future<void> logFeedFollowed(String feedId, String method) async {
    await _logEvent('feed_followed', {
      'feed_id': feedId,
      'method': method,
    });
  }

  static Future<void> logFeedRemoved(String feedId) async {
    await _logEvent('feed_removed', {
      'feed_id': feedId,
    });
  }

  // Wall events
  static Future<void> logWallCreated(String wallId) async {
    await _logEvent('wall_created', {
      'wall_id': wallId,
    });
  }

  static Future<void> logWallUpdated(String wallId) async {
    await _logEvent('wall_updated', {
      'wall_id': wallId,
    });
  }

  static Future<void> logWallRemoved(String wallId) async {
    await _logEvent('wall_removed', {
      'wall_id': wallId,
    });
  }

  static Future<void> logWallSelected(String wallId) async {
    await _logEvent('wall_selected', {
      'wall_id': wallId,
    });
  }

  static Future<void> logFeedAddedToWall(String wallId, String feedId) async {
    await _logEvent('feed_added_to_wall', {
      'wall_id': wallId,
      'feed_id': feedId,
    });
  }

  // Item interaction events
  static Future<void> logItemOpened(String itemId) async {
    await _logEvent('item_opened', {'item_id': itemId});
  }

  static Future<void> logItemSaved(String itemId) async {
    await _logEvent('item_saved', {'item_id': itemId});
  }

  static Future<void> logItemShared(String itemId) async {
    await _logEvent('item_shared', {
      'item_id': itemId,
    });
  }

  static Future<void> logItemLiked(String itemId) async {
    await _logEvent('item_liked', {
      'item_id': itemId,
    });
  }

  static Future<void> logWallDrawerOpened() async {
    await _logEvent('wall_drawer_opened');
  }

  static Future<void> logFilterDrawerOpened() async {
    await _logEvent('filter_drawer_opened');
  }

  // Helper method to log events with debug info
  static Future<void> _logEvent(String name,
      [Map<String, Object>? parameters]) async {
    if (kDebugMode) {
      print(
          'Analytics Event: $name${parameters != null ? ' - $parameters' : ''}');
    }
    await _analytics.logEvent(name: name, parameters: parameters);
  }
}
