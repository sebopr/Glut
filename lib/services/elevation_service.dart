import 'dart:convert';
import 'package:http/http.dart' as http;

class ElevationService {
  static Future<int?> getElevation(double lat, double lng) async {
    final uri = Uri.parse(
      'https://api.open-elevation.com/api/v1/lookup?locations=$lat,$lng',
    );

    try {
      final response = await http
          .get(
            uri,
            headers: {
              'User-Agent':
                  'GlutApp/1.0 (fire spot finder; contact@yourmail.com)',
            },
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;
      if (results.isEmpty) return null;

      return (results[0]['elevation'] as num).toInt();
    } catch (e) {
      return null;
    }
  }
}
