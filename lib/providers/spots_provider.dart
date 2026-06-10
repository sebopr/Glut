import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/spot.dart';
import '../services/overpass_service.dart';

final locationProvider = StreamProvider<Position>((ref) async* {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) throw Exception('Location services disabled');

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Location permission denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw Exception('Location permission permanently denied');
  }

  // Emit current position immediately so the map loads without waiting for first stream tick
  yield await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
  );

  yield* Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.medium,
      distanceFilter: 10,
    ),
  );
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
  final userPosition = await ref.read(locationProvider.future);

  final fetchLat = searchLocation?.latitude ?? userPosition.latitude;
  final fetchLng = searchLocation?.longitude ?? userPosition.longitude;

  await Future.delayed(const Duration(seconds: 1));

  final spots = await OverpassService.fetchSpots(
    lat: fetchLat,
    lng: fetchLng,
    radiusMeters: 5000,
  );

  final spotsWithDistance = spots.map((spot) {
    final distanceMeters = Geolocator.distanceBetween(
      userPosition.latitude,
      userPosition.longitude,
      spot.lat,
      spot.lng,
    );
    return spot.copyWith(distanceKm: distanceMeters / 1000);
  }).toList();

  spotsWithDistance.sort(
    (a, b) => (a.distanceKm ?? 0).compareTo(b.distanceKm ?? 0),
  );

  return spotsWithDistance;
});

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

class FavouritesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    _load();
    return {};
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('favourites') ?? [];
    state = ids.toSet();
  }

  Future<void> toggle(Spot spot) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList('saved_spots') ?? [];

    if (state.contains(spot.id)) {
      jsonList.removeWhere((s) => (jsonDecode(s) as Map)['id'] == spot.id);
      state = {...state}..remove(spot.id);
    } else {
      jsonList.add(jsonEncode(spot.toJson()));
      state = {...state, spot.id};
    }

    await prefs.setStringList('saved_spots', jsonList);
    await prefs.setStringList('favourites', state.toList());
  }

  bool isFavourite(String spotId) => state.contains(spotId);
}

final favouritesProvider = NotifierProvider<FavouritesNotifier, Set<String>>(
  FavouritesNotifier.new,
);

final savedSpotsProvider = FutureProvider<List<Spot>>((ref) async {
  ref.watch(favouritesProvider);
  final prefs = await SharedPreferences.getInstance();
  final jsonList = prefs.getStringList('saved_spots') ?? [];
  return jsonList
      .map((s) => Spot.fromJson(jsonDecode(s) as Map<String, dynamic>))
      .toList();
});
