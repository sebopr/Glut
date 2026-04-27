import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/spot.dart';
import '../providers/spots_provider.dart';
import '../services/elevation_service.dart';
import '../theme.dart';
import '../services/weather_service.dart';

class SpotDetailScreen extends ConsumerStatefulWidget {
  final Spot spot;

  SpotDetailScreen({super.key, required this.spot});

  @override
  ConsumerState<SpotDetailScreen> createState() => _SpotDetailScreenState();
}

class _SpotDetailScreenState extends ConsumerState<SpotDetailScreen> {
  int? _elevation;

  Future<void> _loadElevation() async {
  WeatherData? _weather;
  bool _weatherLoading = true;
    final elevation = await ElevationService.getElevation(
      widget.spot.lat,
      widget.spot.lng,
    );
    if (mounted) setState(() => _elevation = elevation);
  }

  @override
  void initState() {
    super.initState();
    _loadElevation();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    final weather = await WeatherService.getWeather(
      widget.spot.lat,
      widget.spot.lng,
    );
    if (mounted) {
      setState(() {
        _weather = weather;
        _weatherLoading = false;
      });
    }
  }

  void _showNavigationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: GlutTheme.coal,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _NavigationSheet(spot: widget.spot),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spot = widget.spot;
    final isFavourite = ref.watch(favouritesProvider).contains(spot.id);

