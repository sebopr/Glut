import 'package:flutter/material.dart';
import '../services/photo_service.dart';
import '../theme.dart';

// Change this to your preferred admin PIN
const String _adminPin = '1713';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<Map<String, dynamic>> _pending = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final photos = await PhotoService.getPendingPhotos();
    if (mounted) setState(() { _pending = photos; _loading = false; });
  }

  Future<void> _review(String id, bool approve) async {
    final ok = await PhotoService.reviewPhoto(photoId: id, approve: approve);
    if (ok && mounted) {
      setState(() => _pending.removeWhere((p) => p['id'] == id));
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
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: GlutTheme.ember, strokeWidth: 2))
          : _pending.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.white24, size: 48),
                      SizedBox(height: 12),
                      Text('No pending photos', style: TextStyle(color: Colors.white38, fontSize: 14)),
                    ],
                  ),
                )
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
