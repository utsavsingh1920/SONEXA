import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.94,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();

    // Final splash duration = 1.5 seconds
    Timer(
      const Duration(milliseconds: 1500),
      _openApp,
    );
  }

  void _openApp() {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, animation, _) => const AuthGate(),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05050B),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double w = constraints.maxWidth;
          final double h = constraints.maxHeight;

          return Stack(
            fit: StackFit.expand,
            children: [
              // ==================================================
              // BACKGROUND
              // ==================================================

              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.0, -0.02),
                    radius: 1.0,
                    colors: [
                      Color(0xFF140629),
                      Color(0xFF090611),
                      Color(0xFF05050B),
                    ],
                    stops: [0.0, 0.50, 1.0],
                  ),
                ),
              ),

              // ==================================================
              // BACKGROUND CURVES
              // ==================================================

              const CustomPaint(
                painter: BackgroundCurvePainter(),
              ),

              // ==================================================
              // SUBTLE PARTICLES
              // ==================================================

              const CustomPaint(
                painter: ParticlePainter(),
              ),

              // ==================================================
              // TOP LEFT - MORE THAN MUSIC
              // ==================================================

              Positioned(
                left: w * 0.08,
                top: h * 0.075,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'M O R E\nT H A N\nM U S I C',
                      style: TextStyle(
                        color: const Color(0xFFE2CFFF),
                        fontSize: w * 0.030,
                        height: 1.75,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    SizedBox(height: h * 0.012),

                    Container(
                      width: w * 0.115,
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFC45CFF),
                            Color(0xFF7C3AED),
                            Colors.transparent,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9B4DFF)
                                .withValues(alpha: 0.55),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ==================================================
              // MAIN LOGO / BRAND
              // ==================================================

              Positioned(
                top: h * 0.285,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      children: [
                        // ==========================================
                        // LOGO
                        // ==========================================

                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: w * 0.47,
                              height: w * 0.47,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF7C3AED)
                                        .withValues(alpha: 0.26),
                                    blurRadius: 70,
                                    spreadRadius: 10,
                                  ),
                                  BoxShadow(
                                    color: const Color(0xFFB84DFF)
                                        .withValues(alpha: 0.13),
                                    blurRadius: 35,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),

                            Image.asset(
                              'assets/images/sonexa_logo.png',
                              width: w * 0.37,
                              height: w * 0.37,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),

                        SizedBox(height: h * 0.023),

                        // ==========================================
                        // SONEXA
                        // ==========================================

                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'SONEXA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: w * 0.105,
                              fontWeight: FontWeight.w700,
                              letterSpacing: w * 0.013,
                              height: 1,
                            ),
                          ),
                        ),

                        SizedBox(height: h * 0.018),

                        // ==========================================
                        // FEEL EVERY BEAT
                        // ==========================================

                        Text(
                          'Feel Every Beat',
                          style: TextStyle(
                            color: const Color(0xFFD5B6FF),
                            fontSize: w * 0.035,
                            fontWeight: FontWeight.w400,
                            letterSpacing: w * 0.010,
                          ),
                        ),

                        SizedBox(height: h * 0.025),

                        // ==========================================
                        // GLOW LINE
                        // ==========================================

                        Container(
                          width: w * 0.28,
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Colors.transparent,
                                Color(0xFF6D28D9),
                                Color(0xFFC084FC),
                                Colors.white,
                                Color(0xFFC084FC),
                                Color(0xFF6D28D9),
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFA855F7)
                                    .withValues(alpha: 0.85),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ==================================================
              // MUSIC WAVE
              // ==================================================

              Positioned(
                left: 0,
                right: 0,
                top: h * 0.605,
                child: SizedBox(
                  height: h * 0.13,
                  child: const CustomPaint(
                    painter: MusicWavePainter(),
                  ),
                ),
              ),

              // ==================================================
              // PLAY • DISCOVER • ORGANIZE • ENJOY
              // ==================================================

              Positioned(
                left: 0,
                right: 0,
                top: h * 0.715,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: w * 0.075,
                  ),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SplashWord('PLAY'),
                        SplashDot(),
                        SplashWord('DISCOVER'),
                        SplashDot(),
                        SplashWord('ORGANIZE'),
                        SplashDot(),
                        SplashWord('ENJOY'),
                      ],
                    ),
                  ),
                ),
              ),

              // ==================================================
              // BOTTOM RIGHT
              // ==================================================

              Positioned(
                right: w * 0.08,
                bottom: h * 0.075,
                child: Transform.rotate(
                  angle: -0.08,
                  child: Column(
                    children: [
                      Text(
                        'A Better\nYou',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFFA855F7),
                          fontSize: w * 0.052,
                          height: 1.0,
                          fontWeight: FontWeight.w300,
                          fontStyle: FontStyle.italic,
                        ),
                      ),

                      SizedBox(height: h * 0.010),

                      Container(
                        width: w * 0.13,
                        height: 1,
                        color: const Color(0xFFA855F7),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================
// SMALL TEXT
// ============================================================

class SplashWord extends StatelessWidget {
  final String text;

  const SplashWord(
    this.text, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFFE4D1FF),
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 2.5,
      ),
    );
  }
}

