import 'dart:io';
import 'dart:ui' show ImageFilter;
import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../l10n/app_localizations.dart';
import '../../services/device_id_service.dart';
import '../../services/photo_service.dart';
import '../../theme.dart';

class SpotPhotos extends StatefulWidget {
  final String spotId;
  final double spotLat;
  final double spotLng;
  const SpotPhotos({
    super.key,
    required this.spotId,
    required this.spotLat,
    required this.spotLng,
  });

  @override
  State<SpotPhotos> createState() => _SpotPhotosState();
}

class _SpotPhotosState extends State<SpotPhotos> {
  List<String> _approved = [];
  List<String> _pending = [];
  bool _loading = true;
  bool _uploading = false;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    if (mounted) setState(() => _loading = true);
    final deviceId = await DeviceIdService.getDeviceId();
    final results = await Future.wait([
      PhotoService.getApprovedPhotos(widget.spotId),
      PhotoService.getMyPendingPhotos(widget.spotId, deviceId),
    ]);
    if (mounted) {
      setState(() {
        _approved = results[0];
        _pending = results[1];
        _loading = false;
      });
    }
  }

  SnackBar _infoSnackBar(String msg) => SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(msg,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
            const Icon(Icons.info_outline, color: Colors.orange, size: 18),
          ],
        ),
        backgroundColor: GlutTheme.coal,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      );

  void _showAddPhotoSheet() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: GlutTheme.coal,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.addPhotoSheetTitle,
              style: const TextStyle(
                  color: GlutTheme.linen,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading:
                  const Icon(Icons.camera_alt_outlined, color: GlutTheme.ember),
              title: Text(l10n.takePhoto,
                  style: const TextStyle(color: GlutTheme.linen)),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: GlutTheme.ember),
              title: Text(l10n.chooseFromLibrary,
                  style: const TextStyle(color: GlutTheme.linen)),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    ).then((source) {
      debugPrint('📸 sheet closed — source=$source mounted=$mounted');
      if (source != null) _pickImage(source);
    });
  }

  // Returns GPS coordinates from the image EXIF, or null if absent/unreadable.
  Future<(double lat, double lng)?> _exifGps(File file) async {
    try {
      final tags = await readExifFromBytes(await file.readAsBytes());
      final latTag = tags['GPS GPSLatitude'];
      final latRef = tags['GPS GPSLatitudeRef']?.printable ?? 'N';
      final lngTag = tags['GPS GPSLongitude'];
      final lngRef = tags['GPS GPSLongitudeRef']?.printable ?? 'E';
      if (latTag == null || lngTag == null) return null;

      double dms(IfdTag t, String ref) {
        final r = t.values.toList();
        final d = (r[0] as Ratio).toDouble();
        final m = (r[1] as Ratio).toDouble();
        final s = (r[2] as Ratio).toDouble();
        final v = d + m / 60.0 + s / 3600.0;
        return (ref == 'S' || ref == 'W') ? -v : v;
      }

      return (dms(latTag, latRef), dms(lngTag, lngRef));
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    debugPrint('📸 _pickImage start — source=$source');
    try {
      final l10n = AppLocalizations.of(context)!;
      final messenger = ScaffoldMessenger.of(context);

      if (_approved.length + _pending.length >= 3) {
        messenger.showSnackBar(_infoSnackBar(l10n.maxPhotosReached));
        return;
      }

      debugPrint('📸 opening picker');
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1440,
        imageQuality: 90,
      );
      debugPrint('📸 picker returned — path=${picked?.path ?? 'null'} mounted=$mounted');

      if (picked == null) return;
      if (!mounted) return;

      // Extract GPS from EXIF so the admin can see where the photo was taken.
      final gps = await _exifGps(File(picked.path));

      setState(() => _uploading = true);

      debugPrint('📸 calling uploadPhoto');
      final deviceId = await DeviceIdService.getDeviceId();
      final result = await PhotoService.uploadPhoto(
        spotId: widget.spotId,
        imageFile: File(picked.path),
        deviceId: deviceId,
        spotLat: widget.spotLat,
        spotLng: widget.spotLng,
        photoLat: gps?.$1,
        photoLng: gps?.$2,
      );
      debugPrint('📸 uploadPhoto returned — result=$result');

      if (result == 'limit_reached') {
        messenger.showSnackBar(_infoSnackBar(l10n.maxPhotosReached));
      } else {
        await _loadPhotos();
        debugPrint('📸 loadPhotos done — approved=${_approved.length} pending=${_pending.length}');
      }
    } catch (e, st) {
      debugPrint('📸 ERROR: $e\n$st');
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: GlutTheme.coal,
            title: const Text('Upload error',
                style: TextStyle(color: Colors.white, fontSize: 15)),
            content: SingleChildScrollView(
              child: Text('$e',
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 11)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK',
                    style: TextStyle(color: GlutTheme.ember)),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _viewPhoto(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _PhotoViewer(
          photos: _approved,
          initialIndex: index,
          spotId: widget.spotId,
          getDeviceId: DeviceIdService.getDeviceId,
        ),
      ),
    );
  }

  // ── Tile builders ──────────────────────────────────────────────────────────

  Widget _uploadingTile() => Container(
        width: 120,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: GlutTheme.coal,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child:
              CircularProgressIndicator(color: GlutTheme.ember, strokeWidth: 2),
        ),
      );

  Widget _pendingTile(String url) => Container(
        width: 120,
        margin: const EdgeInsets.only(right: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, _) => Container(
                  color: GlutTheme.coal,
                  child: const Center(
                    child: Icon(Icons.image_outlined,
                        color: Colors.white24, size: 28),
                  ),
                ),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.35),
                ),
              ),
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.hourglass_empty_rounded,
                        color: GlutTheme.ember, size: 22),
                    SizedBox(height: 5),
                    Text(
                      'In review',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 9,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final totalCount = _approved.length + _pending.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.sectionPhotos.toUpperCase(),
              style: const TextStyle(
                  color: Colors.white54, fontSize: 10, letterSpacing: 1),
            ),
            if (totalCount < 3 && !_uploading)
              GestureDetector(
                onTap: _showAddPhotoSheet,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: GlutTheme.ember.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: GlutTheme.ember.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add_a_photo_outlined,
                          size: 12, color: GlutTheme.ember),
                      const SizedBox(width: 4),
                      Text(l10n.addPhoto,
                          style: const TextStyle(
                              color: GlutTheme.ember, fontSize: 11)),
                    ],
                  ),
                ),
              )
            else
              Text(
                '$totalCount/3',
                style:
                    const TextStyle(color: Colors.white38, fontSize: 11),
              ),
          ],
        ),
        const SizedBox(height: 10),

        if (_loading)
          const SizedBox(
            height: 100,
            child: Center(
              child: CircularProgressIndicator(
                  color: GlutTheme.ember, strokeWidth: 2),
            ),
          )
        else if (totalCount == 0 && !_uploading)
          GestureDetector(
            onTap: _showAddPhotoSheet,
            child: Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: GlutTheme.coal,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_a_photo_outlined,
                      color: Colors.white24, size: 28),
                  const SizedBox(height: 8),
                  Text(l10n.beFirstToAddPhoto,
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 12)),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount:
                  (_uploading ? 1 : 0) + _pending.length + _approved.length,
              itemBuilder: (_, i) {
                if (_uploading && i == 0) return _uploadingTile();
                final base = _uploading ? 1 : 0;
                final pIdx = i - base;
                if (pIdx < _pending.length) return _pendingTile(_pending[pIdx]);
                final aIdx = i - base - _pending.length;
                return GestureDetector(
                  onTap: () => _viewPhoto(aIdx),
                  child: Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: NetworkImage(_approved[aIdx]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

// ─── Photo viewer ──────────────────────────────────────────────────────────────

class _PhotoViewer extends StatefulWidget {
  final List<String> photos;
  final int initialIndex;
  final String spotId;
  final Future<String> Function() getDeviceId;

  const _PhotoViewer({
    required this.photos,
    required this.initialIndex,
    required this.spotId,
    required this.getDeviceId,
  });

  @override
  State<_PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<_PhotoViewer> {
  late int _current;
  bool _reporting = false;
  final _reported = <String>{};

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
  }

  Future<void> _report() async {
    final l10n = AppLocalizations.of(context)!;
    final photoUrl = widget.photos[_current];
    if (_reported.contains(photoUrl)) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: GlutTheme.coal,
        title: Text(l10n.reportPhoto,
            style: const TextStyle(color: GlutTheme.linen, fontSize: 16)),
        content: Text(l10n.reportPhotoContent,
            style: const TextStyle(color: Colors.white54, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel,
                style: const TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                Text(l10n.report, style: const TextStyle(color: GlutTheme.ember)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _reporting = true);
    final deviceId = await widget.getDeviceId();
    final ok = await PhotoService.reportPhoto(
      spotId: widget.spotId,
      photoUrl: photoUrl,
      deviceId: deviceId,
    );
    if (mounted) {
      setState(() {
        _reporting = false;
        if (ok) _reported.add(photoUrl);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok ? l10n.photoReportedSuccess : l10n.photoReportedError,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          backgroundColor: GlutTheme.coal,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = widget.photos[_current];
    final alreadyReported = _reported.contains(photoUrl);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: PageController(initialPage: widget.initialIndex),
            onPageChanged: (i) => setState(() => _current = i),
            itemCount: widget.photos.length,
            itemBuilder: (_, i) => InteractiveViewer(
              child: Image.network(widget.photos[i], fit: BoxFit.contain),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 16),
                    ),
                  ),
                  Text(
                    '${_current + 1} / ${widget.photos.length}',
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  GestureDetector(
                    onTap: alreadyReported || _reporting ? null : _report,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: _reporting
                          ? const Center(
                              child: SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    color: Colors.white54),
                              ),
                            )
                          : Icon(
                              Icons.flag_outlined,
                              size: 16,
                              color: alreadyReported
                                  ? GlutTheme.ember
                                  : Colors.white54,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
