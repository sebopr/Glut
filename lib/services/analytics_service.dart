import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'device_id_service.dart';

class AnalyticsService {
  static final _db = Supabase.instance.client;

  static Future<String> getDeviceId() => DeviceIdService.getDeviceId();

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
      final deviceId = await getDeviceId();
      await _db.from('search_queries').insert({
        'query': query.trim().toLowerCase(),
        'device_id': deviceId,
      });
    } catch (e) {
      debugPrint('Analytics.logSearch: $e');
    }
  }

  static Future<void> logEvent(String name) async {
    try {
      final deviceId = await getDeviceId();
      await _db.from('analytics_events').insert({
        'event_name': name,
        'device_id': deviceId,
      });
    } catch (e) {
      debugPrint('Analytics.logEvent: $e');
    }
  }
}
