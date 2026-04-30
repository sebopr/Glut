import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class PhotoService {
  static final _supabase = Supabase.instance.client;
  static const _bucket = 'spot-photos';
  static const _uuid = Uuid();

  static Future<List<String>> getPhotosForSpot(String spotId) async {
    try {
      // Get from database — only return URLs that actually exist
      final response = await _supabase
          .from('spot_photos')
          .select('url')
          .eq('spot_id', spotId)
          .order('uploaded_at', ascending: false)
          .limit(3); // never return more than 3

      return (response as List).map((e) => e['url'] as String).toList();
    } catch (e) {
      print('Get photos error: $e');
      return [];
    }
  }

  static Future<String?> uploadPhoto({
    required String spotId,
    required File imageFile,
    required String deviceId,
  }) async {
    try {
      // Check existing photo count
      final existing = await _supabase
          .from('spot_photos')
          .select('id')
          .eq('spot_id', spotId);

      if ((existing as List).length >= 3) {
        print('📸 Photo limit reached for spot: $spotId');
        return 'limit_reached';
      }
      print('📸 Starting upload for spot: $spotId');
      print('📸 File path: ${imageFile.path}');
      print('📸 File exists: ${imageFile.existsSync()}');

      final compressed = await FlutterImageCompress.compressWithFile(
        imageFile.path,
        minWidth: 1200,
        minHeight: 900,
        quality: 82,
        format: CompressFormat.jpeg,
      );

      print('📸 Compressed size: ${compressed?.length ?? 0} bytes');

      if (compressed == null) {
        print('📸 Compression failed');
        return null;
      }

      final fileName = '$spotId/${_uuid.v4()}.jpg';
      print('📸 Uploading to: $fileName');

      await _supabase.storage.from(_bucket).uploadBinary(fileName, compressed);

      print('📸 Upload complete');

      final url = _supabase.storage.from(_bucket).getPublicUrl(fileName);

      print('📸 Public URL: $url');

      await _supabase.from('spot_photos').insert({
        'spot_id': spotId,
        'url': url,
        'device_id': deviceId,
      });

      print('📸 DB insert complete');
      return url;
    } catch (e) {
      print('📸 Upload error: $e');
      return null;
    }
  }
}
