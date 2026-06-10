// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get skip => 'Passer';

  @override
  String get continueButton => 'Continuer';

  @override
  String get notNow => 'Pas maintenant';

  @override
  String get allowLocationAccess => 'Autoriser la localisation';

  @override
  String get cancel => 'Annuler';

  @override
  String get onboardingTitle1 => 'Trouve ton prochain\nspot de feu';

  @override
  String get onboardingSubtitle1 =>
      'Découvre des centaines de places de feu publiques en Suisse, en Allemagne et en Autriche.';

  @override
  String get onboardingTitle2 => 'Sache avant\nde partir';

  @override
  String get onboardingSubtitle2 =>
      'Interdictions de feu, disponibilité du bois et infos grill – tout en un seul endroit.';

  @override
  String get onboardingTitle3 => 'Activer la localisation';

  @override
  String get onboardingSubtitle3 =>
      'Pour t\'afficher les spots proches et donner des distances précises.';

  @override
  String get onboardingPermission1 => 'Afficher les spots de feu près de toi';

  @override
  String get onboardingPermission2 =>
      'T\'alerter sur les interdictions de feu dans ta zone';

  @override
  String get onboardingPermission3 =>
      'Jamais partagé ni vendu – reste sur l\'appareil';

  @override
  String get searchPlaceholder => 'Chercher une ville ou zone…';

  @override
  String get filterButton => 'Filtrer';

  @override
  String get searchThisArea => 'Chercher dans cette zone';

  @override
  String get locationError => 'Impossible d\'obtenir la position';

  @override
  String get navMap => 'Carte';

  @override
  String get navSaved => 'Sauvegardés';

  @override
  String get savedTitle => 'Sauvegardés';

  @override
  String savedCount(int count) {
    return '$count spots';
  }

  @override
  String get savedError => 'Impossible de charger les spots';

  @override
  String get savedEmptyTitle => 'Aucun spot sauvegardé';

  @override
  String get savedEmptySubtitle =>
      'Touche le cœur d\'un spot\npour le sauvegarder';

  @override
  String spotsNearby(int count) {
    return '$count spots à proximité';
  }

  @override
  String get amenityWood => 'Bois';

  @override
  String get amenityGrill => 'Grill';

  @override
  String get amenityFireplace => 'Foyer';

  @override
  String get amenityShelter => 'Abri';

  @override
  String get amenityAccessible => 'Accessible';

  @override
  String get amenityPicnicSite => 'Aire de pique-nique';

  @override
  String get amenityNoInfo => 'Pas d\'info';

  @override
  String distanceKmAway(String distance) {
    return 'à $distance km';
  }

  @override
  String get coordinatesCopiedClipboard => 'Coordonnées copiées';

  @override
  String get coordinatesCopied => 'Coordonnées copiées';

  @override
  String get fireAllowedToday => 'Feu autorisé aujourd\'hui';

  @override
  String get checkLocalRegulations =>
      'Vérifier la réglementation locale avant d\'allumer';

  @override
  String get sectionAmenities => 'Équipements';

  @override
  String get noAmenityInfo => 'Aucune info sur les équipements';

  @override
  String get actionNavigate => 'Naviguer';

  @override
  String get actionShare => 'Partager ce spot';

  @override
  String get navSheetTitle => 'Naviguer vers le spot';

  @override
  String get navSheetSubtitle =>
      'La plupart des spots ne sont accessibles qu\'à pied';

  @override
  String get navModeWalking => 'À pied';

  @override
  String get navModeDriving => 'En voiture';

  @override
  String get navSwisstopoSublabel => 'Recommandé · Sentiers suisses';

  @override
  String get navKomootSublabel => 'Recommandé · Sentiers de randonnée';

  @override
  String get navWalkingDirections => 'Itinéraire à pied';

  @override
  String get navDrivingDirections => 'Itinéraire en voiture';

  @override
  String get navViewGoogleMaps => 'Voir sur Google Maps';

  @override
  String get navStreetViewSublabel => 'Street View & satellite';

  @override
  String get navCopyCoordinates => 'Copier les coordonnées';

  @override
  String get filterTitle => 'Filtrer les spots';

  @override
  String get filterWoodProvided => 'Bois fourni';

  @override
  String get filterGrillAvailable => 'Grill disponible';

  @override
  String get filterShowResults => 'Afficher les résultats';

  @override
  String get sectionPhotos => 'Photos';

  @override
  String get addPhoto => 'Ajouter une photo';

  @override
  String get addPhotoSheetTitle => 'Ajouter une photo';

  @override
  String get takePhoto => 'Prendre une photo';

  @override
  String get chooseFromLibrary => 'Choisir dans la bibliothèque';

  @override
  String get beFirstToAddPhoto => 'Sois le premier à ajouter une photo';

  @override
  String get maxPhotosReached => 'Maximum 3 photos par spot';

  @override
  String get reportPhoto => 'Signaler la photo';

  @override
  String get reportPhotoContent =>
      'Signaler cette photo comme non pertinente aux places de feu?';

  @override
  String get report => 'Signaler';

  @override
  String get photoUploadError => 'Impossible d\'envoyer la photo, réessaie';

  @override
  String get photoReportedSuccess => 'Photo signalée – merci pour ton retour';

  @override
  String get photoReportedError =>
      'Impossible d\'envoyer le signalement, réessaie';

  @override
  String get weatherClearSky => 'Ciel dégagé';

  @override
  String get weatherPartlyCloudy => 'Partiellement nuageux';

  @override
  String get weatherFoggy => 'Brumeux';

  @override
  String get weatherDrizzle => 'Bruine';

  @override
  String get weatherRainy => 'Pluvieux';

  @override
  String get weatherSnowy => 'Neigeux';

  @override
  String get weatherRainShowers => 'Averses de pluie';

  @override
  String get weatherSnowShowers => 'Averses de neige';

  @override
  String get weatherThunderstorm => 'Orage';

  @override
  String get weatherUnknown => 'Inconnu';

  @override
  String get fireAdviceRain => 'Pluie prévue – vérifier l\'interdiction de feu';

  @override
  String get fireAdviceWindy => 'Trop venteux – risque d\'incendie élevé';

  @override
  String get fireAdviceFreezing => 'Gel – habille-toi chaudement';

  @override
  String get fireAdviceGood => 'Bonnes conditions pour un feu';

  @override
  String get spotTypeFeuerstelle => 'Place de feu';

  @override
  String get spotTypeGrillplatz => 'Aire de barbecue';

  @override
  String get languagePickerTitle => 'Langue';

  @override
  String get languageSystem => 'Système (automatique)';

  @override
  String windAndHumidity(String speed, int humidity) {
    return 'Vent $speed km/h  ·  Humidité $humidity%';
  }
}
