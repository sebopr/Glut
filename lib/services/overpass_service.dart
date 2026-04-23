import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/spot.dart';

class OverpassService {
  static const _baseUrl = 'https://overpass.osm.ch/api/interpreter';

  static Future<List<Spot>> fetchSpots({
    required double lat,
    required double lng,
    double radiusMeters = 15000,
  }) async {
    final testResponse = await http.get(
      Uri.parse('https://overpass-api.de/api/status'),
    );
    print('🌐 API reachable: ${testResponse.statusCode}');
    print('🌐 API status: ${testResponse.body}');

    print('📍 Fetching spots at $lat, $lng within ${radiusMeters}m');

    final query =
        '''
[out:json][timeout:25];
(
  node["leisure"="firepit"](around:$radiusMeters,$lat,$lng);
  node["amenity"="bbq"](around:$radiusMeters,$lat,$lng);
  node["tourism"="picnic_site"]["fireplace"="yes"](around:$radiusMeters,$lat,$lng);
  node["fireplace"="yes"](around:$radiusMeters,$lat,$lng);
);
out body;
''';

    final uri = Uri.parse(_baseUrl).replace(queryParameters: {'data': query});

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: 'data=${Uri.encodeComponent(query)}',
    );
    print('📡 Overpass status: ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception('Overpass API error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final elements = data['elements'] as List<dynamic>;

    print('🔥 Found ${elements.length} spots');

    return elements
        .map((e) => Spot.fromOSM(e as Map<String, dynamic>))
        .toList();
  }
}
