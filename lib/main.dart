import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/root_screen.dart';
import 'screens/onboarding_screen.dart';
import 'theme.dart';
import 'l10n/app_localizations.dart';
import 'providers/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://baihpuerlrsycyxpctka.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJhaWhwdWVybHJzeWN5eHBjdGthIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc0MDE3NDQsImV4cCI6MjA5Mjk3Nzc0NH0.CGq8-vc4vhT2LcV_DuoTIEmrMXke9UoA_X_Im3h7uhs',
  );

  final prefs = await SharedPreferences.getInstance();
  final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
  final localeCode = prefs.getString('locale');
  final savedLocale = localeCode != null ? Locale(localeCode) : null;

  runApp(
    ProviderScope(
      overrides: [
        localeProvider.overrideWith(() => LocaleNotifier(savedLocale)),
      ],
      child: GlutApp(onboardingComplete: onboardingComplete),
    ),
  );
}

class GlutApp extends ConsumerWidget {
  final bool onboardingComplete;
  const GlutApp({super.key, required this.onboardingComplete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return MaterialApp(
      title: 'Glut',
      theme: GlutTheme.dark,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: onboardingComplete ? const RootScreen() : const OnboardingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
