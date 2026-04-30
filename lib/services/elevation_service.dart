import 'dart:convert';
import 'package:http/http.dart' as http;

class ElevationService {
  static Future<int?> getElevation(double lat, double lng) async {
    try {
      final uri = Uri.parse(
        'https://api.open-meteo.com/v1/elevation?latitude=$lat&longitude=$lng',
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final elevations = data['elevation'] as List<dynamic>;
      if (elevations.isEmpty) return null;

      return (elevations[0] as num).toInt();
    } catch (e) {
      print('Elevation error: $e');
      return null;
    }
  }
}