class SplashDot extends StatelessWidget {
  const SplashDot({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 12,
      ),
      child: Text(
        '•',
        style: TextStyle(
          color: Color(0xFFA855F7),
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ============================================================
// BACKGROUND CURVES
// ============================================================

class BackgroundCurvePainter extends CustomPainter {
  const BackgroundCurvePainter();

  @override
  void paint(Canvas canvas, Size size) {
    // ==========================================================
    // TOP RIGHT LARGE PLANET
    // ==========================================================

    final Rect topRect = Rect.fromCircle(
      center: Offset(
        size.width * 1.02,
        size.height * -0.045,
      ),
      radius: size.width * 0.43,
    );

    final Paint topGlow = Paint()
      ..color = const Color(0xFF7C3AED)
          .withValues(alpha: 0.16)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        28,
      );

    canvas.drawCircle(
      topRect.center,
      topRect.width / 2,
      topGlow,
    );

    final Paint topPlanet = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.8, 0.8),
        radius: 1.1,
        colors: [
          Color(0xFF5B21B6),
          Color(0xFF25085A),
          Color(0xFF0B0616),
        ],
        stops: [0.0, 0.55, 1.0],
      ).createShader(topRect);

    canvas.drawCircle(
      topRect.center,
      topRect.width / 2,
      topPlanet,
    );

    final Paint topEdgeGlow = Paint()
      ..color = const Color(0xFF9B4DFF)
          .withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        9,
      );

    canvas.drawArc(
      topRect,
      math.pi * 0.42,
      math.pi * 0.92,
      false,
      topEdgeGlow,
    );

    final Paint topEdge = Paint()
      ..color = const Color(0xFFB66CFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    canvas.drawArc(
      topRect,
      math.pi * 0.42,
      math.pi * 0.92,
      false,
      topEdge,
    );

    // ==========================================================
    // BOTTOM LEFT LARGE PLANET
    // ==========================================================

    final Rect bottomRect = Rect.fromCircle(
      center: Offset(
        -size.width * 0.14,
        size.height * 1.03,
      ),
      radius: size.width * 0.58,
    );

    final Paint bottomGlow = Paint()
      ..color = const Color(0xFF6D28D9)
          .withValues(alpha: 0.14)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        30,
      );

    canvas.drawCircle(
      bottomRect.center,
      bottomRect.width / 2,
      bottomGlow,
    );

    final Paint bottomPlanet = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0.8, -0.7),
        radius: 1.15,
        colors: [
          Color(0xFF3B0B84),
          Color(0xFF1D063E),
          Color(0xFF08050F),
        ],
        stops: [0.0, 0.60, 1.0],
      ).createShader(bottomRect);

    canvas.drawCircle(
      bottomRect.center,
      bottomRect.width / 2,
      bottomPlanet,
    );

    final Paint bottomEdgeGlow = Paint()
      ..color = const Color(0xFF7C3AED)
          .withValues(alpha: 0.30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        10,
      );

    canvas.drawArc(
      bottomRect,
      math.pi * 1.30,
      math.pi * 0.70,
      false,
      bottomEdgeGlow,
    );

    final Paint bottomEdge = Paint()
      ..color = const Color(0xFF8B5CF6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    canvas.drawArc(
      bottomRect,
      math.pi * 1.30,
      math.pi * 0.70,
      false,
      bottomEdge,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}

// ============================================================
// PARTICLES
// ============================================================

class ParticlePainter extends CustomPainter {
  const ParticlePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint glowPaint = Paint()
      ..color = const Color(0xFF8B5CF6)
          .withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        5,
      );

    final Paint dotPaint = Paint()
      ..color = const Color(0xFF8B5CF6)
          .withValues(alpha: 0.70);

    final List<Offset> dots = [
      Offset(size.width * 0.81, size.height * 0.17),
      Offset(size.width * 0.91, size.height * 0.20),
      Offset(size.width * 0.94, size.height * 0.23),

      Offset(size.width * 0.20, size.height * 0.61),
      Offset(size.width * 0.24, size.height * 0.64),

      Offset(size.width * 0.83, size.height * 0.62),
      Offset(size.width * 0.88, size.height * 0.65),

      Offset(size.width * 0.24, size.height * 0.78),
      Offset(size.width * 0.34, size.height * 0.82),
      Offset(size.width * 0.42, size.height * 0.87),

      Offset(size.width * 0.49, size.height * 0.91),
      Offset(size.width * 0.58, size.height * 0.94),
    ];

    for (int i = 0; i < dots.length; i++) {
      final double radius =
          i % 3 == 0 ? 2.5 : 1.5;

      canvas.drawCircle(
        dots[i],
        radius + 2,
        glowPaint,
      );

      canvas.drawCircle(
        dots[i],
        radius,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}

// ============================================================
// PREMIUM MUSIC WAVE
// ============================================================

class MusicWavePainter extends CustomPainter {
  const MusicWavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double centerY =
        size.height * 0.50;

    // ==========================================================
    // MULTIPLE THIN WAVES
    // ==========================================================

    for (int i = 0; i < 12; i++) {
      final Path path = Path();

      for (
        double x = -10;
        x <= size.width + 10;
        x += 2
      ) {
        final double progress =
            x / size.width;

        final double amplitude =
            size.height *
            (0.17 + (i * 0.003));

        final double phase =
            (i - 6) * 0.055;

        final double y =
            centerY +
            ((i - 6) * 1.7) +
            math.sin(
                  progress * math.pi * 3.0 +
                      phase,
                ) *
                amplitude;

        if (x <= -9) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      final Paint thinPaint = Paint()
        ..color = const Color(0xFF7C3AED)
            .withValues(
          alpha: 0.12 + i * 0.012,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7;

      canvas.drawPath(
        path,
        thinPaint,
      );
    }

    // ==========================================================
    // MAIN WAVE
    // ==========================================================

    final Path mainPath = Path();

    for (
      double x = -10;
      x <= size.width + 10;
      x += 2
    ) {
      final double progress =
          x / size.width;

      final double y =
          centerY +
          math.sin(
                progress * math.pi * 3.0,
              ) *
              (size.height * 0.20);

      if (x <= -9) {
        mainPath.moveTo(x, y);
      } else {
        mainPath.lineTo(x, y);
      }
    }

    // ==========================================================
    // GLOW
    // ==========================================================

    final Paint glowPaint = Paint()
      ..color = const Color(0xFF9B4DFF)
          .withValues(alpha: 0.42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        12,
      );

    canvas.drawPath(
      mainPath,
      glowPaint,
    );

    // ==========================================================
    // BRIGHT MAIN LINE
    // ==========================================================

    final Paint mainPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF7C3AED),
          Color(0xFFA855F7),
          Color(0xFFE9D5FF),
          Colors.white,
          Color(0xFFB66CFF),
          Color(0xFF7C3AED),
        ],
      ).createShader(
        Rect.fromLTWH(
          0,
          0,
          size.width,
          size.height,
        ),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(
      mainPath,
      mainPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}
