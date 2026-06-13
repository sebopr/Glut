import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class NominatimService {
  static const _baseUrl = 'https://api3.geo.admin.ch/rest/services/api/SearchServer';

  static Future<List<NominatimResult>> search(String query) async {
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'searchText': query,
        'type': 'locations',
        'limit': '5',
        'lang': 'de',
        'sr': '4326',
      },
    );

    final response = await http.get(uri, headers: {
      'User-Agent': 'GlutApp/1.0',
    });

    if (response.statusCode != 200) {
      throw Exception('Geocoder error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>;
    return results
        .map((e) => NominatimResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

class NominatimResult {
  final String displayName;
  final LatLng position;

  NominatimResult({required this.displayName, required this.position});

  factory NominatimResult.fromJson(Map<String, dynamic> json) {
    final attrs = json['attrs'] as Map<String, dynamic>;
    return NominatimResult(
      displayName: attrs['detail'] as String,
      position: LatLng(
        (attrs['lat'] as num).toDouble(),
        (attrs['lon'] as num).toDouble(),
      ),
    );
  }

  // Strip HTML tags from label for short display
  String get shortName {
    final label = displayName.split(' <').first.trim();
    return label.isNotEmpty ? label : displayName.split(',').first.trim();
  }
}
