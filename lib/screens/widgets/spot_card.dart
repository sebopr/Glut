import 'package:flutter/material.dart';
import '../../models/spot.dart';
import '../../theme.dart';

class SpotCard extends StatelessWidget {
  final Spot spot;
  final VoidCallback onTap;
  final bool highlighted;

  const SpotCard({
    super.key,
    required this.spot,
    required this.onTap,
    this.highlighted = false,
  });

  @override
Widget build(BuildContext context) {
  return SizedBox(
    height: 68,  // 76 - 8 margin
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
       
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: highlighted
              ? GlutTheme.ember.withOpacity(0.15)
              : GlutTheme.coal,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: highlighted ? GlutTheme.ember : Colors.white10,
            width: highlighted ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: GlutTheme.ash,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('🔥', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spot.name,
                    style: const TextStyle(
                      color: GlutTheme.linen,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (spot.hasWood) _Badge('Wood', true),
                      if (spot.hasWood) const SizedBox(width: 4),
                      if (spot.hasGrill) _Badge('Grill', true),
                      if (spot.hasGrill) const SizedBox(width: 4),
                      if (spot.hasFireplace) _Badge('Fireplace', true),
                      if (!spot.hasWood && !spot.hasGrill && !spot.hasFireplace)
                        _Badge('No info', false),
                    ],
                  ),
                ],
              ),
            ),
            if (spot.distanceKm != null)
              Text(
                '${spot.distanceKm!.toStringAsFixed(1)} km',
                style: const TextStyle(
                  color: GlutTheme.ember,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    ));
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final bool positive;
  const _Badge(this.label, this.positive);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: positive ? GlutTheme.moss.withOpacity(0.15) : Colors.white10,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: positive ? GlutTheme.moss : Colors.white38,
          fontSize: 9,
        ),
      ),
    );
  }
}
