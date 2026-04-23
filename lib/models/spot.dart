class Spot {
  final String id;
  final String name;
  final String? description;
  final double lat;
  final double lng;
  final bool hasWood;
  final bool hasGrill;
  final bool hasShelter;
  final bool isAccessible;
  final bool hasFireplace;
  final bool isPicnicSite;
  final double? distanceKm;

  const Spot({
    required this.id,
    required this.name,
    this.description,
    required this.lat,
    required this.lng,
    this.hasWood = false,
    this.hasGrill = false,
    this.hasShelter = false,
    this.isAccessible = false,
    this.hasFireplace = false,
    this.isPicnicSite = false,
    this.distanceKm,
  });

  factory Spot.fromOSM(Map<String, dynamic> element) {
    final tags = element['tags'] as Map<String, dynamic>? ?? {};

    String name = 'Feuerstelle';
    if (tags['name'] != null) {
      name = tags['name'];
    } else if (tags['ref'] != null) {
      name = 'Feuerstelle ${tags['ref']}';
    } else if (tags['operator'] != null) {
      name = '${tags['operator']} Feuerstelle';
    } else if (tags['amenity'] == 'bbq') {
      name = 'Grillplatz';
    } else if (tags['tourism'] == 'picnic_site') {
      name = 'Picnic Site';
    }

    final List<String> details = [];
    if (tags['opening_hours'] != null) details.add(tags['opening_hours']);
    if (tags['capacity'] != null) details.add('Capacity: ${tags['capacity']}');
    if (tags['fee'] != null) details.add('Fee: ${tags['fee']}');
    if (tags['website'] != null) details.add(tags['website']);

    return Spot(
      id: element['id'].toString(),
      name: name,
      description: details.isNotEmpty ? details.join(' · ') : null,
      lat: (element['lat'] as num).toDouble(),
      lng: (element['lon'] as num).toDouble(),
      hasWood:
          tags['fuel'] == 'wood' ||
          tags['fireplace:wood'] == 'yes' ||
          tags['wood'] == 'yes' ||
          tags['firewood'] == 'yes',
      hasGrill:
          tags['amenity'] == 'bbq' ||
          tags['bbq'] == 'yes' ||
          tags['leisure'] == 'firepit',
      hasShelter:
          tags['shelter'] == 'yes' ||
          tags['covered'] == 'yes' ||
          tags['covered'] == 'partial',
      isAccessible: tags['wheelchair'] == 'yes',
      hasFireplace: tags['fireplace'] == 'yes',
      isPicnicSite: tags['tourism'] == 'picnic_site',
    );
  }

  Spot copyWith({double? distanceKm}) {
    return Spot(
      id: id,
      name: name,
      description: description,
      lat: lat,
      lng: lng,
      hasWood: hasWood,
      hasGrill: hasGrill,
      hasShelter: hasShelter,
      isAccessible: isAccessible,
      hasFireplace: hasFireplace,
      isPicnicSite: isPicnicSite,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }
}
