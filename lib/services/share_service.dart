import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';
import '../models/spot.dart';

class ShareService {
  static Future<void> shareSpot(Spot spot, {BuildContext? context}) async {
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

    Rect? origin;
    if (context != null) {
      final box = context.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        origin = box.localToGlobal(Offset.zero) & box.size;
      }
    }

    await SharePlus.instance.share(
      ShareParams(text: text.trim(), subject: name, sharePositionOrigin: origin),
    );
  }
}
