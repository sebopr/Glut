import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/spots_provider.dart';
import '../../theme.dart';

class FilterSheet extends ConsumerWidget {
  const FilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final needsWood = ref.watch(filterWoodProvider);
    final needsGrill = ref.watch(filterGrillProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.filterTitle,
            style: const TextStyle(
              color: GlutTheme.linen,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          _ToggleRow(
            label: l10n.filterWoodProvided,
            value: needsWood,
            onToggle: () => ref.read(filterWoodProvider.notifier).toggle(),
          ),
          const Divider(color: Colors.white10),
          _ToggleRow(
            label: l10n.filterGrillAvailable,
            value: needsGrill,
            onToggle: () => ref.read(filterGrillProvider.notifier).toggle(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: GlutTheme.ember,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.filterShowResults,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final VoidCallback onToggle;

  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: GlutTheme.linen, fontSize: 14),
        ),
        Switch(
          value: value,
          onChanged: (_) => onToggle(),
          activeThumbColor: GlutTheme.ember,
        ),
      ],
    );
  }
}