    return Scaffold(
      backgroundColor: GlutTheme.ash,
      body: Column(
        children: [
          // ── 1. MAP HEADER ──────────────────────────────────
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(spot.lat, spot.lng),
                    initialZoom: 15,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.none,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.yourname.glut',
                      maxZoom: 19,
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(spot.lat, spot.lng),
                          width: 56,
                          height: 56,
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: GlutTheme.ash,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: GlutTheme.ember,
                                width: 2.5,
                              ),
                            ),
                            child: const Center(
                              child: Text('🔥', style: TextStyle(fontSize: 26)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Back + favourite buttons
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back button
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),

                        // Favourite button
                        GestureDetector(
                          onTap: () => ref
                              .read(favouritesProvider.notifier)
                              .toggle(spot.id),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Icon(
                              isFavourite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavourite
                                  ? GlutTheme.ember
                                  : Colors.white,
                              size: 20,
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

          // ── 2. CONTENT ─────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    spot.name,
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 22,
                      color: GlutTheme.linen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  // Distance
                  if (spot.distanceKm != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${spot.distanceKm!.toStringAsFixed(1)} km away ✈',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ),

                  // Description
                  if (spot.description != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        spot.description!,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ),

                  // GPS + Elevation
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(
                              ClipboardData(
                                text:
                                    '${spot.lat.toStringAsFixed(6)}, ${spot.lng.toStringAsFixed(6)}',
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Coordinates copied to clipboard',
                                ),
                                backgroundColor: GlutTheme.coal,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              const Icon(
                                Icons.gps_fixed,
                                size: 12,
                                color: Colors.white38,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${spot.lat.toStringAsFixed(6)}, ${spot.lng.toStringAsFixed(6)}',
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.copy,
                                size: 10,
                                color: Colors.white24,
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(
                              Icons.terrain,
                              size: 12,
                              color: Colors.white38,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _elevation != null ? '${_elevation}m' : '...',
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 11,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const SizedBox(height: 16),

                  // Weather
                  _weatherLoading
                      ? Container(
                          height: 72,
                          decoration: BoxDecoration(
                            color: GlutTheme.coal,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: GlutTheme.ember,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : _weather != null
                      ? Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: GlutTheme.coal,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    _weather!.emoji,
                                    style: const TextStyle(fontSize: 28),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${_weather!.temperature.toStringAsFixed(1)}°C  ·  ${_weather!.description}',
                                          style: const TextStyle(
                                            color: GlutTheme.linen,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Wind ${_weather!.windSpeed.toStringAsFixed(0)} km/h  ·  Humidity ${_weather!.humidity}%',
                                          style: const TextStyle(
                                            color: Colors.white38,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _weather!.goodForFire
                                      ? GlutTheme.moss.withOpacity(0.1)
                                      : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: _weather!.goodForFire
                                        ? GlutTheme.moss.withOpacity(0.3)
                                        : Colors.orange.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _weather!.goodForFire
                                          ? Icons.check_circle_outline
                                          : Icons.warning_amber_outlined,
                                      size: 14,
                                      color: _weather!.goodForFire
                                          ? GlutTheme.moss
                                          : Colors.orange,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _weather!.fireAdvice,
                                      style: TextStyle(
                                        color: _weather!.goodForFire
                                            ? GlutTheme.moss
                                            : Colors.orange,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),

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
                      if (spot.hasFireplace) _Amenity('🔥 Fireplace'),
                      if (spot.isPicnicSite) _Amenity('🧺 Picnic site'),
                      if (!spot.hasWood &&
                          !spot.hasGrill &&
                          !spot.hasShelter &&
                          !spot.isAccessible &&
                          !spot.hasFireplace &&
                          !spot.isPicnicSite)
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
                      onPressed: () => _showNavigationSheet(context),
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

// ── NAVIGATION SHEET ───────────────────────────────────────
class _NavigationSheet extends StatefulWidget {
  final Spot spot;
  const _NavigationSheet({required this.spot});

  @override
  State<_NavigationSheet> createState() => _NavigationSheetState();
}

class _NavigationSheetState extends State<_NavigationSheet> {
  bool _walking = true;

  bool get _isInSwitzerland {
    return widget.spot.lat >= 45.8 &&
        widget.spot.lat <= 47.8 &&
        widget.spot.lng >= 5.9 &&
        widget.spot.lng <= 10.5;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Navigate to spot',
              style: TextStyle(
                color: GlutTheme.linen,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Most fire spots are only reachable on foot',
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
            const SizedBox(height: 16),

            // Walking / Driving toggle
            Container(
              decoration: BoxDecoration(
                color: GlutTheme.ash,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  _ModeTab(
                    label: 'Walking',
                    icon: Icons.directions_walk,
                    selected: _walking,
                    onTap: () => setState(() => _walking = true),
                  ),
                  _ModeTab(
                    label: 'Driving',
                    icon: Icons.directions_car_outlined,
                    selected: !_walking,
                    onTap: () => setState(() => _walking = false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Swisstopo — walking + Switzerland only
            if (_walking && _isInSwitzerland) ...[
              _NavOption(
                label: 'Swisstopo',
                sublabel: 'Recommended · Swiss hiking trails',
                icon: Icons.terrain_outlined,
                onTap: () async {
                  Navigator.pop(context);

                  final nativeUri = Uri.parse(
                    'ch.admin.swisstopo://map?lat=${widget.spot.lat}&lon=${widget.spot.lng}&zoom=12',
                  );

                  // Convert to LV95
                  final lv95 = CoordinateService.wgs84ToLV95(
                    widget.spot.lat,
                    widget.spot.lng,
                  );

                  final webUri = Uri.parse(
                    'https://map.geo.admin.ch/#/map'
                    '?lang=de'
                    '&center=${lv95['e']!.toInt()},${lv95['n']!.toInt()}'
                    '&z=12'
                    '&bgLayer=ch.swisstopo.pixelkarte-farbe'
                    '&layers=ch.swisstopo.swisstlm3d-wanderwege'
                    '&crosshair=point',
                  );

                  if (await canLaunchUrl(nativeUri)) {
                    await launchUrl(
                      nativeUri,
                      mode: LaunchMode.externalApplication,
                    );
                  } else {
                    await launchUrl(
                      webUri,
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
              ),
              const Divider(color: Colors.white10),
            ],

            // Komoot — walking + outside Switzerland
            if (_walking && !_isInSwitzerland) ...[
              _NavOption(
                label: 'Komoot',
                sublabel: 'Recommended · Hiking trails',
                icon: Icons.terrain_outlined,
                onTap: () async {
                  Navigator.pop(context);
                  final uri = Uri.parse(
                    'https://www.komoot.com/plan/@${widget.spot.lat},${widget.spot.lng},12z',
                  );
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                },
              ),
              const Divider(color: Colors.white10),
            ],

            // Google Maps
            _NavOption(
              label: 'Google Maps',
              sublabel: _walking ? 'Walking directions' : 'Driving directions',
              icon: Icons.map_outlined,
              onTap: () async {
                Navigator.pop(context);
                final mode = _walking ? 'walking' : 'driving';

                // Try native Google Maps app first
                final nativeUri = Uri.parse(
                  'comgooglemaps://?daddr=${widget.spot.lat},${widget.spot.lng}&directionsmode=$mode',
                );

                // Fall back to web
                final webUri = Uri.parse(
                  'https://maps.google.com/maps?daddr=${widget.spot.lat},${widget.spot.lng}&dirflg=${_walking ? 'w' : 'd'}',
                );

                if (await canLaunchUrl(nativeUri)) {
                  await launchUrl(
                    nativeUri,
                    mode: LaunchMode.externalApplication,
                  );
                } else {
                  await launchUrl(webUri, mode: LaunchMode.externalApplication);
                }
              },
            ),

            const Divider(color: Colors.white10),

            // Apple Maps — iOS only
            if (Platform.isIOS) ...[
              _NavOption(
                label: 'Apple Maps',
                sublabel: _walking
                    ? 'Walking directions'
                    : 'Driving directions',
                icon: Icons.apple,
                onTap: () async {
                  Navigator.pop(context);
                  final Uri uri;
                  if (_walking) {
                    uri = Uri.parse(
                      'maps://?daddr=${widget.spot.lat},${widget.spot.lng}&dirflg=w&t=m',
                    );
                  } else {
                    uri = Uri.parse(
                      'maps://?daddr=${widget.spot.lat},${widget.spot.lng}&dirflg=d&t=m',
                    );
                  }
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
              ),
              const Divider(color: Colors.white10),
            ],

            // Waze — driving only
            if (!_walking) ...[
              _NavOption(
                label: 'Waze',
                sublabel: 'Driving directions',
                icon: Icons.navigation_outlined,
                onTap: () async {
                  Navigator.pop(context);
                  final uri = Uri.parse(
                    'https://waze.com/ul?ll=${widget.spot.lat},${widget.spot.lng}&navigate=yes',
                  );
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                },
              ),
              const Divider(color: Colors.white10),
            ],

            // Street View
            _NavOption(
              label: 'View on Google Maps',
              sublabel: 'Street View & satellite',
              icon: Icons.streetview,
              onTap: () async {
                Navigator.pop(context);
                final uri = Uri.parse(
                  'https://www.google.com/maps/@${widget.spot.lat},${widget.spot.lng},3a,75y,90t/data=!3m1!1e1',
                );
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              },
            ),
            const Divider(color: Colors.white10),

            // Copy coordinates
            _NavOption(
              label: 'Copy coordinates',
              sublabel:
                  '${widget.spot.lat.toStringAsFixed(6)}, ${widget.spot.lng.toStringAsFixed(6)}',
              icon: Icons.copy_outlined,
              onTap: () {
                Navigator.pop(context);
                Clipboard.setData(
                  ClipboardData(
                    text:
                        '${widget.spot.lat.toStringAsFixed(6)}, ${widget.spot.lng.toStringAsFixed(6)}',
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Coordinates copied',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.check_circle,
                          color: GlutTheme.moss,
                          size: 18,
                        ),
                      ],
                    ),
                    backgroundColor: GlutTheme.coal,
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? GlutTheme.ember : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? Colors.white : Colors.white38,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.white38,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavOption extends StatelessWidget {
  final String label;
  final String? sublabel;
  final IconData icon;
  final VoidCallback onTap;

  const _NavOption({
    required this.label,
    required this.icon,
    required this.onTap,
    this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: GlutTheme.ember, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: GlutTheme.linen,
                      fontSize: 14,
                    ),
                  ),
                  if (sublabel != null)
                    Text(
                      sublabel!,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
          ],
        ),
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
