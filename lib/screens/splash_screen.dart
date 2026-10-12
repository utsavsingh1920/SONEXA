import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import '../main.dart';

class SplashScreen extends StatefulWidget {

  const SplashScreen({super.key});

  @override

  State<SplashScreen> createState() => _SplashScreenState();

}

class _SplashScreenState extends State<SplashScreen>

    with SingleTickerProviderStateMixin {

  late final AnimationController _controller;

  Timer? _timer;

  @override

  void initState() {

    super.initState();

    _controller = AnimationController(

      vsync: this,

      duration: const Duration(milliseconds: 950),

    )..forward();

    _timer = Timer(const Duration(milliseconds: 1500), _openApp);

  }

  void _openApp() {

    if (!mounted) return;

    Navigator.of(context).pushReplacement(

      PageRouteBuilder<void>(

        pageBuilder: (_, animation, secondaryAnimation) => const AuthGate(),

        transitionDuration: const Duration(milliseconds: 350),

        transitionsBuilder: (_, animation, secondaryAnimation, child) =>

            FadeTransition(opacity: animation, child: child),

      ),

    );

  }

  @override

  void dispose() {

    _timer?.cancel();

    _controller.dispose();

    super.dispose();

  }

  @override

  Widget build(BuildContext context) {

    return AnnotatedRegion<SystemUiOverlayStyle>(

      value: SystemUiOverlayStyle.light.copyWith(

        statusBarColor: Colors.transparent,

        statusBarIconBrightness: Brightness.light,

        systemNavigationBarColor: const Color(0xFF090414),

        systemNavigationBarIconBrightness: Brightness.light,

      ),

      child: Scaffold(

        backgroundColor: const Color(0xFF090414),

        body: LayoutBuilder(

          builder: (context, constraints) {

            // Reference design canvas, tuned to the second screenshot (393 × 880).

            const dw = 393.0;

            const dh = 880.0;

            final width = constraints.maxWidth;

            final height = constraints.maxHeight;

            final sx = width / dw;

            final sy = height / dh;

            // Scale all fixed design coordinates proportionally to available screen size.

            // Fill the whole viewport. X and Y are scaled independently so

            // nothing is letterboxed on taller phones.

            return ClipRect(

              child: SizedBox.expand(

                child: Stack(

                  children: [

                    const Positioned.fill(

                      child: DecoratedBox(

                        decoration: BoxDecoration(

                          gradient: RadialGradient(

                            center: Alignment(0, -0.22),

                            radius: 1.05,

                            colors: [

                              Color(0xFF230C3C),

                              Color(0xFF10071E),

                              Color(0xFF070310),

                            ],

                            stops: [0, .53, 1],

                          ),

                        ),

                      ),

                    ),

                    Transform(

                      alignment: Alignment.topLeft,

                      transform: Matrix4.diagonal3Values(sx, sy, 1),

                      child: SizedBox(

                        width: dw,

                        height: dh,

                        child: Stack(

                          clipBehavior: Clip.none,

                          children: [

                            const Positioned.fill(

                              child: CustomPaint(painter: _BackgroundPainter()),

                            ),

                            const Positioned(

                              left: 29,

                              top: 65,

                              child: Text(

                                'M O R E\nT H A N\nM U S I C',

                                style: TextStyle(

                                  color: Color(0xFFE8D4F7),

                                  fontSize: 12,

                                  height: 1.78,

                                  letterSpacing: 1.05,

                                ),

                              ),

                            ),

                            const Positioned(

                              left: 29,

                              top: 132,

                              child: _GlowLine(width: 48),

                            ),

                            const Positioned(

                              left: 329,

                              top: 183,

                              child: _MusicNote(size: 35, doubleNote: false),

                            ),

                            const Positioned(

                              left: 35,

                              top: 350,

                              child: _MusicNote(size: 40, doubleNote: true),

                            ),

                            const Positioned(

                              left: 343,

                              top: 606,

                              child: _MusicNote(size: 42, doubleNote: true),

                            ),

                            Positioned(

                              left: 0,

                              top: 211,

                              width: dw,

                              child: FadeTransition(

                                opacity: CurvedAnimation(

                                  parent: _controller,

                                  curve: Curves.easeOut,

                                ),

                                child: Column(

                                  mainAxisSize: MainAxisSize.min,

                                  children: [

                                    Container(

                                      width: 156,

                                      height: 156,

                                      alignment: Alignment.center,

                                      decoration: BoxDecoration(

                                        shape: BoxShape.circle,

                                        boxShadow: [

                                          BoxShadow(

                                            color: const Color(0xFF932BFF)

                                                .withValues(alpha: .20),

                                            blurRadius: 42,

                                            spreadRadius: 3,

                                          ),

                                        ],

                                      ),

                                      child: Image.asset(

                                        'assets/images/sonexa_logo.png',

                                        width: 150,

                                        height: 150,

                                        fit: BoxFit.contain,

                                        errorBuilder: (_, error, stackTrace) =>

                                            Container(

                                              width: 148,

                                              height: 148,

                                              decoration: BoxDecoration(

                                                borderRadius:

                                                    BorderRadius.circular(34),

                                                border: Border.all(

                                                  color: const Color(

                                                    0xFFD65DFF,

                                                  ),

                                                  width: 2,

                                                ),

                                                gradient: const LinearGradient(

                                                  begin: Alignment.topLeft,

                                                  end: Alignment.bottomRight,

                                                  colors: [

                                                    Color(0xFFCB60FF),

                                                    Color(0xFF6E18DB),

                                                    Color(0xFF16062E),

                                                  ],

                                                ),

                                              ),

                                              child: const Icon(

                                                Icons.graphic_eq_rounded,

                                                size: 83,

                                                color: Colors.white,

                                              ),

                                            ),

                                      ),

                                    ),

                                    const SizedBox(height: 14),

                                    const Text.rich(

                                      TextSpan(

                                        children: [

                                          TextSpan(

                                            text: 'SONEX',

                                            style: TextStyle(

                                              color: Colors.white,

                                            ),

                                          ),

                                          TextSpan(

                                            text: 'A',

                                            style: TextStyle(

                                              color: Color(0xFFB85BFF),

                                            ),

                                          ),

                                        ],

                                      ),

                                      textAlign: TextAlign.center,

                                      style: TextStyle(

                                        fontSize: 46,

                                        fontWeight: FontWeight.w800,

                                        height: 1,

                                        letterSpacing: 1.0,

                                      ),

                                    ),

                                    const SizedBox(height: 16),

                                    const Text(

                                      'F e e l  E v e r y  B e a t',

                                      style: TextStyle(

                                        fontSize: 11.7,

                                        color: Color(0xFFF0DFFB),

                                      ),

                                    ),

                                    const SizedBox(height: 18),

                                    const _GlowLine(width: 99, height: 2.5),

                                  ],

                                ),

                              ),

                            ),

                            // Four equally spaced, screen-centered feature icons.

                            // Explicit coordinates avoid intrinsic-width shifts.

                            const Positioned(

                              left: 0,

                              top: 493,

                              width: dw,

                              child: SizedBox(

                                height: 83,

                                child: Stack(

                                  children: [

                                    Positioned(

                                      left: 28,

                                      width: 68,

                                      child: _Feature(

                                        icon: Icons.play_arrow_rounded,

                                        label: 'PLAY',

                                      ),

                                    ),

                                    Positioned(

                                      left: 118,

                                      width: 68,

                                      child: _Feature(

                                        icon: Icons.search_rounded,

                                        label: 'DISCOVER',

                                      ),

                                    ),

                                    Positioned(

                                      left: 208,

                                      width: 68,

                                      child: _Feature(

                                        icon: Icons.queue_music_rounded,

                                        label: 'ORGANIZE',

                                      ),

                                    ),

                                    Positioned(

                                      left: 298,

                                      width: 68,

                                      child: _Feature(

                                        icon: Icons.favorite_rounded,

                                        label: 'ENJOY',

                                      ),

                                    ),

                                    Positioned(

                                      left: 106,

                                      top: 2,

                                      child: _FeatureDivider(),

                                    ),

                                    Positioned(

                                      left: 196,

                                      top: 2,

                                      child: _FeatureDivider(),

                                    ),

                                    Positioned(

                                      left: 286,

                                      top: 2,

                                      child: _FeatureDivider(),

                                    ),

                                  ],

                                ),

                              ),

                            ),

                            const Positioned(

                              left: 0,

                              top: 627,

                              width: dw,

                              child: Column(

                                children: [

                                  Text.rich(

                                    TextSpan(

                                      children: [

                                        TextSpan(text: 'A Better You\n'),

                                        TextSpan(

                                          text: 'Through ',

                                          style: TextStyle(

                                            fontStyle: FontStyle.italic,

                                          ),

                                        ),

                                        TextSpan(

                                          text: 'Music',

                                          style: TextStyle(

                                            fontStyle: FontStyle.italic,

                                            color: Color(0xFFCB6AFF),

                                          ),

                                        ),

                                      ],

                                    ),

                                    textAlign: TextAlign.center,

                                    style: TextStyle(

                                      color: Colors.white,

                                      fontSize: 18,

                                      fontWeight: FontWeight.w700,

                                      height: 1.18,

                                    ),

                                  ),

                                  SizedBox(height: 13),

                                  _GlowLine(width: 69, height: 2),

                                ],

                              ),

                            ),

                          ],

                        ),

                      ),

                    ),

                  ],

                ),

              ),

            );

          },

        ),

      ),

    );

  }

}

