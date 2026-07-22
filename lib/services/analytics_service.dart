import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class AnalyticsService {
  static final _db = Supabase.instance.client;

  static Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('device_id')) {
      await prefs.setString('device_id', const Uuid().v4());
    }
    return prefs.getString('device_id')!;
  }

  static Future<void> logSpotView(String spotId) async {
    try {
      final deviceId = await getDeviceId();
      await _db.from('spot_views').insert({
        'spot_id': spotId,
        'device_id': deviceId,
      });
    } catch (e) {
      debugPrint('Analytics.logSpotView: $e');
    }
  }

  static Future<void> logSearch(String query) async {
    if (query.trim().isEmpty) return;
    try {
      await _db.from('search_queries').insert({
        'query': query.trim().toLowerCase(),
      });
    } catch (e) {
      debugPrint('Analytics.logSearch: $e');
    }
  }

  static Future<void> logEvent(String name) async {
    try {
      await _db.from('analytics_events').insert({
        'event_name': name,
      });
    } catch (e) {
      debugPrint('Analytics.logEvent: $e');
    }
  }
}
