import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/spots_provider.dart';
import '../theme.dart';
import 'spot_detail_screen.dart';
import 'widgets/spot_card.dart';

class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favouriteIds = ref.watch(favouritesProvider);
    final allSpots = ref.watch(spotsProvider);

    return Scaffold(
      backgroundColor: GlutTheme.ash,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Saved',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 28,
                      color: GlutTheme.linen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${favouriteIds.length} spots',
                    style: const TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                ],
              ),
            ),
            Expanded(
              child: favouriteIds.isEmpty
                  ? const _EmptyState()
                  : allSpots.when(
                      data: (spots) {
                        final saved = spots
                            .where((s) => favouriteIds.contains(s.id))
                            .toList();
                        if (saved.isEmpty) return const _EmptyState();
                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 32),
                          itemCount: saved.length,
                          itemBuilder: (_, i) => SpotCard(
                            spot: saved[i],
                            highlighted: false,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    SpotDetailScreen(spot: saved[i]),
                              ),
                            ),
                          ),
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(
                          color: GlutTheme.ember,
                        ),
                      ),
                      error: (e, _) => const Center(
                        child: Text(
                          'Could not load spots',
                          style: TextStyle(color: Colors.white38),
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
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          const Text(
            'No saved spots yet',
            style: TextStyle(
              color: GlutTheme.linen,
              fontSize: 18,
              fontFamily: 'Georgia',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the heart on any spot\nto save it for later',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}