class _GlowLine extends StatelessWidget {

  const _GlowLine({required this.width, this.height = 2.5});

  final double width;

  final double height;

  @override

  Widget build(BuildContext context) => Container(

    width: width,

    height: height,

    decoration: BoxDecoration(

      gradient: const LinearGradient(

        colors: [

          Colors.transparent,

          Color(0xFF8B24FF),

          Color(0xFFECA6FF),

          Color(0xFF8B24FF),

          Colors.transparent,

        ],

      ),

      boxShadow: [

        BoxShadow(

          color: const Color(0xFFB449FF).withValues(alpha: .8),

          blurRadius: 11,

        ),

      ],

    ),

  );

}

class _MusicNote extends StatelessWidget {

  const _MusicNote({required this.size, required this.doubleNote});

  final double size;

  final bool doubleNote;

  @override

  Widget build(BuildContext context) => Icon(

    doubleNote ? Icons.music_note_rounded : Icons.music_note_rounded,

    size: size,

    color: const Color(0xFFAB4BFF),

    shadows: [

      Shadow(

        color: const Color(0xFFAB4BFF).withValues(alpha: .8),

        blurRadius: 13,

      ),

    ],

  );

}

class _Feature extends StatelessWidget {

  const _Feature({required this.icon, required this.label});

