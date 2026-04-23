import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/spot.dart';
import '../../providers/spots_provider.dart';
import '../../theme.dart';
import 'spot_card.dart';

class SpotBottomSheet extends ConsumerStatefulWidget {
  final Function(Spot) onSpotTap;
  final Spot? selectedSpot;

  const SpotBottomSheet({
    super.key,
    required this.onSpotTap,
    this.selectedSpot,
  });

  @override
  ConsumerState<SpotBottomSheet> createState() => _SpotBottomSheetState();
}

class _SpotBottomSheetState extends ConsumerState<SpotBottomSheet> {
  final _scrollController = ScrollController();
  String? _lastSelectedId;
  static const double _itemExtent = 76.0;

  @override
  void didUpdateWidget(SpotBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedSpot != null &&
        widget.selectedSpot!.id != _lastSelectedId) {
      _lastSelectedId = widget.selectedSpot!.id;
      Future.delayed(const Duration(milliseconds: 150), _scrollToSelected);
    }
  }

  void _scrollToSelected() {
    if (widget.selectedSpot == null) return;
    if (!_scrollController.hasClients) return;

    final spots = ref.read(filteredSpotsProvider);
    spots.whenData((list) {
      final index = list.indexWhere((s) => s.id == widget.selectedSpot!.id);
      if (index == -1) return;

      final viewportHeight = _scrollController.position.viewportDimension;
      final offset =
          (_itemExtent * index) - (viewportHeight / 2) + (_itemExtent / 2);

      _scrollController.animateTo(
        offset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spots = ref.watch(filteredSpotsProvider);

    return DraggableScrollableSheet(
      initialChildSize: 1.0,
      minChildSize: 1.0,
      maxChildSize: 1.0,
      builder: (context, _) {
        return Container(
          decoration: const BoxDecoration(
            color: GlutTheme.ash,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Container(
                  width: 32,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              spots.when(
                data: (list) => Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${list.length} spots nearby',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              Expanded(
                child: spots.when(
                  data: (list) => ListView.builder(
                    controller: _scrollController,
                    itemExtent: _itemExtent,
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 32),
                    itemCount: list.length,
                    itemBuilder: (_, i) => SpotCard(
                      spot: list[i],
                      highlighted: widget.selectedSpot?.id == list[i].id,
                      onTap: () => widget.onSpotTap(list[i]),
                    ),
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: GlutTheme.ember),
                  ),
                  error: (e, _) => Center(
                    child: Text(
                      'Error: $e',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
