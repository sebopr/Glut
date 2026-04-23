import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter/services.dart';

class NominatimService {
  static const _baseUrl = 'https://nominatim.openstreetmap.org/search';

  static Future<List<NominatimResult>> search(String query) async {
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'q': query,
        'format': 'json',
        'limit': '5',
        'countrycodes': 'ch,de,at', // Switzerland, Germany, Austria
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'User-Agent': 'GlutApp/1.0 (fire spot finder; contact@yourmail.com)',
        'Accept-Language': 'de,en',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Nominatim error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => NominatimResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

class NominatimResult {
  final String displayName;
  final LatLng position;

  NominatimResult({required this.displayName, required this.position});

  factory NominatimResult.fromJson(Map<String, dynamic> json) {
    return NominatimResult(
      displayName: json['display_name'] as String,
      position: LatLng(
        double.parse(json['lat'] as String),
        double.parse(json['lon'] as String),
      ),
    );
  }

  // Short name — first part before the first comma
  String get shortName => displayName.split(',').first.trim();
}