  final IconData icon;

  final String label;

  @override

  Widget build(BuildContext context) => SizedBox(

    width: double.infinity,

    child: Column(

      mainAxisSize: MainAxisSize.min,

      children: [

        Container(

          width: 49,

          height: 49,

          decoration: BoxDecoration(

            shape: BoxShape.circle,

            gradient: const LinearGradient(

              begin: Alignment.topLeft,

              end: Alignment.bottomRight,

              colors: [Color(0xFF381454), Color(0xFF1B0B32), Color(0xFF0C0518)],

            ),

            border: Border.all(color: const Color(0xFF573078), width: .8),

          ),

          child: Icon(icon, color: const Color(0xFFDDA0FF), size: 27),

        ),

        const SizedBox(height: 9),

        Text(

          label,

          maxLines: 1,

          style: const TextStyle(

            fontSize: 9.6,

            fontWeight: FontWeight.w600,

            letterSpacing: .2,

            color: Color(0xFFE8D6F9),

          ),

        ),

      ],

    ),

  );

}

class _FeatureDivider extends StatelessWidget {

  const _FeatureDivider();

  @override

  Widget build(BuildContext context) => Container(

    width: 1,

    height: 53,

    margin: const EdgeInsets.only(bottom: 13),

    color: const Color(0xFF74428F),

  );

}

class _BackgroundPainter extends CustomPainter {

  const _BackgroundPainter();

  @override

  void paint(Canvas canvas, Size size) {

    const w = 393.0;

    const h = 880.0;

    // Upper-right circular glow.

    const topCenter = Offset(407, -52);

    const topRadius = 167.0;

    final topRect = Rect.fromCircle(center: topCenter, radius: topRadius);

    canvas.drawCircle(

      topCenter,

      topRadius,

      Paint()

        ..shader = const RadialGradient(

          center: Alignment(-.6, .7),

          radius: 1.3,

          colors: [Color(0xFF7523D9), Color(0xFF46138C), Color(0xFF19072E)],

        ).createShader(topRect),

    );

    canvas.drawCircle(

      topCenter,

      topRadius,

      Paint()

        ..color = const Color(0xFFAF5CFF)

        ..style = PaintingStyle.stroke

        ..strokeWidth = 1.3,

    );

    const dots = <Offset>[

      Offset(300, 149),

      Offset(353, 192),

      Offset(29, 247),

      Offset(63, 282),

      Offset(40, 465),

      Offset(354, 440),

      Offset(336, 475),

      Offset(323, 631),

      Offset(30, 843),

      Offset(69, 836),

    ];

    for (var i = 0; i < dots.length; i++) {

      final r = i % 3 == 0 ? 3.7 : 2.1;

      canvas.drawCircle(

        dots[i],

        r + 3,

        Paint()

          ..color = const Color(0xFF9C43FF).withValues(alpha: .30)

          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),

      );

      canvas.drawCircle(dots[i], r, Paint()..color = const Color(0xFF9542F4));

    }

