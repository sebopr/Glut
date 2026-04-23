import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/spot.dart';
import '../theme.dart';

class SpotDetailScreen extends StatelessWidget {
  final Spot spot;
  const SpotDetailScreen({super.key, required this.spot});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlutTheme.ash,
      body: Column(
        children: [
          // Header image area
          Container(
            height: 200,
            width: double.infinity,
            color: GlutTheme.coal,
            child: Stack(
              children: [
                const Center(child: Text('🔥', style: TextStyle(fontSize: 64))),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Icon(
                              Icons.favorite_border,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spot.name,
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 22,
                      color: GlutTheme.linen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (spot.distanceKm != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${spot.distanceKm!.toStringAsFixed(1)} km away',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Fire ban status
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: GlutTheme.moss.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: GlutTheme.moss.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: GlutTheme.moss,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fire allowed today',
                              style: TextStyle(
                                color: GlutTheme.moss,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'Check local regulations before lighting',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Amenities
                  const Text(
                    'Amenities',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (spot.hasWood) _Amenity('🪵 Wood'),
                      if (spot.hasGrill) _Amenity('🍖 Grill'),
                      if (spot.hasShelter) _Amenity('🏕️ Shelter'),
                      if (spot.isAccessible) _Amenity('♿ Accessible'),
                      if (!spot.hasWood &&
                          !spot.hasGrill &&
                          !spot.hasShelter &&
                          !spot.isAccessible)
                        const Text(
                          'No amenity info available',
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Navigate button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GlutTheme.ember,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
                        final uri = Uri.parse(
                          'https://maps.google.com/?q=${spot.lat},${spot.lng}',
                        );
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                      child: const Text(
                        'Navigate',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Amenity extends StatelessWidget {
  final String label;
  const _Amenity(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: GlutTheme.coal,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(
        label,
        style: const TextStyle(color: GlutTheme.linen, fontSize: 11),
      ),
    );
  }
}
