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

// Add to elevation_service.dart or create a new lib/services/coordinate_service.dart
class CoordinateService {
  // Convert WGS84 to Swiss LV95
  static Map<String, double> wgs84ToLV95(double lat, double lng) {
    // Convert degrees to seconds
    final latSec = lat * 3600;
    final lngSec = lng * 3600;

    // Auxiliary values
    final latAux = (latSec - 169028.66) / 10000;
    final lngAux = (lngSec - 26782.5) / 10000;

    // E (easting)
    final e =
        2600072.37 +
        211455.93 * lngAux -
        10938.51 * lngAux * latAux -
        0.36 * lngAux * latAux * latAux -
        44.54 * lngAux * lngAux * lngAux;

    // N (northing)
    final n =
        1200147.07 +
        308807.95 * latAux +
        3745.25 * lngAux * lngAux +
        76.63 * latAux * latAux -
        194.56 * lngAux * lngAux * latAux +
        119.79 * latAux * latAux * latAux;

    return {'e': e, 'n': n};
  }
}
