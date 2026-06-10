import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../l10n/app_localizations.dart';
import '../../services/photo_service.dart';
import '../../theme.dart';

class SpotPhotos extends StatefulWidget {
  final String spotId;
  const SpotPhotos({super.key, required this.spotId});

  @override
  State<SpotPhotos> createState() => _SpotPhotosState();
}

class _SpotPhotosState extends State<SpotPhotos> {
  List<String> _photos = [];
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
    final photos = await PhotoService.getPhotosForSpot(widget.spotId);
    if (mounted) {
      setState(() {
        _photos = photos;
        _loading = false;
      });
    }
  }

  Future<String> _getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('device_id')) {
      await prefs.setString('device_id', const Uuid().v4());
    }
    return prefs.getString('device_id')!;
  }

  SnackBar _errorSnackBar(String message) => SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.orange, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.white, fontSize: 13))),
          ],
        ),
        backgroundColor: GlutTheme.coal,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      );

  SnackBar _infoSnackBar(String message) => SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
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
    showModalBottomSheet(
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
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(
                Icons.camera_alt_outlined,
                color: GlutTheme.ember,
              ),
              title: Text(
                l10n.takePhoto,
                style: const TextStyle(color: GlutTheme.linen),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: GlutTheme.ember,
              ),
              title: Text(
                l10n.chooseFromLibrary,
                style: const TextStyle(color: GlutTheme.linen),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1440,
      imageQuality: 90,
    );

    if (picked == null) return;

    if (_photos.length >= 3) {
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.maxPhotosReached,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.info_outline, color: Colors.orange, size: 18),
            ],
          ),
          backgroundColor: GlutTheme.coal,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        ),
      );
      return;
    }

    setState(() => _uploading = true);

    try {
      final deviceId = await _getDeviceId();
      final result = await PhotoService.uploadPhoto(
        spotId: widget.spotId,
        imageFile: File(picked.path),
        deviceId: deviceId,
      );

      await _loadPhotos();

      if (result == null) {
        messenger.showSnackBar(_errorSnackBar(l10n.photoUploadError));
      } else if (result == 'limit_reached') {
        messenger.showSnackBar(_infoSnackBar(l10n.maxPhotosReached));
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
          photos: _photos,
          initialIndex: index,
          spotId: widget.spotId,
          getDeviceId: _getDeviceId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.sectionPhotos.toUpperCase(),
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
            if (_photos.length < 3)
              GestureDetector(
                onTap: _showAddPhotoSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: GlutTheme.ember.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: GlutTheme.ember.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.add_a_photo_outlined,
                        size: 12,
                        color: GlutTheme.ember,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.addPhoto,
                        style: const TextStyle(color: GlutTheme.ember, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              )
            else
              const Text(
                '3/3',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
          ],
        ),
        const SizedBox(height: 10),

        // Photo content
        if (_loading)
          const SizedBox(
            height: 100,
            child: Center(
              child: CircularProgressIndicator(
                color: GlutTheme.ember,
                strokeWidth: 2,
              ),
            ),
          )
        else if (_photos.isEmpty && !_uploading)
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
                  const Icon(
                    Icons.add_a_photo_outlined,
                    color: Colors.white24,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.beFirstToAddPhoto,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _photos.length + (_uploading ? 1 : 0),
              itemBuilder: (_, i) {
                // Uploading placeholder
                if (_uploading && i == 0) {
                  return Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: GlutTheme.coal,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: GlutTheme.ember,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                }

                final photoIndex = _uploading ? i - 1 : i;
                return GestureDetector(
                  onTap: () => _viewPhoto(photoIndex),
                  child: Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: NetworkImage(_photos[photoIndex]),
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
        title: Text(
          l10n.reportPhoto,
          style: const TextStyle(color: GlutTheme.linen, fontSize: 16),
        ),
        content: Text(
          l10n.reportPhotoContent,
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel, style: const TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.report, style: const TextStyle(color: GlutTheme.ember)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                      child: const Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                  ),
                  Text(
                    '${_current + 1} / ${widget.photos.length}',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
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
                                  color: Colors.white54,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.flag_outlined,
                              size: 16,
                              color: alreadyReported ? GlutTheme.ember : Colors.white54,
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
