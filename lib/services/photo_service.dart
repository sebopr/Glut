import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class PhotoService {
  static final _supabase = Supabase.instance.client;
  static const _bucket = 'spot-photos';
  static const _uuid = Uuid();

  static Future<List<String>> getApprovedPhotos(String spotId) async {
    try {
      final response = await _supabase
          .from('spot_photos')
          .select('url')
          .eq('spot_id', spotId)
          .eq('status', 'approved')
          .order('uploaded_at', ascending: false)
          .limit(3);
      return (response as List).map((e) => e['url'] as String).toList();
    } catch (e) {
      debugPrint('PhotoService.getApprovedPhotos: $e');
      return [];
    }
  }

  static Future<List<String>> getMyPendingPhotos(
      String spotId, String deviceId) async {
    try {
      final response = await _supabase
          .from('spot_photos')
          .select('url')
          .eq('spot_id', spotId)
          .eq('device_id', deviceId)
          .eq('status', 'pending')
          .order('uploaded_at', ascending: false);
      return (response as List).map((e) => e['url'] as String).toList();
    } catch (e) {
      debugPrint('PhotoService.getMyPendingPhotos: $e');
      return [];
    }
  }

  static Future<bool> reportPhoto({
    required String spotId,
    required String photoUrl,
    required String deviceId,
  }) async {
    try {
      await _supabase.from('photo_reports').insert({
        'spot_id': spotId,
        'photo_url': photoUrl,
        'device_id': deviceId,
      });
      return true;
    } catch (e) {
      debugPrint('PhotoService.reportPhoto: $e');
      return false;
    }
  }

  // Throws on any failure so the caller can surface the real error.
  static Future<String?> uploadPhoto({
    required String spotId,
    required File imageFile,
    required String deviceId,
    required double spotLat,
    required double spotLng,
    double? photoLat,
    double? photoLng,
  }) async {
    debugPrint('📸 [1] count check');
    final existing = await _supabase
        .from('spot_photos')
        .select('id')
        .eq('spot_id', spotId)
        .neq('status', 'rejected');
    debugPrint('📸 [2] count=${(existing as List).length}');
    if (existing.length >= 3) return 'limit_reached';

    debugPrint('📸 [3] compressing');
    final compressed = await FlutterImageCompress.compressWithFile(
      imageFile.path,
      minWidth: 1200,
      minHeight: 900,
      quality: 82,
      format: CompressFormat.jpeg,
    );
    debugPrint('📸 [4] compressed=${compressed?.length ?? 0} bytes');
    if (compressed == null) throw Exception('Image compression failed');

    debugPrint('📸 [5] uploading to storage');
    final fileName = '$spotId/${_uuid.v4()}.jpg';
    await _supabase.storage.from(_bucket).uploadBinary(fileName, compressed);
    final url = _supabase.storage.from(_bucket).getPublicUrl(fileName);
    debugPrint('📸 [6] storage done — url=$url');

    debugPrint('📸 [7] inserting to DB');
    await _supabase.from('spot_photos').insert({
      'spot_id': spotId,
      'url': url,
      'device_id': deviceId,
      'status': 'pending',
      'spot_lat': spotLat,
      'spot_lng': spotLng,
      'photo_lat': photoLat,
      'photo_lng': photoLng,
    });
    debugPrint('📸 [8] done');

    return url;
  }

  static Future<List<Map<String, dynamic>>> getPendingPhotos() async {
    try {
      final response = await _supabase
          .from('spot_photos')
          .select('id, spot_id, url, uploaded_at, photo_lat, photo_lng, spot_lat, spot_lng')
          .eq('status', 'pending')
          .order('uploaded_at', ascending: true);
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('PhotoService.getPendingPhotos: $e');
      return [];
    }
  }

  static Future<bool> reviewPhoto({
    required String photoId,
    required bool approve,
  }) async {
    try {
      await _supabase
          .from('spot_photos')
          .update({'status': approve ? 'approved' : 'rejected'})
          .eq('id', photoId);
      return true;
    } catch (e) {
      debugPrint('PhotoService.reviewPhoto: $e');
      return false;
    }
  }
}
