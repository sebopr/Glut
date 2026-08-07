import 'dart:convert';
import 'package:http/http.dart' as http;

class FireDangerData {
  // level: 3 = restrictions, 4 = fire ban, 5 = total ban
  // 0 = no data for this canton (unknown)
  final int level;
  final String? canton;
  final String? region;
  final bool noDataForCanton; // true when canton not reported to BAFU

  const FireDangerData({
    required this.level,
    this.canton,
    this.region,
    this.noDataForCanton = false,
  });

  bool get isBanned => level >= 4;
  bool get isRestricted => level == 3;
  bool get hasWarning => level >= 3;
}

class FireDangerService {
  static const _measuresUrl =
      'https://www.waldbrandgefahr.ch/de/aktuelle-massnahmen.json';
  static const _dangerUrl =
      'https://www.waldbrandgefahr.ch/de/aktuelle-gefahrenlage.json';
  static const _reverseUrl = 'https://nominatim.openstreetmap.org/reverse';

  static Future<FireDangerData?> getDanger(double lat, double lng) async {
    try {
      final results = await Future.wait([
        _getCanton(lat, lng),
        _fetchJson(_measuresUrl),
        _fetchJson(_dangerUrl),
      ]);

      final canton = results[0] as String?;
      if (canton == null) return null;

      final measures = results[1] as List<dynamic>?;
      final dangers = results[2] as List<dynamic>?;

      final cantonNorm = _normalize(canton);

      // Check measures endpoint first (actual bans, field: category)
      FireDangerData? best;
      if (measures != null) {
        for (final raw in measures) {
          final e = raw as Map<String, dynamic>;
          if (_normalize(e['canton'] as String? ?? '') == cantonNorm) {
            final level = (e['category'] as num).toInt();
            final region = e['region'] as String?;
            if (best == null || level > best.level) {
              best = FireDangerData(level: level, canton: canton, region: region);
            }
          }
        }
      }

      // Also check danger level endpoint (field: level)
      if (dangers != null) {
        for (final raw in dangers) {
          final e = raw as Map<String, dynamic>;
          if (_normalize(e['canton'] as String? ?? '') == cantonNorm) {
            final level = (e['level'] as num).toInt();
            final region = e['region'] as String?;
            if (best == null || level > best.level) {
              best = FireDangerData(level: level, canton: canton, region: region);
            }
          }
        }
      }

      // Canton not reported to BAFU — flag it explicitly rather than showing "low danger"
      return best ?? FireDangerData(level: 0, canton: canton, noDataForCanton: true);
    } catch (_) {
      return null;
    }
  }

  static Future<String?> _getCanton(double lat, double lng) async {
    final uri = Uri.parse(_reverseUrl).replace(queryParameters: {
      'lat': lat.toString(),
      'lon': lng.toString(),
      'format': 'json',
      'zoom': '6',
      'addressdetails': '1',
    });
    final response = await http
        .get(uri, headers: {'User-Agent': 'GlutApp/1.0 (ch.thurlabs.glut)'})
        .timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) return null;
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['address'] as Map<String, dynamic>?)?['state'] as String?;
  }

  static Future<List<dynamic>?> _fetchJson(String url) async {
    try {
      final response = await http
          .get(Uri.parse(url), headers: {'User-Agent': 'GlutApp/1.0'})
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;
      return jsonDecode(response.body) as List<dynamic>;
    } catch (_) {
      return null;
    }
  }

  static String _normalize(String s) => s
      .toLowerCase()
      .trim()
      .replaceAll(RegExp(r'[-/]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ');
}