    // The large left orb must stay mostly offscreen, like the reference.

    const orbCenter = Offset(-114, 890);

    const orbRadius = 246.0;

    final orbRect = Rect.fromCircle(center: orbCenter, radius: orbRadius);

    canvas.drawCircle(

      orbCenter,

      orbRadius,

      Paint()

        ..shader = const RadialGradient(

          center: Alignment(.65, -.7),

          radius: 1.3,

          colors: [Color(0xFF8426EA), Color(0xFF5115A6), Color(0xFF1C083B)],

        ).createShader(orbRect),

    );

    canvas.drawCircle(

      orbCenter,

      orbRadius,

      Paint()

        ..color = const Color(0xFFAF60FF)

        ..style = PaintingStyle.stroke

        ..strokeWidth = 1.3,

    );

    // Reference: wave crests at edges and a smooth deep valley at center.

    Path crest(double dy) => Path()

      ..moveTo(-12, 707 + dy)

      ..cubicTo(64, 719 + dy, 134, 779 + dy, 198, 772 + dy)

      ..cubicTo(263, 768 + dy, 328, 688 + dy, 407, 715 + dy);

    // Dark translucent body below the crest.

    final base = crest(18)

      ..lineTo(407, h + 5)

      ..lineTo(-12, h + 5)

      ..close();

    canvas.drawPath(

      base,

      Paint()

        ..shader = const LinearGradient(

          begin: Alignment.topCenter,

          end: Alignment.bottomCenter,

          colors: [Color(0xBB3B0D86), Color(0x99200A50), Color(0xFF0B041A)],

        ).createShader(const Rect.fromLTWH(0, 704, w, 176)),

    );

    // Semi-transparent flowing silk that crosses the orb.

    final silk = Path()

      ..moveTo(-12, 759)

      ..cubicTo(74, 689, 137, 800, 202, 800)

      ..cubicTo(285, 799, 340, 704, 407, 746)

      ..lineTo(407, 811)

      ..cubicTo(327, 771, 276, 847, 199, 838)

      ..cubicTo(111, 832, 60, 743, -12, 820)

      ..close();

    canvas.drawPath(

      silk,

      Paint()

        ..shader = const LinearGradient(

          begin: Alignment.topCenter,

          end: Alignment.bottomCenter,

          colors: [Color(0xBB8E35F9), Color(0x884E18AE), Color(0x00250A55)],

        ).createShader(const Rect.fromLTWH(0, 694, w, 181)),

    );

    // Many fine, transparent parallel threads instead of thick stripes.

    for (int i = 19; i >= 0; i--) {

      canvas.drawPath(

        crest(i * 2.0),

        Paint()

          ..color = const Color(0xFFC16AFF).withValues(alpha: .16 - i * .005)

          ..style = PaintingStyle.stroke

          ..strokeWidth = .65,

      );

    }

    canvas.drawPath(

      crest(0),

      Paint()

        ..color = const Color(0xFFB54AFF).withValues(alpha: .75)

        ..style = PaintingStyle.stroke

        ..strokeWidth = 11

        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),

    );

    canvas.drawPath(

      crest(0),

      Paint()

        ..shader = const LinearGradient(

          colors: [Color(0xFFB04AFF), Color(0xFFE9AAFF), Color(0xFF9231FF)],

        ).createShader(const Rect.fromLTWH(0, 694, w, 146))

        ..style = PaintingStyle.stroke

        ..strokeWidth = 2.2

        ..strokeCap = StrokeCap.round,

    );

    final lowerFold = Path()

      ..moveTo(-12, 811)

      ..cubicTo(74, 763, 136, 847, 200, 844)

      ..cubicTo(279, 844, 344, 786, 407, 813)

      ..lineTo(407, h + 5)

      ..lineTo(-12, h + 5)

      ..close();

    canvas.drawPath(

      lowerFold,

      Paint()

        ..shader = const LinearGradient(

          begin: Alignment.topCenter,

          end: Alignment.bottomCenter,

          colors: [Color(0x66451A98), Color(0x00100625)],

        ).createShader(const Rect.fromLTWH(0, 774, w, 106)),

    );

  }

  @override

  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) => false;

}
