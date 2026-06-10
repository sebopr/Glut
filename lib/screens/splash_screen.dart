import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/spots_provider.dart';
import '../theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  final Widget destination;

  const SplashScreen({super.key, required this.destination});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  // Loops continuously — drives all fire / ember animation
  late final AnimationController _fireCtrl;
  // Runs once — drives fire fade-in and title fade-in
  late final AnimationController _introCtrl;
  late final List<_Ember> _embers;
  late final Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();

    _fireCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _introCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _embers = List.generate(36, (_) => _Ember.random());

    _textOpacity = CurvedAnimation(
      parent: _introCtrl,
      curve: const Interval(0.18, 0.65, curve: Curves.easeOut),
    );

    // Kick off GPS in the background so it's cached by the time the map mounts.
    // We intentionally do NOT await this — a slow GPS fix or permission dialog
    // would otherwise hang the splash indefinitely.
    ref.read(locationProvider.future).then<void>((_) {}).catchError((_) {});

    Future.delayed(const Duration(milliseconds: 1500)).then((_) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, _, _) => widget.destination,
          transitionDuration: const Duration(milliseconds: 350),
          transitionsBuilder: (_, anim, _, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    });
  }

  @override
  void dispose() {
    _fireCtrl.dispose();
    _introCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: GlutTheme.ash,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([_fireCtrl, _introCtrl]),
            builder: (_, _) => CustomPaint(
              size: size,
              painter: _CampfirePainter(
                _embers,
                _fireCtrl.value,
                _introCtrl.value,
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0, -0.20),
            child: FadeTransition(
              opacity: _textOpacity,
              child: const Text(
                'Glut',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  color: GlutTheme.linen,
                  fontSize: 54,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Ember particle (designed for continuous looping) ─────────────────────────

class _Ember {
  final double xOffset;  // horizontal from center as fraction of width
  final double phase;    // 0–1 stagger so embers don't all sync
  final double size;     // core radius px
  final double speed;    // screen-height fraction covered per fire cycle
  final double driftAmp; // horizontal wobble amplitude (fraction of width)
  final double driftFreq;
  final Color color;

  const _Ember({
    required this.xOffset,
    required this.phase,
    required this.size,
    required this.speed,
    required this.driftAmp,
    required this.driftFreq,
    required this.color,
  });

  static final _rng = Random();

  static const _palette = [
    Color(0xFFFF8C2A),
    Color(0xFFE8621A),
    Color(0xFFFF4500),
    Color(0xFFFFB347),
    Color(0xFFFFD040),
    Color(0xFFCC3300),
    Color(0xFFFF6010),
  ];

  factory _Ember.random() {
    final r = _rng;
    return _Ember(
      xOffset: (r.nextDouble() - 0.5) * 0.16,
      phase: r.nextDouble(),
      size: 1.0 + r.nextDouble() * 2.2,
      speed: 0.22 + r.nextDouble() * 0.28,
      driftAmp: 0.005 + r.nextDouble() * 0.018,
      driftFreq: 1.4 + r.nextDouble() * 2.0,
      color: _palette[r.nextInt(_palette.length)],
    );
  }
}

// ─── Campfire painter ─────────────────────────────────────────────────────────

class _CampfirePainter extends CustomPainter {
  final List<_Ember> embers;
  final double t;     // fire loop value 0→1 (repeating)
  final double intro; // one-shot intro 0→1

  const _CampfirePainter(this.embers, this.t, this.intro);

  static const _fireYFrac = 0.72;

  @override
  void paint(Canvas canvas, Size size) {
    final fireY = size.height * _fireYFrac;
    final cx = size.width * 0.5;
    final fadeIn = (intro * 6.0).clamp(0.0, 1.0);

    _drawGroundGlow(canvas, size, cx, fireY, fadeIn);
    _drawLogs(canvas, cx, fireY, fadeIn);
    _drawCoals(canvas, cx, fireY, fadeIn);
    _drawFlames(canvas, cx, fireY, size, fadeIn);
    _drawEmbers(canvas, size, cx, fireY, fadeIn);
    _drawVignette(canvas, size);
  }

  void _drawGroundGlow(Canvas canvas, Size size, double cx, double fireY, double fadeIn) {
    final rect = Rect.fromCenter(
      center: Offset(cx, fireY + 20),
      width: size.width * 0.70,
      height: 80,
    );
    canvas.drawOval(
      rect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFE8621A).withValues(alpha: 0.22 * fadeIn),
            const Color(0xFFCC3300).withValues(alpha: 0.07 * fadeIn),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(rect),
    );
  }

  void _drawLogs(Canvas canvas, double cx, double fireY, double fadeIn) {
    final body  = Paint()..color = const Color(0xFF2A1508).withValues(alpha: fadeIn);
    final grain = Paint()..color = const Color(0xFF160B04).withValues(alpha: fadeIn * 0.75);

    for (final angle in [pi / 6.5, -pi / 6.5]) {
      canvas.save();
      canvas.translate(cx, fireY + 5);
      canvas.rotate(angle);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: 84, height: 12),
          const Radius.circular(6),
        ),
        body,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: const Offset(0, -1.5), width: 80, height: 4),
          const Radius.circular(2),
        ),
        grain,
      );
      canvas.restore();
    }
  }

  void _drawCoals(Canvas canvas, double cx, double fireY, double fadeIn) {
    final flicker = 0.72 + 0.28 * sin(t * 8.5 * pi * 2 + 0.6);
    final rect = Rect.fromCenter(center: Offset(cx, fireY - 1), width: 44, height: 16);
    canvas.drawOval(
      rect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFF5500).withValues(alpha: 0.95 * fadeIn * flicker),
            const Color(0xFFBB2000).withValues(alpha: 0.45 * fadeIn),
            Colors.transparent,
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(rect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
  }

  void _drawFlames(Canvas canvas, double cx, double fireY, Size size, double fadeIn) {
    final h = size.height;

    // Four independent flicker signals at different frequencies
    final f1 = sin(t * 3.2 * pi * 2);
    final f2 = sin(t * 4.7 * pi * 2 + 1.1);
    final f3 = sin(t * 6.3 * pi * 2 + 2.0);
    final f4 = sin(t * 8.1 * pi * 2 + 0.5);
    final lean = sin(t * 1.6 * pi * 2) * 6;

    final layers = [
      _Flame(cx + lean * 0.5,       fireY, 70 + f1 * 7,  h * (0.195 + f1 * 0.022), const Color(0xFF6B0F00), 0.45, 20.0),
      _Flame(cx - 16 + lean * 0.35, fireY, 50 + f2 * 5,  h * (0.168 + f2 * 0.018), const Color(0xFFAA2000), 0.65, 11.0),
      _Flame(cx + 16 + lean * 0.35, fireY, 48 + f1 * 4,  h * (0.162 + f1 * 0.016), const Color(0xFFAA2000), 0.65, 11.0),
      _Flame(cx - 8  + lean * 0.55, fireY, 38 + f3 * 4,  h * (0.142 + f3 * 0.014), const Color(0xFFE04010), 0.80, 8.0),
      _Flame(cx + 8  + lean * 0.55, fireY, 36 + f2 * 3,  h * (0.136 + f2 * 0.013), const Color(0xFFE04010), 0.80, 8.0),
      _Flame(cx      + lean * 0.80, fireY, 26 + f4 * 3,  h * (0.112 + f4 * 0.012), const Color(0xFFFF7820), 0.92, 5.5),
      _Flame(cx      + lean,        fireY, 15 + f4 * 2,  h * (0.082 + f4 * 0.009), const Color(0xFFFFCC30), 1.00, 3.5),
      _Flame(cx      + lean * 1.1,  fireY, 7  + f4,      h * (0.052 + f4 * 0.005), const Color(0xFFFFF4C0), 0.80, 2.0),
    ];

    for (final fl in layers) {
      canvas.drawPath(
        _flamePath(fl.cx, fl.baseY, fl.w, fl.h),
        Paint()
          ..color = fl.color.withValues(alpha: fl.opacity * fadeIn)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, fl.blur),
      );
    }
  }

  Path _flamePath(double cx, double baseY, double w, double h) {
    final half = w / 2;
    return Path()
      ..moveTo(cx - half, baseY)
      ..cubicTo(cx - half * 1.18, baseY - h * 0.28, cx - half * 0.32, baseY - h * 0.74, cx, baseY - h)
      ..cubicTo(cx + half * 0.32, baseY - h * 0.74, cx + half * 1.18, baseY - h * 0.28, cx + half, baseY)
      ..close();
  }

  void _drawEmbers(Canvas canvas, Size size, double cx, double fireY, double fadeIn) {
    final glow  = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    final core  = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
    final white = Paint();

    for (final e in embers) {
      // Each ember uses its own phase offset so they're staggered across the loop
      final localT = (t + e.phase) % 1.0;

      final opacity = localT < 0.20 ? localT / 0.20
          : localT < 0.70 ? 1.0
          : 1.0 - (localT - 0.70) / 0.30;
      final alpha = (opacity * fadeIn).clamp(0.0, 1.0);
      if (alpha < 0.01) continue;

      final ex = cx + e.xOffset * size.width
          + e.driftAmp * size.width * sin(localT * e.driftFreq * pi * 2);
      final ey = fireY - e.speed * size.height * localT;

      glow.color  = e.color.withValues(alpha: alpha * 0.30);
      canvas.drawCircle(Offset(ex, ey), e.size * 2.6, glow);

      core.color  = e.color.withValues(alpha: alpha);
      canvas.drawCircle(Offset(ex, ey), e.size, core);

      white.color = Colors.white.withValues(alpha: alpha * 0.60);
      canvas.drawCircle(Offset(ex, ey), e.size * 0.36, white);
    }
  }

  void _drawVignette(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, 0.50),
          radius: 0.88,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.50)],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(_CampfirePainter old) => old.t != t || old.intro != intro;
}

// ─── Flame layer descriptor ───────────────────────────────────────────────────

class _Flame {
  final double cx, baseY, w, h, opacity, blur;
  final Color color;
  const _Flame(this.cx, this.baseY, this.w, this.h, this.color, this.opacity, this.blur);
}
