// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get skip => 'Skip';

  @override
  String get continueButton => 'Continue';

  @override
  String get notNow => 'Not now';

  @override
  String get allowLocationAccess => 'Allow location access';

  @override
  String get cancel => 'Cancel';

  @override
  String get onboardingTitle1 => 'Find your next\nfire spot';

  @override
  String get onboardingSubtitle1 =>
      'Discover hundreds of public Feuerstellen across Switzerland, Germany and Austria.';

  @override
  String get onboardingTitle2 => 'Know before\nyou go';

  @override
  String get onboardingSubtitle2 =>
      'Fire ban status, wood availability and grill info — all in one place.';

  @override
  String get onboardingTitle3 => 'Enable location';

  @override
  String get onboardingSubtitle3 =>
      'So we can show spots near you and give accurate distances.';

  @override
  String get onboardingPermission1 => 'Show fire spots near your location';

  @override
  String get onboardingPermission2 => 'Alert you to fire bans in your area';

  @override
  String get onboardingPermission3 => 'Never shared or sold — stays on device';

  @override
  String get searchPlaceholder => 'Search city or area…';

  @override
  String get filterButton => 'Filter';

  @override
  String get searchThisArea => 'Search this area';

  @override
  String get locationError => 'Could not get location';

  @override
  String get navMap => 'Map';

  @override
  String get navSaved => 'Saved';

  @override
  String get savedTitle => 'Saved';

  @override
  String savedCount(int count) {
    return '$count spots';
  }

  @override
  String get savedError => 'Could not load spots';

  @override
  String get savedEmptyTitle => 'No saved spots yet';

  @override
  String get savedEmptySubtitle =>
      'Tap the heart on any spot\nto save it for later';

  @override
  String spotsNearby(int count) {
    return '$count spots nearby';
  }

  @override
  String get amenityWood => 'Wood';

  @override
  String get amenityGrill => 'Grill';

  @override
  String get amenityFireplace => 'Fireplace';

  @override
  String get amenityShelter => 'Shelter';

  @override
  String get amenityAccessible => 'Accessible';

  @override
  String get amenityPicnicSite => 'Picnic site';

  @override
  String get amenityNoInfo => 'No info';

  @override
  String distanceKmAway(String distance) {
    return '$distance km away';
  }

  @override
  String get coordinatesCopiedClipboard => 'Coordinates copied to clipboard';

  @override
  String get coordinatesCopied => 'Coordinates copied';

  @override
  String get fireAllowedToday => 'Fire allowed today';

  @override
  String get checkLocalRegulations => 'Check local regulations before lighting';

  @override
  String get sectionAmenities => 'Amenities';

  @override
  String get noAmenityInfo => 'No amenity info available';

  @override
  String get actionNavigate => 'Navigate';

  @override
  String get actionShare => 'Share this spot';

  @override
  String get navSheetTitle => 'Navigate to spot';

  @override
  String get navSheetSubtitle => 'Most fire spots are only reachable on foot';

  @override
  String get navModeWalking => 'Walking';

  @override
  String get navModeDriving => 'Driving';

  @override
  String get navSwisstopoSublabel => 'Recommended · Swiss hiking trails';

  @override
  String get navKomootSublabel => 'Recommended · Hiking trails';

  @override
  String get navWalkingDirections => 'Walking directions';

  @override
  String get navDrivingDirections => 'Driving directions';

  @override
  String get navViewGoogleMaps => 'View on Google Maps';

  @override
  String get navStreetViewSublabel => 'Street View & satellite';

  @override
  String get navCopyCoordinates => 'Copy coordinates';

  @override
  String get filterTitle => 'Filter spots';

  @override
  String get filterWoodProvided => 'Wood provided';

  @override
  String get filterGrillAvailable => 'Grill available';

  @override
  String get filterShowResults => 'Show results';

  @override
  String get sectionPhotos => 'Photos';

  @override
  String get addPhoto => 'Add photo';

  @override
  String get addPhotoSheetTitle => 'Add a photo';

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get chooseFromLibrary => 'Choose from library';

  @override
  String get beFirstToAddPhoto => 'Be the first to add a photo';

  @override
  String get maxPhotosReached => 'Maximum 3 photos per spot';

  @override
  String get reportPhoto => 'Report photo';

  @override
  String get reportPhotoContent =>
      'Report this photo as unrelated to grilling or fire spots?';

  @override
  String get report => 'Report';

  @override
  String get photoUploadError => 'Could not upload photo, try again';

  @override
  String get photoReportedSuccess => 'Photo reported — thanks for the feedback';

  @override
  String get photoReportedError => 'Could not send report, try again';

  @override
  String get weatherClearSky => 'Clear sky';

  @override
  String get weatherPartlyCloudy => 'Partly cloudy';

  @override
  String get weatherFoggy => 'Foggy';

  @override
  String get weatherDrizzle => 'Drizzle';

  @override
  String get weatherRainy => 'Rainy';

  @override
  String get weatherSnowy => 'Snowy';

  @override
  String get weatherRainShowers => 'Rain showers';

  @override
  String get weatherSnowShowers => 'Snow showers';

  @override
  String get weatherThunderstorm => 'Thunderstorm';

  @override
  String get weatherUnknown => 'Unknown';

  @override
  String get fireAdviceRain => 'Rain expected — check fire ban';

  @override
  String get fireAdviceWindy => 'Too windy — fire risk high';

  @override
  String get fireAdviceFreezing => 'Freezing — dress warm';

  @override
  String get fireAdviceGood => 'Good conditions for a fire';

  @override
  String get spotTypeFeuerstelle => 'Fire spot';

  @override
  String get spotTypeGrillplatz => 'BBQ spot';

  @override
  String get languagePickerTitle => 'Language';

  @override
  String get languageSystem => 'System (auto)';

  @override
  String windAndHumidity(String speed, int humidity) {
    return 'Wind $speed km/h  ·  Humidity $humidity%';
  }
}
