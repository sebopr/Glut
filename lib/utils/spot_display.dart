import '../l10n/app_localizations.dart';

// Replaces known German fire-spot type words inside OSM names.
// Uses \b word boundaries so compounds like "Waldgrillplatz" are left intact.
// For the German locale the replacements are identical words, so it's a no-op.
String localizedSpotName(String name, AppLocalizations l10n) {
  String result = name;

  result = result.replaceAllMapped(
    RegExp(r'\bFeuerstelle\b'),
    (_) => l10n.spotTypeFeuerstelle,
  );
  result = result.replaceAllMapped(
    RegExp(r'\bGrillplatz\b'),
    (_) => l10n.spotTypeGrillplatz,
  );
  result = result.replaceAllMapped(
    RegExp(r'\bGrillstelle\b'),
    (_) => l10n.spotTypeGrillplatz,
  );
  if (result == 'Picnic Site') return l10n.amenityPicnicSite;

  return result;
}
