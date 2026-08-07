import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('fr'),
    Locale('it'),
  ];

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @allowLocationAccess.
  ///
  /// In en, this message translates to:
  /// **'Allow location access'**
  String get allowLocationAccess;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Find your next\nfire spot'**
  String get onboardingTitle1;

  /// No description provided for @onboardingSubtitle1.
  ///
  /// In en, this message translates to:
  /// **'Discover hundreds of public Feuerstellen across Switzerland, Germany and Austria.'**
  String get onboardingSubtitle1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Know before\nyou go'**
  String get onboardingTitle2;

  /// No description provided for @onboardingSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'Fire ban status, wood availability and grill info — all in one place.'**
  String get onboardingSubtitle2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Enable location'**
  String get onboardingTitle3;

  /// No description provided for @onboardingSubtitle3.
  ///
  /// In en, this message translates to:
  /// **'So we can show spots near you and give accurate distances.'**
  String get onboardingSubtitle3;

  /// No description provided for @onboardingPermission1.
  ///
  /// In en, this message translates to:
  /// **'Show fire spots near your location'**
  String get onboardingPermission1;

  /// No description provided for @onboardingPermission2.
  ///
  /// In en, this message translates to:
  /// **'Alert you to fire bans in your area'**
  String get onboardingPermission2;

  /// No description provided for @onboardingPermission3.
  ///
  /// In en, this message translates to:
  /// **'Never shared or sold — stays on device'**
  String get onboardingPermission3;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search city or area…'**
  String get searchPlaceholder;

  /// No description provided for @filterButton.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filterButton;

  /// No description provided for @searchThisArea.
  ///
  /// In en, this message translates to:
  /// **'Search this area'**
  String get searchThisArea;

  /// No description provided for @locationError.
  ///
  /// In en, this message translates to:
  /// **'Could not get location'**
  String get locationError;

  /// No description provided for @navMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get navMap;

  /// No description provided for @navSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get navSaved;

  /// No description provided for @savedTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedTitle;

  /// No description provided for @savedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} spots'**
  String savedCount(int count);

  /// No description provided for @savedError.
  ///
  /// In en, this message translates to:
  /// **'Could not load spots'**
  String get savedError;

  /// No description provided for @savedEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved spots yet'**
  String get savedEmptyTitle;

  /// No description provided for @savedEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on any spot\nto save it for later'**
  String get savedEmptySubtitle;

  /// No description provided for @spotsNearby.
  ///
  /// In en, this message translates to:
  /// **'{count} spots nearby'**
  String spotsNearby(int count);

  /// No description provided for @amenityWood.
  ///
  /// In en, this message translates to:
  /// **'Wood'**
  String get amenityWood;

  /// No description provided for @amenityGrill.
  ///
  /// In en, this message translates to:
  /// **'Grill'**
  String get amenityGrill;

  /// No description provided for @amenityFireplace.
  ///
  /// In en, this message translates to:
  /// **'Fireplace'**
  String get amenityFireplace;

  /// No description provided for @amenityShelter.
  ///
  /// In en, this message translates to:
  /// **'Shelter'**
  String get amenityShelter;

  /// No description provided for @amenityAccessible.
  ///
  /// In en, this message translates to:
  /// **'Accessible'**
  String get amenityAccessible;

  /// No description provided for @amenityPicnicSite.
  ///
  /// In en, this message translates to:
  /// **'Picnic site'**
  String get amenityPicnicSite;

  /// No description provided for @amenityNoInfo.
  ///
  /// In en, this message translates to:
  /// **'No info'**
  String get amenityNoInfo;

  /// No description provided for @distanceKmAway.
  ///
  /// In en, this message translates to:
  /// **'{distance} km away'**
  String distanceKmAway(String distance);

  /// No description provided for @coordinatesCopiedClipboard.
  ///
  /// In en, this message translates to:
  /// **'Coordinates copied to clipboard'**
  String get coordinatesCopiedClipboard;

  /// No description provided for @coordinatesCopied.
  ///
  /// In en, this message translates to:
  /// **'Coordinates copied'**
  String get coordinatesCopied;

  /// No description provided for @fireAllowedToday.
  ///
  /// In en, this message translates to:
  /// **'Fire allowed today'**
  String get fireAllowedToday;

  /// No description provided for @checkLocalRegulations.
  ///
  /// In en, this message translates to:
  /// **'Check local regulations before lighting'**
  String get checkLocalRegulations;

  /// No description provided for @sectionAmenities.
  ///
  /// In en, this message translates to:
  /// **'Amenities'**
  String get sectionAmenities;

  /// No description provided for @noAmenityInfo.
  ///
  /// In en, this message translates to:
  /// **'No amenity info available'**
  String get noAmenityInfo;

  /// No description provided for @actionNavigate.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get actionNavigate;

  /// No description provided for @actionShare.
  ///
  /// In en, this message translates to:
  /// **'Share this spot'**
  String get actionShare;

  /// No description provided for @navSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Navigate to spot'**
  String get navSheetTitle;

  /// No description provided for @navSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Most fire spots are only reachable on foot'**
  String get navSheetSubtitle;

  /// No description provided for @navModeWalking.
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get navModeWalking;

  /// No description provided for @navModeDriving.
  ///
  /// In en, this message translates to:
  /// **'Driving'**
  String get navModeDriving;

  /// No description provided for @navSwisstopoSublabel.
  ///
  /// In en, this message translates to:
  /// **'Recommended · Swiss hiking trails'**
  String get navSwisstopoSublabel;

  /// No description provided for @navKomootSublabel.
  ///
  /// In en, this message translates to:
  /// **'Recommended · Hiking trails'**
  String get navKomootSublabel;

  /// No description provided for @navWalkingDirections.
  ///
  /// In en, this message translates to:
  /// **'Walking directions'**
  String get navWalkingDirections;

  /// No description provided for @navDrivingDirections.
  ///
  /// In en, this message translates to:
  /// **'Driving directions'**
  String get navDrivingDirections;

  /// No description provided for @navViewGoogleMaps.
  ///
  /// In en, this message translates to:
  /// **'View on Google Maps'**
  String get navViewGoogleMaps;

  /// No description provided for @navStreetViewSublabel.
  ///
  /// In en, this message translates to:
  /// **'Street View & satellite'**
  String get navStreetViewSublabel;

  /// No description provided for @navCopyCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Copy coordinates'**
  String get navCopyCoordinates;

  /// No description provided for @filterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter spots'**
  String get filterTitle;

  /// No description provided for @filterWoodProvided.
  ///
  /// In en, this message translates to:
  /// **'Wood provided'**
  String get filterWoodProvided;

  /// No description provided for @filterGrillAvailable.
  ///
  /// In en, this message translates to:
  /// **'Grill available'**
  String get filterGrillAvailable;

  /// No description provided for @filterShowResults.
  ///
  /// In en, this message translates to:
  /// **'Show results'**
  String get filterShowResults;

  /// No description provided for @sectionPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get sectionPhotos;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get addPhoto;

  /// No description provided for @addPhotoSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a photo'**
  String get addPhotoSheetTitle;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takePhoto;

  /// No description provided for @chooseFromLibrary.
  ///
  /// In en, this message translates to:
  /// **'Choose from library'**
  String get chooseFromLibrary;

  /// No description provided for @beFirstToAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Be the first to add a photo'**
  String get beFirstToAddPhoto;

  /// No description provided for @maxPhotosReached.
  ///
  /// In en, this message translates to:
  /// **'Maximum 3 photos per spot'**
  String get maxPhotosReached;

  /// No description provided for @reportPhoto.
  ///
  /// In en, this message translates to:
  /// **'Report photo'**
  String get reportPhoto;

  /// No description provided for @reportPhotoContent.
  ///
  /// In en, this message translates to:
  /// **'Report this photo as unrelated to grilling or fire spots?'**
  String get reportPhotoContent;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @photoUploadError.
  ///
  /// In en, this message translates to:
  /// **'Could not upload photo, try again'**
  String get photoUploadError;

  /// No description provided for @photoReportedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Photo reported — thanks for the feedback'**
  String get photoReportedSuccess;

  /// No description provided for @photoReportedError.
  ///
  /// In en, this message translates to:
  /// **'Could not send report, try again'**
  String get photoReportedError;

  /// No description provided for @weatherClearSky.
  ///
  /// In en, this message translates to:
  /// **'Clear sky'**
  String get weatherClearSky;

  /// No description provided for @weatherPartlyCloudy.
  ///
  /// In en, this message translates to:
  /// **'Partly cloudy'**
  String get weatherPartlyCloudy;

  /// No description provided for @weatherFoggy.
  ///
  /// In en, this message translates to:
  /// **'Foggy'**
  String get weatherFoggy;

  /// No description provided for @weatherDrizzle.
  ///
  /// In en, this message translates to:
  /// **'Drizzle'**
  String get weatherDrizzle;

  /// No description provided for @weatherRainy.
  ///
  /// In en, this message translates to:
  /// **'Rainy'**
  String get weatherRainy;

  /// No description provided for @weatherSnowy.
  ///
  /// In en, this message translates to:
  /// **'Snowy'**
  String get weatherSnowy;

  /// No description provided for @weatherRainShowers.
  ///
  /// In en, this message translates to:
  /// **'Rain showers'**
  String get weatherRainShowers;

  /// No description provided for @weatherSnowShowers.
  ///
  /// In en, this message translates to:
  /// **'Snow showers'**
  String get weatherSnowShowers;

  /// No description provided for @weatherThunderstorm.
  ///
  /// In en, this message translates to:
  /// **'Thunderstorm'**
  String get weatherThunderstorm;

  /// No description provided for @weatherUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get weatherUnknown;

  /// No description provided for @fireAdviceRain.
  ///
  /// In en, this message translates to:
  /// **'Rain expected — check fire ban'**
  String get fireAdviceRain;

  /// No description provided for @fireAdviceWindy.
  ///
  /// In en, this message translates to:
  /// **'Too windy — fire risk high'**
  String get fireAdviceWindy;

  /// No description provided for @fireAdviceFreezing.
  ///
  /// In en, this message translates to:
  /// **'Freezing — dress warm'**
  String get fireAdviceFreezing;

  /// No description provided for @fireAdviceGood.
  ///
  /// In en, this message translates to:
  /// **'Good conditions for a fire'**
  String get fireAdviceGood;

  /// No description provided for @spotTypeFeuerstelle.
  ///
  /// In en, this message translates to:
  /// **'Fire spot'**
  String get spotTypeFeuerstelle;

  /// No description provided for @spotTypeGrillplatz.
  ///
  /// In en, this message translates to:
  /// **'BBQ spot'**
  String get spotTypeGrillplatz;

  /// No description provided for @languagePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languagePickerTitle;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System (auto)'**
  String get languageSystem;

  /// No description provided for @windAndHumidity.
  ///
  /// In en, this message translates to:
  /// **'Wind {speed} km/h  ·  Humidity {humidity}%'**
  String windAndHumidity(String speed, int humidity);

  /// No description provided for @fireDangerLevel1.
  ///
  /// In en, this message translates to:
  /// **'Low fire danger'**
  String get fireDangerLevel1;

  /// No description provided for @fireDangerLevel2.
  ///
  /// In en, this message translates to:
  /// **'Moderate fire danger'**
  String get fireDangerLevel2;

  /// No description provided for @fireDangerLevel3.
  ///
  /// In en, this message translates to:
  /// **'Considerable fire danger'**
  String get fireDangerLevel3;

  /// No description provided for @fireDangerLevel4.
  ///
  /// In en, this message translates to:
  /// **'High fire danger'**
  String get fireDangerLevel4;

  /// No description provided for @fireDangerLevel5.
  ///
  /// In en, this message translates to:
  /// **'Very high fire danger'**
  String get fireDangerLevel5;

  /// No description provided for @fireDangerNoWarning.
  ///
  /// In en, this message translates to:
  /// **'No active fire warning'**
  String get fireDangerNoWarning;

  /// No description provided for @fireDangerNoData.
  ///
  /// In en, this message translates to:
  /// **'Fire status unavailable'**
  String get fireDangerNoData;

  /// No description provided for @fireDangerCheckCanton.
  ///
  /// In en, this message translates to:
  /// **'No data from BAFU — check cantonal website'**
  String get fireDangerCheckCanton;

  /// No description provided for @fireDangerSource.
  ///
  /// In en, this message translates to:
  /// **'waldbrandgefahr.ch'**
  String get fireDangerSource;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'fr', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
