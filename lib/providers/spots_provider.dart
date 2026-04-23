import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../models/spot.dart';
import '../services/overpass_service.dart';
import 'package:latlong2/latlong.dart';

final locationProvider = FutureProvider<Position>((ref) async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) throw Exception('Location services disabled');

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Location permission denied');
    }
  }

  return await Geolocator.getCurrentPosition();
});

final searchLocationProvider = NotifierProvider<SearchLocation, LatLng?>(
  SearchLocation.new,
);

class SearchLocation extends Notifier<LatLng?> {
  @override
  LatLng? build() => null;
  void set(LatLng location) => state = location;
}

final spotsProvider = FutureProvider<List<Spot>>((ref) async {
  final searchLocation = ref.watch(searchLocationProvider);
  final userPosition = await ref.watch(locationProvider.future);

  // Fetch from search location if set, otherwise user position
  final fetchLat = searchLocation?.latitude ?? userPosition.latitude;
  final fetchLng = searchLocation?.longitude ?? userPosition.longitude;

  await Future.delayed(const Duration(seconds: 1));

  final spots = await OverpassService.fetchSpots(
    lat: fetchLat,
    lng: fetchLng,
    radiusMeters: 15000,
  );

  // ALWAYS use real user position for distance — never search center
  final spotsWithDistance = spots.map((spot) {
    final distanceMeters = Geolocator.distanceBetween(
      userPosition.latitude, // real GPS
      userPosition.longitude, // real GPS
      spot.lat,
      spot.lng,
    );
    return spot.copyWith(distanceKm: distanceMeters / 1000);
  }).toList();

  // Sort by distance from user
  spotsWithDistance.sort(
    (a, b) => (a.distanceKm ?? 0).compareTo(b.distanceKm ?? 0),
  );

  return spotsWithDistance;
});

// Filters
class FilterRadius extends Notifier<double> {
  @override
  double build() => 5000;
  void set(double v) => state = v;
}

class FilterBool extends Notifier<bool> {
  @override
  bool build() => false;
  void toggle() => state = !state;
  void set(bool v) => state = v;
}

final filterRadiusProvider = NotifierProvider<FilterRadius, double>(
  FilterRadius.new,
);

final filterWoodProvider = NotifierProvider<FilterBool, bool>(FilterBool.new);

final filterGrillProvider = NotifierProvider<FilterBool, bool>(FilterBool.new);

final filteredSpotsProvider = Provider<AsyncValue<List<Spot>>>((ref) {
  final spots = ref.watch(spotsProvider);
  final needsWood = ref.watch(filterWoodProvider);
  final needsGrill = ref.watch(filterGrillProvider);

  return spots.whenData(
    (list) => list.where((s) {
      if (needsWood && !s.hasWood) return false;
      if (needsGrill && !s.hasGrill) return false;
      return true;
    }).toList(),
  );
});
