import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../providers/spots_provider.dart';
import '../theme.dart';
import 'spot_detail_screen.dart';
import 'widgets/language_picker.dart';
import 'widgets/spot_card.dart';

class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final savedSpots = ref.watch(savedSpotsProvider);

    return Scaffold(
      backgroundColor: GlutTheme.ash,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 8, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.savedTitle,
                          style: const TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 28,
                            color: GlutTheme.linen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          l10n.savedCount(savedSpots.value?.length ?? 0),
                          style: const TextStyle(color: Colors.white38, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => showLanguagePicker(context),
                    icon: const Icon(Icons.language, color: Colors.white38, size: 22),
                  ),
                ],
              ),
            ),
            Expanded(
              child: savedSpots.when(
                data: (spots) {
                  if (spots.isEmpty) return _EmptyState(l10n: l10n);
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 32),
                    itemCount: spots.length,
                    itemBuilder: (_, i) => SpotCard(
                      spot: spots[i],
                      highlighted: false,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SpotDetailScreen(spot: spots[i]),
                        ),
                      ),
                    ),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: GlutTheme.ember),
                ),
                error: (e, _) => Center(
                  child: Text(
                    l10n.savedError,
                    style: const TextStyle(color: Colors.white38),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations l10n;
  const _EmptyState({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.local_fire_department, size: 48, color: GlutTheme.ember),
          const SizedBox(height: 16),
          Text(
            l10n.savedEmptyTitle,
            style: const TextStyle(
              color: GlutTheme.linen,
              fontSize: 18,
              fontFamily: 'Georgia',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.savedEmptySubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white38, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}
