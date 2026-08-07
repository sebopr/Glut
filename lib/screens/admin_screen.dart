import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../services/photo_service.dart';
import '../theme.dart';

// Change this to your preferred admin PIN
const String _adminPin = '1713';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<Map<String, dynamic>> _pending = [];
  List<Map<String, dynamic>> _reported = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      PhotoService.getPendingPhotos(),
      PhotoService.getReportedPhotos(),
    ]);
    if (mounted) {
      setState(() {
        _pending = results[0];
        _reported = results[1];
        _loading = false;
      });
    }
  }

  Future<void> _review(String id, bool approve) async {
    final ok = await PhotoService.reviewPhoto(photoId: id, approve: approve);
    if (ok && mounted) {
      setState(() => _pending.removeWhere((p) => p['id'] == id));
    }
  }

  Future<void> _dismissReport(String photoUrl) async {
    final ok = await PhotoService.dismissReports(photoUrl);
    if (ok && mounted) {
      setState(() => _reported.removeWhere((p) => p['photo_url'] == photoUrl));
    }
  }

  Future<void> _removeReported(String photoUrl) async {
    final ok = await PhotoService.removeReportedPhoto(photoUrl);
    if (ok && mounted) {
      setState(() => _reported.removeWhere((p) => p['photo_url'] == photoUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlutTheme.ash,
      appBar: AppBar(
        backgroundColor: GlutTheme.coal,
        title: const Text(
          'Photo Review',
          style: TextStyle(color: GlutTheme.linen, fontSize: 16, fontWeight: FontWeight.w500),
        ),
        iconTheme: const IconThemeData(color: GlutTheme.linen),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: GlutTheme.linen),
            onPressed: _load,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: GlutTheme.ember,
          labelColor: GlutTheme.linen,
          unselectedLabelColor: Colors.white38,
          tabs: [
            Tab(text: 'Pending (${_pending.length})'),
            Tab(text: 'Reported (${_reported.length})'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: GlutTheme.ember, strokeWidth: 2))
          : TabBarView(
              controller: _tabController,
              children: [
                _pending.isEmpty
                    ? const _EmptyState(label: 'No pending photos')
                    : RefreshIndicator(
                        color: GlutTheme.ember,
                        backgroundColor: GlutTheme.coal,
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _pending.length,
                          itemBuilder: (_, i) {
                            final photo = _pending[i];
                            return _PendingPhotoCard(
                              photo: photo,
                              onApprove: () => _review(photo['id'] as String, true),
                              onReject: () => _review(photo['id'] as String, false),
                            );
                          },
                        ),
                      ),
                _reported.isEmpty
                    ? const _EmptyState(label: 'No reported photos')
                    : RefreshIndicator(
                        color: GlutTheme.ember,
                        backgroundColor: GlutTheme.coal,
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _reported.length,
                          itemBuilder: (_, i) {
                            final photo = _reported[i];
                            final url = photo['photo_url'] as String;
                            return _ReportedPhotoCard(
                              photo: photo,
                              onDismiss: () => _dismissReport(url),
                              onRemove: () => _removeReported(url),
                            );
                          },
                        ),
                      ),
              ],
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String label;
  const _EmptyState({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.white24, size: 48),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 14)),
        ],
      ),
    );
  }
}

class _PendingPhotoCard extends StatefulWidget {
  final Map<String, dynamic> photo;
  final Future<void> Function() onApprove;
  final Future<void> Function() onReject;

  const _PendingPhotoCard({
    required this.photo,
    required this.onApprove,
    required this.onReject,
  });

  @override
  State<_PendingPhotoCard> createState() => _PendingPhotoCardState();
}

class _PendingPhotoCardState extends State<_PendingPhotoCard> {
  bool _busy = false;

