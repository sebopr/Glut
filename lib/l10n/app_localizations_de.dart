// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get skip => 'Überspringen';

  @override
  String get continueButton => 'Weiter';

  @override
  String get notNow => 'Nicht jetzt';

  @override
  String get allowLocationAccess => 'Standort erlauben';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get onboardingTitle1 => 'Dein nächster\nFeuerplatz';

  @override
  String get onboardingSubtitle1 =>
      'Entdecke hunderte öffentliche Feuerstellen in der Schweiz, Deutschland und Österreich.';

  @override
  String get onboardingTitle2 => 'Wissen bevor\ndu losgehst';

  @override
  String get onboardingSubtitle2 =>
      'Feuerverbot, Holzversorgung und Grillinfos – alles auf einen Blick.';

  @override
  String get onboardingTitle3 => 'Standort aktivieren';

  @override
  String get onboardingSubtitle3 =>
      'So können wir dir nahegelegene Spots anzeigen und genaue Entfernungen angeben.';

  @override
  String get onboardingPermission1 => 'Feuerstellen in deiner Nähe anzeigen';

  @override
  String get onboardingPermission2 =>
      'Über Feuerverbote in deiner Region informieren';

  @override
  String get onboardingPermission3 =>
      'Niemals weitergegeben – bleibt auf deinem Gerät';

  @override
  String get searchPlaceholder => 'Stadt oder Gebiet suchen…';

  @override
  String get filterButton => 'Filter';

  @override
  String get searchThisArea => 'Diesen Bereich suchen';

  @override
  String get locationError => 'Standort nicht verfügbar';

  @override
  String get navMap => 'Karte';

  @override
  String get navSaved => 'Gespeichert';

  @override
  String get savedTitle => 'Gespeichert';

  @override
  String savedCount(int count) {
    return '$count Spots';
  }

  @override
  String get savedError => 'Spots konnten nicht geladen werden';

  @override
  String get savedEmptyTitle => 'Noch keine Spots gespeichert';

  @override
  String get savedEmptySubtitle =>
      'Tippe das Herz eines Spots an,\num ihn zu speichern';

  @override
  String spotsNearby(int count) {
    return '$count Spots in der Nähe';
  }

  @override
  String get amenityWood => 'Holz';

  @override
  String get amenityGrill => 'Grill';

  @override
  String get amenityFireplace => 'Feuerstelle';

  @override
  String get amenityShelter => 'Unterstand';

  @override
  String get amenityAccessible => 'Barrierefrei';

  @override
  String get amenityPicnicSite => 'Picknickplatz';

  @override
  String get amenityNoInfo => 'Keine Info';

  @override
  String distanceKmAway(String distance) {
    return '$distance km entfernt';
  }

  @override
  String get coordinatesCopiedClipboard => 'Koordinaten kopiert';

  @override
  String get coordinatesCopied => 'Koordinaten kopiert';

  @override
  String get fireAllowedToday => 'Feuer heute erlaubt';

  @override
  String get checkLocalRegulations =>
      'Lokale Vorschriften vor dem Anzünden prüfen';

  @override
  String get sectionAmenities => 'Ausstattung';

  @override
  String get noAmenityInfo => 'Keine Ausstattungsinfo verfügbar';

  @override
  String get actionNavigate => 'Navigieren';

  @override
  String get actionShare => 'Spot teilen';

  @override
  String get navSheetTitle => 'Zum Spot navigieren';

  @override
  String get navSheetSubtitle =>
      'Die meisten Feuerstellen sind nur zu Fuß erreichbar';

  @override
  String get navModeWalking => 'Zu Fuß';

  @override
  String get navModeDriving => 'Mit dem Auto';

  @override
  String get navSwisstopoSublabel => 'Empfohlen · Schweizer Wanderwege';

  @override
  String get navKomootSublabel => 'Empfohlen · Wanderwege';

  @override
  String get navWalkingDirections => 'Fußweg-Anweisungen';

  @override
  String get navDrivingDirections => 'Fahrtanweisungen';

  @override
  String get navViewGoogleMaps => 'Auf Google Maps ansehen';

  @override
  String get navStreetViewSublabel => 'Street View & Satellit';

  @override
  String get navCopyCoordinates => 'Koordinaten kopieren';

  @override
  String get filterTitle => 'Spots filtern';

  @override
  String get filterWoodProvided => 'Holz vorhanden';

  @override
  String get filterGrillAvailable => 'Grill verfügbar';

  @override
  String get filterShowResults => 'Ergebnisse anzeigen';

  @override
  String get sectionPhotos => 'Fotos';

  @override
  String get addPhoto => 'Foto hinzufügen';

  @override
  String get addPhotoSheetTitle => 'Foto hinzufügen';

  @override
  String get takePhoto => 'Foto aufnehmen';

  @override
  String get chooseFromLibrary => 'Aus Bibliothek wählen';

  @override
  String get beFirstToAddPhoto => 'Füge das erste Foto hinzu';

  @override
  String get maxPhotosReached => 'Maximal 3 Fotos pro Spot';

  @override
  String get reportPhoto => 'Foto melden';

  @override
  String get reportPhotoContent =>
      'Dieses Foto als nicht zum Grillen oder Feuerstellen passend melden?';

  @override
  String get report => 'Melden';

  @override
  String get photoUploadError =>
      'Foto konnte nicht hochgeladen werden, erneut versuchen';

  @override
  String get photoReportedSuccess => 'Foto gemeldet – danke für dein Feedback';

  @override
  String get photoReportedError =>
      'Meldung konnte nicht gesendet werden, versuche es erneut';

  @override
  String get weatherClearSky => 'Klarer Himmel';

  @override
  String get weatherPartlyCloudy => 'Teilweise bewölkt';

  @override
  String get weatherFoggy => 'Nebelig';

  @override
  String get weatherDrizzle => 'Nieselregen';

  @override
  String get weatherRainy => 'Regnerisch';

  @override
  String get weatherSnowy => 'Schneefall';

  @override
  String get weatherRainShowers => 'Regenschauer';

  @override
  String get weatherSnowShowers => 'Schneeschauer';

  @override
  String get weatherThunderstorm => 'Gewitter';

  @override
  String get weatherUnknown => 'Unbekannt';

  @override
  String get fireAdviceRain => 'Regen erwartet – Feuerverbot prüfen';

  @override
  String get fireAdviceWindy => 'Zu windig – hohe Brandgefahr';

  @override
  String get fireAdviceFreezing => 'Frost – warm anziehen';

  @override
  String get fireAdviceGood => 'Gute Bedingungen für ein Feuer';

  @override
  String get spotTypeFeuerstelle => 'Feuerstelle';

  @override
  String get spotTypeGrillplatz => 'Grillplatz';

  @override
  String get languagePickerTitle => 'Sprache';

  @override
  String get languageSystem => 'System (automatisch)';

  @override
  String windAndHumidity(String speed, int humidity) {
    return 'Wind $speed km/h  ·  Luftfeuchtigkeit $humidity%';
  }
}
