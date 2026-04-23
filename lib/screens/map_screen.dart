import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../providers/spots_provider.dart';
import '../theme.dart';
import '../models/spot.dart';
import 'spot_detail_screen.dart';
import 'widgets/spot_bottom_sheet.dart';
import 'widgets/filter_sheet.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _mapController = MapController();
  Spot? _selectedSpot;
  bool _centeredOnUser = false;
  bool _mapMoved = false;
  double _mapRotation = 0.0;
  LatLng _currentMapCenter = const LatLng(47.3769, 8.5417);

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(locationProvider);
    final spots = ref.watch(filteredSpotsProvider);

    return Scaffold(
      body: Stack(
        children: [
          // ── 1. MAP ──────────────────────────────────────────
          location.when(
            data: (pos) {
              if (!_centeredOnUser) {
                _centeredOnUser = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _mapController.move(LatLng(pos.latitude, pos.longitude), 13);
                });
              }
              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(pos.latitude, pos.longitude),
                  initialZoom: 13,
                  onTap: (_, __) => setState(() => _selectedSpot = null),
                  onPositionChanged: (position, hasGesture) {
                    if (hasGesture && position.center != null) {
                      setState(() {
                        _mapMoved = true;
                        _currentMapCenter = position.center!;
                        _mapRotation = position.rotation ?? 0.0;
                      });
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.yourname.glut',
                  ),
                  // User location dot
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(pos.latitude, pos.longitude),
                        width: 20,
                        height: 20,
                        child: Container(
                          decoration: BoxDecoration(
                            color: GlutTheme.ember,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Spot pins
                  spots.when(
                    data: (list) => MarkerLayer(
                      markers: list
                          .map(
                            (spot) => Marker(
                              point: LatLng(spot.lat, spot.lng),
                              width: 36,
                              height: 36,
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedSpot = spot),
                                child: _SpotPin(
                                  selected: _selectedSpot?.id == spot.id,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    loading: () => const MarkerLayer(markers: []),
                    error: (_, __) => const MarkerLayer(markers: []),
                  ),
                ],
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: GlutTheme.ember),
            ),
            error: (e, _) => Center(
              child: Text(
                'Could not get location',
                style: TextStyle(color: GlutTheme.linen),
              ),
            ),
          ),

          // ── 2. SEARCH BAR + FILTER ──────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: GlutTheme.ash.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search, size: 16, color: Colors.white38),
                          SizedBox(width: 8),
                          Text(
                            'Search fire spots…',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => showModalBottomSheet(
                      context: context,
                      backgroundColor: GlutTheme.coal,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      builder: (_) => const FilterSheet(),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: GlutTheme.ember,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Filter',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── 3. SEARCH THIS AREA BUTTON ──────────────────────
          if (_mapMoved)
            Positioned(
              top: 110,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    ref
                        .read(searchLocationProvider.notifier)
                        .set(_currentMapCenter);
                    setState(() => _mapMoved = false);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: GlutTheme.ember,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search, color: Colors.white, size: 14),
                        SizedBox(width: 6),
                        Text(
                          'Search this area',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          // ── 4. COMPASS BUTTON ───────────────────────────────
          Positioned(
            right: 12,
            top: 110,
            child: GestureDetector(
              onTap: () {
                _mapController.rotate(0);
                setState(() => _mapRotation = 0.0);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: GlutTheme.ash.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12),
                ),
                child: Transform.rotate(
                  angle: -_mapRotation * (3.14159265 / 180),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'N',
                        style: TextStyle(
                          color: GlutTheme.ember,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(width: 2, height: 8, color: GlutTheme.ember),
                      Container(width: 2, height: 8, color: Colors.white24),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // ── 5. BOTTOM SHEET ─────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: MediaQuery.of(context).size.height * 0.35,
            child: SpotBottomSheet(
              selectedSpot: _selectedSpot,
              onSpotTap: (spot) => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SpotDetailScreen(spot: spot)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpotPin extends StatelessWidget {
  final bool selected;
  const _SpotPin({this.selected = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: selected ? 36 : 28,
      height: selected ? 36 : 28,
      decoration: BoxDecoration(
        color: selected ? GlutTheme.ember : GlutTheme.coal,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? Colors.white : Colors.white30,
          width: selected ? 2.5 : 1.5,
        ),
      ),
      child: const Center(child: Text('🔥', style: TextStyle(fontSize: 14))),
    );
  }
}