  Future<void> _handle(bool approve) async {
    setState(() => _busy = true);
    try {
      await (approve ? widget.onApprove() : widget.onReject());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _locationBadge(Map<String, dynamic> photo) {
    final photoLat = photo['photo_lat'] as double?;
    final photoLng = photo['photo_lng'] as double?;
    final spotLat  = photo['spot_lat']  as double?;
    final spotLng  = photo['spot_lng']  as double?;

    if (photoLat == null || photoLng == null || spotLat == null || spotLng == null) {
      return const Row(
        children: [
          Icon(Icons.location_off_outlined, size: 12, color: Colors.white24),
          SizedBox(width: 4),
          Text('No GPS data', style: TextStyle(color: Colors.white24, fontSize: 11)),
        ],
      );
    }

    final distanceM = const Distance().as(
      LengthUnit.Meter,
      LatLng(photoLat, photoLng),
      LatLng(spotLat, spotLng),
    );
    final inRange = distanceM <= 250;
    final color = inRange ? Colors.greenAccent : Colors.orangeAccent;
    final label = distanceM < 1000
        ? '${distanceM.toInt()}m from spot'
        : '${(distanceM / 1000).toStringAsFixed(1)}km from spot';

    return Row(
      children: [
        Icon(Icons.location_on_outlined, size: 12, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontSize: 11)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final spotId = widget.photo['spot_id'] as String;
    final shortId = spotId.length > 14 ? '${spotId.substring(0, 14)}…' : spotId;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: GlutTheme.coal,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              widget.photo['url'] as String,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : SizedBox(
                      height: 220,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: progress.expectedTotalBytes != null
                              ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                              : null,
                          color: GlutTheme.ember,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
              errorBuilder: (_, _, _) => const SizedBox(
                height: 220,
                child: Center(child: Icon(Icons.broken_image_outlined, color: Colors.white24, size: 40)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Spot $shortId',
                  style: const TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 0.3),
                ),
                const SizedBox(height: 6),
                _locationBadge(widget.photo),
                const SizedBox(height: 10),
                if (_busy)
                  const SizedBox(
                    height: 40,
                    child: Center(child: CircularProgressIndicator(color: GlutTheme.ember, strokeWidth: 2)),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _handle(false),
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                            ),
                            child: const Center(
                              child: Text(
                                'Reject',
                                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500, fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _handle(true),
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                            ),
                            child: const Center(
                              child: Text(
                                'Approve',
                                style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.w500, fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportedPhotoCard extends StatefulWidget {
  final Map<String, dynamic> photo;
  final Future<void> Function() onDismiss;
  final Future<void> Function() onRemove;

  const _ReportedPhotoCard({
    required this.photo,
    required this.onDismiss,
    required this.onRemove,
  });

  @override
  State<_ReportedPhotoCard> createState() => _ReportedPhotoCardState();
}

class _ReportedPhotoCardState extends State<_ReportedPhotoCard> {
  static const _autoDeleteThreshold = 5;
  bool _busy = false;

  Future<void> _handle(bool remove) async {
    setState(() => _busy = true);
    try {
      await (remove ? widget.onRemove() : widget.onDismiss());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final spotId = widget.photo['spot_id'] as String;
    final shortId = spotId.length > 14 ? '${spotId.substring(0, 14)}…' : spotId;
    final reportCount = widget.photo['report_count'] as int;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: GlutTheme.coal,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              widget.photo['photo_url'] as String,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : SizedBox(
                      height: 220,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: progress.expectedTotalBytes != null
                              ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                              : null,
                          color: GlutTheme.ember,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
              errorBuilder: (_, _, _) => const SizedBox(
                height: 220,
                child: Center(child: Icon(Icons.broken_image_outlined, color: Colors.white24, size: 40)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Spot $shortId',
                  style: const TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 0.3),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.flag_outlined, size: 12, color: Colors.orangeAccent),
                    const SizedBox(width: 4),
                    Text(
                      '$reportCount/$_autoDeleteThreshold reports',
                      style: const TextStyle(color: Colors.orangeAccent, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (_busy)
                  const SizedBox(
                    height: 40,
                    child: Center(child: CircularProgressIndicator(color: GlutTheme.ember, strokeWidth: 2)),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _handle(false),
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: const Center(
                              child: Text(
                                'Dismiss',
                                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500, fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _handle(true),
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                            ),
                            child: const Center(
                              child: Text(
                                'Remove',
                                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500, fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows a PIN entry dialog. Returns true if correct PIN was entered.
Future<bool> showAdminPinDialog(BuildContext context) async {
  final controller = TextEditingController();
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (_) => AlertDialog(
      backgroundColor: GlutTheme.coal,
      title: const Text(
        'Admin Access',
        style: TextStyle(color: GlutTheme.linen, fontSize: 16),
      ),
      content: TextField(
        controller: controller,
        autofocus: true,
        obscureText: true,
        keyboardType: TextInputType.number,
        maxLength: 6,
        style: const TextStyle(color: GlutTheme.linen, letterSpacing: 8),
        decoration: const InputDecoration(
          hintText: '••••',
          hintStyle: TextStyle(color: Colors.white24, letterSpacing: 4),
          counterText: '',
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: GlutTheme.ember)),
        ),
        onSubmitted: (_) => Navigator.pop(context, controller.text == _adminPin),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text == _adminPin),
          child: const Text('Enter', style: TextStyle(color: GlutTheme.ember)),
        ),
      ],
    ),
  );
  return result == true;
}
