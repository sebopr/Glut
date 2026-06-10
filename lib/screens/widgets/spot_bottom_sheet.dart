import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../models/spot.dart';
import '../../providers/spots_provider.dart';
import '../../theme.dart';
import 'spot_card.dart';

class SpotBottomSheet extends ConsumerStatefulWidget {
  final Function(Spot) onSpotTap;
  final Spot? selectedSpot;
  final ScrollController? scrollController;
  final DraggableScrollableController? sheetController;
  final bool listScrollable;

  const SpotBottomSheet({
    super.key,
    required this.onSpotTap,
    this.selectedSpot,
    this.scrollController,
    this.sheetController,
    this.listScrollable = true,
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

    // Expand sheet to middle if collapsed
    if (widget.sheetController != null && widget.sheetController!.size < 0.42) {
      widget.sheetController!.animateTo(
        0.42,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }

    // Use whichever controller is attached to the ListView
    final controller = widget.scrollController ?? _scrollController;

    final spots = ref.read(filteredSpotsProvider);
    spots.whenData((list) {
      final index = list.indexWhere((s) => s.id == widget.selectedSpot!.id);
      if (index == -1) return;

      // Wait for sheet animation to finish before scrolling
      Future.delayed(const Duration(milliseconds: 350), () {
        if (!controller.hasClients) return;

        final viewportHeight = controller.position.viewportDimension;
        final offset =
            (_itemExtent * index) - (viewportHeight / 2) + (_itemExtent / 2);

        controller.animateTo(
          offset.clamp(0.0, controller.position.maxScrollExtent),
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      });
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
    // Use external scroll controller or fall back to internal one
    final scrollController = widget.scrollController ?? _scrollController;

    return Container(
      decoration: const BoxDecoration(
        color: GlutTheme.ash,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Drag handle
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragUpdate: (details) {
              if (widget.sheetController == null) return;
              final size = widget.sheetController!.size;
              final delta =
                  -details.primaryDelta! / MediaQuery.of(context).size.height;
              final newSize = (size + delta).clamp(0.08, 0.85);
              widget.sheetController!.jumpTo(newSize);
            },
            onVerticalDragEnd: (details) {
              if (widget.sheetController == null) return;
              final size = widget.sheetController!.size;
              if (size < 0.25) {
                widget.sheetController!.animateTo(
                  0.08,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                );
              } else if (size < 0.63) {
                widget.sheetController!.animateTo(
                  0.42,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                );
              } else {
                widget.sheetController!.animateTo(
                  0.85,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                );
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Container(
                  width: 32,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
          // Count
          spots.when(
            data: (list) => Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppLocalizations.of(context)!.spotsNearby(list.length),
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          // List
          Expanded(
            child: spots.when(
              data: (list) => ListView.builder(
                controller: widget.scrollController ?? _scrollController,
                physics: widget.listScrollable
                    ? const ClampingScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
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
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
