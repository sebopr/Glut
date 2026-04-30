import 'package:share_plus/share_plus.dart';
import '../models/spot.dart';

class ShareService {
  static Future<void> shareSpot(Spot spot) async {
    final name = spot.name;
    final lat = spot.lat.toStringAsFixed(6);
    final lng = spot.lng.toStringAsFixed(6);
    final distance = spot.distanceKm != null
        ? '${spot.distanceKm!.toStringAsFixed(1)} km away'
        : '';

    final amenities = [
      if (spot.hasWood) 'Wood',
      if (spot.hasGrill) 'Grill',
      if (spot.hasShelter) 'Shelter',
      if (spot.isAccessible) 'Accessible',
    ].join(' · ');

    final text =
        '''
🔥 $name
${distance.isNotEmpty ? '📍 $distance' : ''}
${amenities.isNotEmpty ? '✓ $amenities' : ''}

🗺 Open in Maps:
https://maps.google.com/?q=$lat,$lng

Found with Glut — find fire spots near you
''';

    await Share.share(text.trim(), subject: name);
  }
}
