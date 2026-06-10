import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../theme.dart';

void showLanguagePicker(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: GlutTheme.coal,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => const _LanguagePickerSheet(),
  );
}

class _LanguagePickerSheet extends ConsumerWidget {
  const _LanguagePickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);

    final options = [
      _LangOption(locale: null, code: 'auto', name: l10n.languageSystem),
      _LangOption(locale: const Locale('en'), code: 'EN', name: 'English'),
      _LangOption(locale: const Locale('de'), code: 'DE', name: 'Deutsch'),
      _LangOption(locale: const Locale('it'), code: 'IT', name: 'Italiano'),
      _LangOption(locale: const Locale('fr'), code: 'FR', name: 'Français'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.languagePickerTitle,
            style: const TextStyle(
              color: GlutTheme.linen,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          for (final opt in options) ...[
            _LanguageRow(
              option: opt,
              selected: opt.locale?.languageCode == currentLocale?.languageCode,
              onTap: () {
                ref.read(localeProvider.notifier).setLocale(opt.locale);
                Navigator.pop(context);
              },
            ),
            if (opt != options.last)
              const Divider(color: Colors.white10, height: 1),
          ],
        ],
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  final _LangOption option;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageRow({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            _LangBadge(code: option.code, selected: selected),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                option.name,
                style: TextStyle(
                  color: selected ? GlutTheme.linen : Colors.white54,
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check, color: GlutTheme.ember, size: 18),
          ],
        ),
      ),
    );
  }
}

class _LangBadge extends StatelessWidget {
  final String code;
  final bool selected;

  const _LangBadge({required this.code, required this.selected});

  @override
  Widget build(BuildContext context) {
    if (code == 'auto') {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: selected ? GlutTheme.ember.withValues(alpha: 0.15) : GlutTheme.ash,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? GlutTheme.ember.withValues(alpha: 0.4) : Colors.white12,
          ),
        ),
        child: Icon(
          Icons.language,
          size: 16,
          color: selected ? GlutTheme.ember : Colors.white38,
        ),
      );
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: selected ? GlutTheme.ember.withValues(alpha: 0.15) : GlutTheme.ash,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selected ? GlutTheme.ember.withValues(alpha: 0.4) : Colors.white12,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        code,
        style: TextStyle(
          color: selected ? GlutTheme.ember : Colors.white38,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _LangOption {
  final Locale? locale;
  final String code;
  final String name;
  const _LangOption({required this.locale, required this.code, required this.name});
}
