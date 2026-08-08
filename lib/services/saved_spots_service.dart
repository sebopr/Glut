import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/spot.dart';

/// Backs up a device's saved spots to Supabase, keyed by the persistent
/// device id, so they can be restored after an app uninstall/reinstall.
class SavedSpotsService {
  static final _db = Supabase.instance.client;

  static Future<List<Spot>> fetchSaved(String deviceId) async {
    try {
      final rows = await _db
          .from('saved_spots')
          .select('spot_json')
          .eq('device_id', deviceId);
      return (rows as List)
          .map((r) => Spot.fromJson(r['spot_json'] as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('SavedSpotsService.fetchSaved: $e');
      return [];
    }
  }

  static Future<void> save(String deviceId, Spot spot) async {
    try {
      await _db.from('saved_spots').upsert({
        'device_id': deviceId,
        'spot_id': spot.id,
        'spot_json': spot.toJson(),
      });
    } catch (e) {
      debugPrint('SavedSpotsService.save: $e');
    }
  }

  static Future<void> remove(String deviceId, String spotId) async {
    try {
      await _db
          .from('saved_spots')
          .delete()
          .eq('device_id', deviceId)
          .eq('spot_id', spotId);
    } catch (e) {
      debugPrint('SavedSpotsService.remove: $e');
    }
  }
}
