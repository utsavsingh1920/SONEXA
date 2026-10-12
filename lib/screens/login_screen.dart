import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../navigation/main_shell.dart';

import 'signup_screen.dart';

/// Matches the 393 x 880 design reference with no scroll view.

/// The full composition scales to the available screen.

class LoginScreen extends StatefulWidget {

  const LoginScreen({super.key});

  @override

  State<LoginScreen> createState() => _LoginScreenState();

}

class _LoginScreenState extends State<LoginScreen> {

  final _email = TextEditingController();

  final _password = TextEditingController();

  bool _hidden = true;

  bool _loading = false;

  static const _bg = Color(0xFF090414);

  static const _purple = Color(0xFFBC50FF);

  @override

  void dispose() {

    _email.dispose();

    _password.dispose();

    super.dispose();

  }

  void _message(String message) {

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(content: Text(message)),

    );

  }

  Future<void> _login() async {

    FocusManager.instance.primaryFocus?.unfocus();

    if (_loading) return;

    final email = _email.text.trim();

    if (!RegExp(r'^[\w.+-]+@[\w\.-]+\.[A-Za-z]{2,}$').hasMatch(email)) {

      _message('Please enter a valid email');

      return;

    }

    if (_password.text.length < 6) {

      _message('Password must be at least 6 characters');

      return;

    }

    setState(() => _loading = true);

    try {

      // Retains your original prototype login flow (not server authentication).

      await Future.delayed(const Duration(milliseconds: 700));

      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool('isLoggedIn', true);

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(

        MaterialPageRoute<void>(builder: (_) => const MainShell()),

        (_) => false,

      );

    } catch (_) {

      _message('Could not sign in. Please try again.');

    } finally {

      if (mounted) setState(() => _loading = false);

    }

  }

  Future<void> _forgotPassword() async {

    final controller = TextEditingController();

    await showDialog<void>(

      context: context,

      builder: (dialogContext) => AlertDialog(

        backgroundColor: const Color(0xFF1B1029),

        title: const Text('Forgot Password?',

            style: TextStyle(color: Colors.white)),

        content: TextField(

          controller: controller,

          style: const TextStyle(color: Colors.white),

          keyboardType: TextInputType.emailAddress,

          decoration: const InputDecoration(

            hintText: 'Enter your email',

            hintStyle: TextStyle(color: Colors.white54),

          ),

        ),

        actions: [

          TextButton(

            onPressed: () => Navigator.pop(dialogContext),

            child: const Text('Cancel'),

          ),

          TextButton(

            onPressed: () {

              Navigator.pop(dialogContext);

              _message('Password recovery is not configured yet.');

            },

            child: const Text('Continue'),

          ),

        ],

      ),

    );

    controller.dispose();

  }

  void _openSignup() {

    Navigator.of(context).pushReplacement(

      MaterialPageRoute<void>(builder: (_) => const SignupScreen()),

    );

  }

  InputDecoration _inputDecoration(String hint, IconData icon,

      {Widget? suffix}) {

    return InputDecoration(

      hintText: hint,

      hintStyle: const TextStyle(color: Color(0xFFAFA4BB), fontSize: 12.5),

      prefixIcon: Icon(icon, color: const Color(0xFFDA79FC), size: 23),

      prefixIconConstraints: const BoxConstraints(minWidth: 57),

      suffixIcon: suffix,

      filled: true,

      fillColor: const Color(0xC5160929),

      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 13),

      border: OutlineInputBorder(borderRadius: BorderRadius.circular(28)),

      enabledBorder: OutlineInputBorder(

        borderRadius: BorderRadius.circular(28),

        borderSide: const BorderSide(color: Color(0xFF5B326D), width: 1.0),

      ),

      focusedBorder: OutlineInputBorder(

        borderRadius: BorderRadius.circular(28),

        borderSide: const BorderSide(color: _purple, width: 1.3),

      ),

    );

  }

  @override

  Widget build(BuildContext context) {

    return AnnotatedRegion<SystemUiOverlayStyle>(

      value: SystemUiOverlayStyle.light.copyWith(

        statusBarColor: Colors.transparent,

        statusBarIconBrightness: Brightness.light,

        systemNavigationBarColor: _bg,

        systemNavigationBarIconBrightness: Brightness.light,

      ),

      child: Scaffold(

        backgroundColor: _bg,

        resizeToAvoidBottomInset: false,

        body: LayoutBuilder(

          builder: (context, viewport) {

            return ClipRect(

              child: SizedBox.expand(

                child: FittedBox(

                  fit: BoxFit.fill,

                  alignment: Alignment.topLeft,

                  child: SizedBox(

                    width: 393,

                    height: 880,

                    child: Stack(

                      clipBehavior: Clip.hardEdge,

                      children: [

                        const Positioned.fill(

                          child: CustomPaint(painter: _LoginBackdropPainter()),

                        ),

                        const Positioned(

                          left: 23, top: 59,

                          child: Text('M O R E\nT H A N\nM U S I C',

                            style: TextStyle(

                              color: Color(0xFFEAD7F6),

                              fontSize: 11, height: 1.85, letterSpacing: 1.0,

                            ),

                          ),

                        ),

                        const Positioned(left: 25, top: 115,

                            child: _GlowLine(width: 44)),

                        const Positioned(left: 331, top: 171,

                            child: _MusicNote(size: 32)),

                        const Positioned(left: 43, top: 234,

                            child: _MusicNote(size: 34)),

                        const Positioned(left: 342, top: 263,

                            child: _MusicNote(size: 30)),

                        const Positioned(left: 350, top: 663,

                            child: _MusicNote(size: 31)),

                        // Top logo + title use fixed reference-image coordinates.

                        Positioned(

                          top: 147, left: 0, width: 393,

                          child: Column(

                            mainAxisSize: MainAxisSize.min,

                            children: [

                              SizedBox(

                                width: 116, height: 116,

                                child: Image.asset(

                                  'assets/images/sonexa_logo.png',

                                  fit: BoxFit.contain,

                                  errorBuilder: (_, error, trace) =>

                                    Container(

                                      decoration: BoxDecoration(

                                        borderRadius: BorderRadius.circular(28),

                                        gradient: const LinearGradient(colors: [

                                          Color(0xFFCA65FF), Color(0xFF4D0FA5),

                                        ]),

                                      ),

                                      child: const Icon(Icons.graphic_eq_rounded,

                                          color: Colors.white, size: 70),

                                    ),

                                ),

                              ),

                              const SizedBox(height: 8),

                              const Text.rich(

                                TextSpan(children: [

                                  TextSpan(text: 'SONEX',

                                      style: TextStyle(color: Colors.white)),

                                  TextSpan(text: 'A',

                                      style: TextStyle(color: Color(0xFFB852FA))),

                                ]),

                                textAlign: TextAlign.center,

                                style: TextStyle(

                                  fontSize: 37, fontWeight: FontWeight.w800,

                                  height: 1, letterSpacing: -.6,

                                ),

                              ),

                              const SizedBox(height: 10),

                              const Text('F e e l  E v e r y  B e a t',

                                style: TextStyle(

                                  fontSize: 10.7,

                                  color: Color(0xFFF3DFFB),

                                ),

                              ),

                              const SizedBox(height: 16),

                              const _GlowLine(width: 85),

                            ],

                          ),

                        ),

                        // Reference positions: Email ~373, Password ~462,

                        // Login button ~578, Sign Up ~652.

                        Positioned(

                          top: 371, left: 29, width: 335,

                          child: Column(

                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [

                              const Text('Email', style: TextStyle(

                                color: Colors.white,

                                fontSize: 13.2, fontWeight: FontWeight.w700,

                              )),

                              const SizedBox(height: 9),

                              SizedBox(

                                height: 47,

                                child: TextField(

                                  controller: _email,

                                  keyboardType: TextInputType.emailAddress,

                                  textInputAction: TextInputAction.next,

                                  style: const TextStyle(color: Colors.white, fontSize: 14),

                                  decoration: _inputDecoration(

                                      'Enter your email', Icons.mail_outline_rounded),

                                ),

                              ),

                            ],

                          ),

                        ),

                        Positioned(

                          top: 460, left: 29, width: 335,

                          child: Column(

                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [

                              const Text('Password', style: TextStyle(

                                color: Colors.white,

                                fontSize: 13.2, fontWeight: FontWeight.w700,

                              )),

                              const SizedBox(height: 9),

                              SizedBox(

                                height: 47,

                                child: TextField(

                                  controller: _password,

                                  obscureText: _hidden,

                                  textInputAction: TextInputAction.done,

                                  onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),

                                  style: const TextStyle(color: Colors.white, fontSize: 14),

                                  decoration: _inputDecoration(

                                    'Enter your password', Icons.lock_outline_rounded,

                                    suffix: IconButton(

                                      onPressed: () => setState(() => _hidden = !_hidden),

                                      icon: Icon(

                                        _hidden

                                            ? Icons.visibility_outlined

                                            : Icons.visibility_off_outlined,

                                        color: const Color(0xFFCF69FF),

                                        size: 27,

                                      ),

                                    ),

                                  ),

                                ),

                              ),

                            ],

                          ),

                        ),

                        Positioned(

                          right: 29, top: 541,

                          child: TextButton(

                            onPressed: _forgotPassword,

                            style: TextButton.styleFrom(

                              padding: EdgeInsets.zero,

                              minimumSize: const Size(0, 28),

                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,

                            ),

                            child: const Text('Forgot Password?', style: TextStyle(

                              color: _purple, fontSize: 11.5,

                              fontWeight: FontWeight.w700,

                            )),

                          ),

                        ),

                        Positioned(

                          left: 29, right: 29, top: 578, height: 48,

                          child: DecoratedBox(

                            decoration: BoxDecoration(

                              borderRadius: BorderRadius.circular(30),

                              gradient: const LinearGradient(

                                colors: [Color(0xFFB946F6), Color(0xFF8000FF)],

                              ),

                            ),

                            child: ElevatedButton(

                              onPressed: _loading ? null : _login,

                              style: ElevatedButton.styleFrom(

                                backgroundColor: Colors.transparent,

                                disabledBackgroundColor: Colors.transparent,

                                shadowColor: Colors.transparent,

                                foregroundColor: Colors.white,

                                shape: RoundedRectangleBorder(

                                  borderRadius: BorderRadius.circular(30),

                                ),

                              ),

                              child: _loading

                                  ? const SizedBox(width: 21, height: 21,

                                      child: CircularProgressIndicator(

                                        color: Colors.white, strokeWidth: 2))

                                  : const Text('LOGIN', style: TextStyle(

                                      fontWeight: FontWeight.w800, fontSize: 17)),

                            ),

                          ),

                        ),

                        Positioned(

                          top: 645, left: 0, width: 393,

                          child: Row(

                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [

                              const Text("Don't have an account?", style: TextStyle(

                                color: Colors.white, fontSize: 12.8,

                              )),

                              const SizedBox(width: 5),

                              InkWell(

                                onTap: _openSignup,

                                child: const Padding(

                                  padding: EdgeInsets.symmetric(vertical: 4),

                                  child: Text('Sign Up', style: TextStyle(

                                    color: _purple, fontSize: 12.8,

                                    fontWeight: FontWeight.w700,

                                  )),

                                ),

                              ),

                            ],

                          ),

                        ),

                      ],

                    ),

                  ),

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

  const _GlowLine({required this.width});

  final double width;

  @override

  Widget build(BuildContext context) => Container(

    width: width, height: 2,

    decoration: BoxDecoration(

      gradient: const LinearGradient(colors: [

        Colors.transparent, Color(0xFF8B24FF), Color(0xFFECA6FF),

        Color(0xFF8B24FF), Colors.transparent,

      ]),

      boxShadow: [BoxShadow(

        color: const Color(0xFFB449FF).withValues(alpha: .8), blurRadius: 11,

      )],

    ),

  );

}

class _MusicNote extends StatelessWidget {

  const _MusicNote({required this.size});

  final double size;

  @override

  Widget build(BuildContext context) => Icon(

    Icons.music_note_rounded, size: size,

    color: const Color(0xFFAB4BFF),

    shadows: [Shadow(color: const Color(0xFFAB4BFF).withValues(alpha: .8),

      blurRadius: 13)],

  );

}

class _LoginBackdropPainter extends CustomPainter {

  const _LoginBackdropPainter();

  @override

  void paint(Canvas canvas, Size size) {

    const w = 393.0;

    const h = 880.0;

    canvas.save();

    // Waves must finish at the bottom edge of the actual canvas.

    canvas.scale(size.width / w, size.height / h);

    final background = const Rect.fromLTWH(0, 0, w, h);

    canvas.drawRect(

      background,

      Paint()

        ..shader = const RadialGradient(

          center: Alignment(0, -0.22),

          radius: 1.05,

          colors: [Color(0xFF230C3C), Color(0xFF10071E), Color(0xFF070310)],

          stops: [0, .53, 1],

        ).createShader(background),

    );

    // Top-right cropped purple circle from the reference.

    const topCenter = Offset(405, -82);

    const topRadius = 181.0;

    canvas.drawCircle(topCenter, topRadius, Paint()

      ..shader = const RadialGradient(

        center: Alignment(-.55, .6), radius: 1.35,

        colors: [Color(0xFF9B16F8), Color(0xFF6400BD), Color(0xFF300663)],

      ).createShader(Rect.fromCircle(center: topCenter, radius: topRadius)));

    canvas.drawCircle(topCenter, topRadius, Paint()

      ..color = const Color(0xFFB566FF)

      ..style = PaintingStyle.stroke

      ..strokeWidth = 1);

    const dots = <Offset>[

      Offset(311, 108), Offset(358, 146), Offset(79, 170),

      Offset(35, 216), Offset(321, 223), Offset(44, 307),

      Offset(80, 682), Offset(319, 692), Offset(359, 712),

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

    const orbCenter = Offset(-119, 902);

    const orbRadius = 242.0;

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

      ..moveTo(-12, 727 + dy)

      ..cubicTo(66, 736 + dy, 138, 810 + dy, 202, 788 + dy)

      ..cubicTo(271, 765 + dy, 335, 703 + dy, 407, 733 + dy);

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

        ).createShader(const Rect.fromLTWH(0, 720, w, 160)),

    );

    // Semi-transparent flowing silk that crosses the orb.

    final silk = Path()

      ..moveTo(-12, 775)

      ..cubicTo(74, 705, 137, 816, 202, 816)

      ..cubicTo(285, 815, 340, 720, 407, 762)

      ..lineTo(407, 827)

      ..cubicTo(327, 787, 276, 863, 199, 854)

      ..cubicTo(111, 848, 60, 759, -12, 836)

      ..close();

    canvas.drawPath(

      silk,

      Paint()

        ..shader = const LinearGradient(

          begin: Alignment.topCenter,

          end: Alignment.bottomCenter,

          colors: [Color(0xBB8E35F9), Color(0x884E18AE), Color(0x00250A55)],

        ).createShader(const Rect.fromLTWH(0, 710, w, 165)),

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

        ).createShader(const Rect.fromLTWH(0, 710, w, 130))

        ..style = PaintingStyle.stroke

        ..strokeWidth = 2.2

        ..strokeCap = StrokeCap.round,

    );

    final lowerFold = Path()

      ..moveTo(-12, 827)

      ..cubicTo(74, 779, 136, 863, 200, 860)

      ..cubicTo(279, 860, 344, 802, 407, 829)

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

        ).createShader(const Rect.fromLTWH(0, 790, w, 90)),

    );

    canvas.restore();

  }

  @override

  bool shouldRepaint(covariant _LoginBackdropPainter oldDelegate) => false;

}
