import 'dart:io';
import 'package:android_id/android_id.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Resolves a device identifier that survives an app uninstall/reinstall,
/// so analytics and saved places can be tied back to the same device.
///
/// - iOS: a UUID kept in the Keychain, which iOS does not clear on uninstall.
/// - Android: ANDROID_ID, which is stable across uninstall/reinstall on the
///   same device (it only changes on factory reset).
/// - Other platforms (or if the above fails): falls back to the legacy
///   SharedPreferences-backed UUID, which does not survive a reinstall.
class DeviceIdService {
  static const _prefsKey = 'device_id';
  static const _secureStorageKey = 'device_id';
  static const _secureStorage = FlutterSecureStorage();

  static String? _cached;

  static Future<String> getDeviceId() async {
    if (_cached != null) return _cached!;

    String id;
    try {
      if (Platform.isIOS) {
        id = await _resolveIOSId();
      } else if (Platform.isAndroid) {
        id = await _resolveAndroidId();
      } else {
        id = await _resolveLegacyId();
      }
    } catch (e) {
      debugPrint('DeviceIdService: falling back to legacy id: $e');
      id = await _resolveLegacyId();
    }

    _cached = id;
    return id;
  }

  static Future<String> _resolveIOSId() async {
    final existing = await _secureStorage.read(key: _secureStorageKey);
    if (existing != null && existing.isNotEmpty) return existing;

    // Migrate an already-installed user's id so we don't fork their history
    // the first time this runs post-update.
    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getString(_prefsKey);
    final id = (legacy != null && legacy.isNotEmpty) ? legacy : const Uuid().v4();

    await _secureStorage.write(key: _secureStorageKey, value: id);
    return id;
  }

  static Future<String> _resolveAndroidId() async {
    final androidId = await const AndroidId().getId();
    if (androidId != null && androidId.isNotEmpty) return 'android_$androidId';
    return _resolveLegacyId();
  }

  static Future<String> _resolveLegacyId() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_prefsKey)) {
      await prefs.setString(_prefsKey, const Uuid().v4());
    }
    return prefs.getString(_prefsKey)!;
  }
}
