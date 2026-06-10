// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get skip => 'Salta';

  @override
  String get continueButton => 'Continua';

  @override
  String get notNow => 'Non ora';

  @override
  String get allowLocationAccess => 'Consenti la posizione';

  @override
  String get cancel => 'Annulla';

  @override
  String get onboardingTitle1 => 'Trova il tuo\nprossimo falò';

  @override
  String get onboardingSubtitle1 =>
      'Scopri centinaia di aree fuoco pubbliche in Svizzera, Germania e Austria.';

  @override
  String get onboardingTitle2 => 'Informati prima\ndi partire';

  @override
  String get onboardingSubtitle2 =>
      'Divieti di fuoco, disponibilità legna e info griglia – tutto in un posto.';

  @override
  String get onboardingTitle3 => 'Attiva la posizione';

  @override
  String get onboardingSubtitle3 =>
      'Per mostrarti i posti vicini e fornire distanze precise.';

  @override
  String get onboardingPermission1 => 'Mostra aree fuoco vicino a te';

  @override
  String get onboardingPermission2 =>
      'Avvisarti dei divieti di fuoco nella tua zona';

  @override
  String get onboardingPermission3 =>
      'Mai condiviso o venduto – rimane sul dispositivo';

  @override
  String get searchPlaceholder => 'Cerca città o zona…';

  @override
  String get filterButton => 'Filtra';

  @override
  String get searchThisArea => 'Cerca in quest\'area';

  @override
  String get locationError => 'Impossibile ottenere la posizione';

  @override
  String get navMap => 'Mappa';

  @override
  String get navSaved => 'Salvati';

  @override
  String get savedTitle => 'Salvati';

  @override
  String savedCount(int count) {
    return '$count posti';
  }

  @override
  String get savedError => 'Impossibile caricare i posti';

  @override
  String get savedEmptyTitle => 'Nessun posto salvato';

  @override
  String get savedEmptySubtitle => 'Tocca il cuore su un posto\nper salvarlo';

  @override
  String spotsNearby(int count) {
    return '$count posti nelle vicinanze';
  }

  @override
  String get amenityWood => 'Legna';

  @override
  String get amenityGrill => 'Griglia';

  @override
  String get amenityFireplace => 'Camino';

  @override
  String get amenityShelter => 'Riparo';

  @override
  String get amenityAccessible => 'Accessibile';

  @override
  String get amenityPicnicSite => 'Area picnic';

  @override
  String get amenityNoInfo => 'Nessuna info';

  @override
  String distanceKmAway(String distance) {
    return 'a $distance km';
  }

  @override
  String get coordinatesCopiedClipboard => 'Coordinate copiate';

  @override
  String get coordinatesCopied => 'Coordinate copiate';

  @override
  String get fireAllowedToday => 'Fuoco consentito oggi';

  @override
  String get checkLocalRegulations =>
      'Controlla le normative locali prima di accendere';

  @override
  String get sectionAmenities => 'Servizi';

  @override
  String get noAmenityInfo => 'Nessuna informazione sui servizi';

  @override
  String get actionNavigate => 'Naviga';

  @override
  String get actionShare => 'Condividi posto';

  @override
  String get navSheetTitle => 'Naviga verso il posto';

  @override
  String get navSheetSubtitle =>
      'La maggior parte dei posti è raggiungibile solo a piedi';

  @override
  String get navModeWalking => 'A piedi';

  @override
  String get navModeDriving => 'In auto';

  @override
  String get navSwisstopoSublabel => 'Consigliato · Sentieri svizzeri';

  @override
  String get navKomootSublabel => 'Consigliato · Sentieri escursionistici';

  @override
  String get navWalkingDirections => 'Indicazioni a piedi';

  @override
  String get navDrivingDirections => 'Indicazioni in auto';

  @override
  String get navViewGoogleMaps => 'Visualizza su Google Maps';

  @override
  String get navStreetViewSublabel => 'Street View e satellite';

  @override
  String get navCopyCoordinates => 'Copia coordinate';

  @override
  String get filterTitle => 'Filtra posti';

  @override
  String get filterWoodProvided => 'Legna disponibile';

  @override
  String get filterGrillAvailable => 'Griglia disponibile';

  @override
  String get filterShowResults => 'Mostra risultati';

  @override
  String get sectionPhotos => 'Foto';

  @override
  String get addPhoto => 'Aggiungi foto';

  @override
  String get addPhotoSheetTitle => 'Aggiungi una foto';

  @override
  String get takePhoto => 'Scatta una foto';

  @override
  String get chooseFromLibrary => 'Scegli dalla libreria';

  @override
  String get beFirstToAddPhoto => 'Sii il primo ad aggiungere una foto';

  @override
  String get maxPhotosReached => 'Massimo 3 foto per posto';

  @override
  String get reportPhoto => 'Segnala foto';

  @override
  String get reportPhotoContent =>
      'Segnalare questa foto come non pertinente alle aree fuoco?';

  @override
  String get report => 'Segnala';

  @override
  String get photoUploadError => 'Impossibile caricare la foto, riprova';

  @override
  String get photoReportedSuccess => 'Foto segnalata – grazie per il feedback';

  @override
  String get photoReportedError =>
      'Impossibile inviare la segnalazione, riprova';

  @override
  String get weatherClearSky => 'Cielo sereno';

  @override
  String get weatherPartlyCloudy => 'Parzialmente nuvoloso';

  @override
  String get weatherFoggy => 'Nebbioso';

  @override
  String get weatherDrizzle => 'Pioggerella';

  @override
  String get weatherRainy => 'Piovoso';

  @override
  String get weatherSnowy => 'Nevoso';

  @override
  String get weatherRainShowers => 'Rovesci di pioggia';

  @override
  String get weatherSnowShowers => 'Rovesci di neve';

  @override
  String get weatherThunderstorm => 'Temporale';

  @override
  String get weatherUnknown => 'Sconosciuto';

  @override
  String get fireAdviceRain =>
      'Pioggia prevista – controlla il divieto di fuoco';

  @override
  String get fireAdviceWindy => 'Troppo ventoso – alto rischio incendio';

  @override
  String get fireAdviceFreezing => 'Gelo – vestiti caldi';

  @override
  String get fireAdviceGood => 'Buone condizioni per un fuoco';

  @override
  String get spotTypeFeuerstelle => 'Posto fuoco';

  @override
  String get spotTypeGrillplatz => 'Area barbecue';

  @override
  String get languagePickerTitle => 'Lingua';

  @override
  String get languageSystem => 'Sistema (automatico)';

  @override
  String windAndHumidity(String speed, int humidity) {
    return 'Vento $speed km/h  ·  Umidità $humidity%';
  }
}
