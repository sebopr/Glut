import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../models/spot.dart';
import '../utils/spot_display.dart';
import '../providers/spots_provider.dart';
import '../services/elevation_service.dart';
import '../theme.dart';
import '../services/weather_service.dart';
import 'widgets/spot_photos.dart';
import '../services/coordinate_service.dart';
import '../services/share_service.dart';

class SpotDetailScreen extends ConsumerStatefulWidget {
  final Spot spot;

  const SpotDetailScreen({super.key, required this.spot});

  @override
  ConsumerState<SpotDetailScreen> createState() => _SpotDetailScreenState();
}

class _SpotDetailScreenState extends ConsumerState<SpotDetailScreen> {
  int? _elevation;
  WeatherData? _weather;
  bool _weatherLoading = true;

  @override
  void initState() {
    super.initState();
    _loadElevation();
    _loadWeather();
  }

  Future<void> _loadElevation() async {
    final elevation = await ElevationService.getElevation(
      widget.spot.lat,
      widget.spot.lng,
    );
    if (mounted) setState(() => _elevation = elevation);
  }

  IconData _weatherIcon(int code) {
    if (code == 0) return Icons.wb_sunny;
    if (code <= 3) return Icons.wb_cloudy;
    if (code <= 48) return Icons.foggy;
    if (code <= 57) return Icons.grain;
    if (code <= 67) return Icons.umbrella;
    if (code <= 77) return Icons.ac_unit;
    if (code <= 82) return Icons.water_drop;
    if (code <= 86) return Icons.ac_unit;
    if (code <= 99) return Icons.thunderstorm;
    return Icons.device_thermostat;
  }

  String _localizedDescription(WeatherData w, AppLocalizations l10n) {
    final code = w.weatherCode;
    if (code == 0) return l10n.weatherClearSky;
    if (code <= 3) return l10n.weatherPartlyCloudy;
    if (code <= 48) return l10n.weatherFoggy;
    if (code <= 57) return l10n.weatherDrizzle;
    if (code <= 67) return l10n.weatherRainy;
    if (code <= 77) return l10n.weatherSnowy;
    if (code <= 82) return l10n.weatherRainShowers;
    if (code <= 86) return l10n.weatherSnowShowers;
    if (code <= 99) return l10n.weatherThunderstorm;
    return l10n.weatherUnknown;
  }

  String _localizedFireAdvice(WeatherData w, AppLocalizations l10n) {
    if (w.weatherCode >= 51) return l10n.fireAdviceRain;
    if (w.windSpeed >= 30) return l10n.fireAdviceWindy;
    if (w.temperature <= 0) return l10n.fireAdviceFreezing;
    return l10n.fireAdviceGood;
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
    final l10n = AppLocalizations.of(context)!;
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
                              child: Icon(Icons.local_fire_department, size: 28, color: GlutTheme.ember),
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
                        // Share + Favourite on the right
                        Row(
                          children: [
                            Builder(
                              builder: (ctx) => GestureDetector(
                                onTap: () => ShareService.shareSpot(spot, context: ctx),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: const Icon(
                                    Icons.share_outlined,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => ref
                                  .read(favouritesProvider.notifier)
                                  .toggle(spot),
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
                    localizedSpotName(spot.name, l10n),
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.distanceKmAway(spot.distanceKm!.toStringAsFixed(1)),
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.flight, size: 12, color: Colors.white54),
                        ],
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
                              SnackBar(
                                content: Text(
                                  l10n.coordinatesCopiedClipboard,
                                ),
                                backgroundColor: GlutTheme.coal,
                                duration: const Duration(seconds: 2),
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
                                  Icon(
                                    _weatherIcon(_weather!.weatherCode),
                                    size: 28,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${_weather!.temperature.toStringAsFixed(1)}°C  ·  ${_localizedDescription(_weather!, l10n)}',
                                          style: const TextStyle(
                                            color: GlutTheme.linen,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          l10n.windAndHumidity(
                                            _weather!.windSpeed.toStringAsFixed(0),
                                            _weather!.humidity,
                                          ),
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
                                      ? GlutTheme.moss.withValues(alpha: 0.1)
                                      : Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: _weather!.goodForFire
                                        ? GlutTheme.moss.withValues(alpha: 0.3)
                                        : Colors.orange.withValues(alpha: 0.3),
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
                                      _localizedFireAdvice(_weather!, l10n),
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
                      color: GlutTheme.moss.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: GlutTheme.moss.withValues(alpha: 0.3),
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.fireAllowedToday,
                              style: const TextStyle(
                                color: GlutTheme.moss,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              l10n.checkLocalRegulations,
                              style: const TextStyle(
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
                  Text(
                    l10n.sectionAmenities,
                    style: const TextStyle(
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
                      if (spot.hasWood) _Amenity(Icons.forest, l10n.amenityWood),
                      if (spot.hasGrill) _Amenity(Icons.outdoor_grill, l10n.amenityGrill),
                      if (spot.hasShelter) _Amenity(Icons.cottage, l10n.amenityShelter),
                      if (spot.isAccessible) _Amenity(Icons.accessible, l10n.amenityAccessible),
                      if (spot.hasFireplace) _Amenity(Icons.local_fire_department, l10n.amenityFireplace),
                      if (spot.isPicnicSite) _Amenity(Icons.park, l10n.amenityPicnicSite),
                      if (!spot.hasWood &&
                          !spot.hasGrill &&
                          !spot.hasShelter &&
                          !spot.isAccessible &&
                          !spot.hasFireplace &&
                          !spot.isPicnicSite)
                        Text(
                          l10n.noAmenityInfo,
                          style: const TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  const SizedBox(height: 16),

                  // Photos
                  SpotPhotos(
                    spotId: spot.id,
                    spotLat: spot.lat,
                    spotLng: spot.lng,
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
                      child: Text(
                        l10n.actionNavigate,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Share button
                  SizedBox(
                    width: double.infinity,
                    child: Builder(
                      builder: (ctx) => OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => ShareService.shareSpot(spot, context: ctx),
                        icon: const Icon(
                          Icons.share_outlined,
                          color: Colors.white54,
                          size: 18,
                        ),
                        label: Text(
                          l10n.actionShare,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
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
    final l10n = AppLocalizations.of(context)!;

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
            Text(
              l10n.navSheetTitle,
              style: const TextStyle(
                color: GlutTheme.linen,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.navSheetSubtitle,
              style: const TextStyle(color: Colors.white38, fontSize: 11),
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
                    label: l10n.navModeWalking,
                    icon: Icons.directions_walk,
                    selected: _walking,
                    onTap: () => setState(() => _walking = true),
                  ),
                  _ModeTab(
                    label: l10n.navModeDriving,
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
                sublabel: l10n.navSwisstopoSublabel,
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
                sublabel: l10n.navKomootSublabel,
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
              sublabel: _walking ? l10n.navWalkingDirections : l10n.navDrivingDirections,
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
                    ? l10n.navWalkingDirections
                    : l10n.navDrivingDirections,
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
                sublabel: l10n.navDrivingDirections,
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
              label: l10n.navViewGoogleMaps,
              sublabel: l10n.navStreetViewSublabel,
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
              label: l10n.navCopyCoordinates,
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
                      children: [
                        Text(
                          l10n.coordinatesCopied,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
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
  final IconData icon;
  final String label;
  const _Amenity(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: GlutTheme.coal,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: GlutTheme.ember),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: GlutTheme.linen, fontSize: 11)),
        ],
      ),
    );
  }
}
