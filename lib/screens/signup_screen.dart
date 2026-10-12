import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../navigation/main_shell.dart';

import 'login_screen.dart';

// SONEXA static 393x880 reference design. Local prototype signup only.

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _name = TextEditingController();

  final _email = TextEditingController();

  final _password = TextEditingController();

  final _confirm = TextEditingController();

  bool _hidePassword = true;

  bool _hideConfirm = true;

  bool _loading = false;

  static const _bg = Color(0xFF090414);

  static const _purple = Color(0xFFC04BFF);

  @override
  void dispose() {
    _name.dispose();

    _email.dispose();

    _password.dispose();

    _confirm.dispose();

    super.dispose();
  }

  void _message(String value) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(value),

          behavior: SnackBarBehavior.floating,

          backgroundColor: const Color(0xFF3B164C),
        ),
      );
  }

  // Called ONLY when the CREATE ACCOUNT button is tapped.

  Future<void> _createAccount() async {
    if (_loading) return;

    FocusManager.instance.primaryFocus?.unfocus();

    final name = _name.text.trim();

    final email = _email.text.trim();

    final password = _password.text;

    final confirm = _confirm.text;

    if (name.isEmpty) {
      _message('Please enter your full name');

      return;
    }

    if (name.length < 2 || !RegExp(r"^[a-zA-Z][a-zA-Z .'-]*$").hasMatch(name)) {
      _message('Please enter a valid full name');

      return;
    }

    if (email.isEmpty) {
      _message('Please enter your email address');

      return;
    }

    if (!RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
        .hasMatch(email)) {
      _message('Please enter a valid email address');

      return;
    }

    if (password.isEmpty) {
      _message('Please create a password');

      return;
    }

    if (password.length < 6) {
      _message('Password must be at least 6 characters');
      return;
    }

    if (confirm.isEmpty) {
      _message('Please confirm your password');

      return;
    }

    if (password != confirm) {
      _message('Passwords do not match');

      return;
    }

    setState(() => _loading = true);

    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('sonexa_profile_name', name);

      await prefs.setString('sonexa_profile_email', email);

      await prefs.setString('account_name', name);

      await prefs.setString('account_email', email);

      // Do NOT save the password to SharedPreferences.

      await prefs.setBool('hasRegistered', true);

      await prefs.setBool('isLoggedIn', true);

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const MainShell()),

        (route) => false,
      );
    } catch (_) {
      _message('Unable to create your profile. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
    );
  }

  // Clean text rows: no nested pill, underline or theme-provided fill.

  Widget _field({
    required double top,

    required String label,

    required String hint,

    required IconData icon,

    required TextEditingController controller,

    bool password = false,

    bool confirm = false,

    TextInputType? keyboardType,

    TextInputAction inputAction = TextInputAction.next,
  }) {
    final hidden = confirm ? _hideConfirm : _hidePassword;

    return Positioned(
      left: 24,

      right: 24,

      top: top,

      height: 60,

      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xC5160929),

          borderRadius: BorderRadius.circular(32),

          border: Border.all(color: const Color(0xFF4F285D), width: 1),
        ),

        child: Row(
          children: [
            const SizedBox(width: 18),

            Icon(icon, color: const Color(0xFFE084FF), size: 28),

            const SizedBox(width: 18),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    label,

                    style: const TextStyle(
                      color: Colors.white,

                      fontSize: 11.5,

                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 3),

                  SizedBox(
                    height: 24,

                    child: Theme(
                      data: Theme.of(context).copyWith(
                        inputDecorationTheme: const InputDecorationTheme(
                          filled: false,

                          fillColor: Colors.transparent,

                          border: InputBorder.none,

                          enabledBorder: InputBorder.none,

                          focusedBorder: InputBorder.none,

                          disabledBorder: InputBorder.none,

                          errorBorder: InputBorder.none,

                          focusedErrorBorder: InputBorder.none,

                          contentPadding: EdgeInsets.zero,

                          isDense: true,
                        ),
                      ),

                      child: TextField(
                        controller: controller,

                        obscureText: password && hidden,

                        keyboardType: keyboardType,

                        textInputAction: inputAction,

                        // No onSubmitted: keyboard Done only closes keyboard.
                        onEditingComplete: () =>
                            FocusScope.of(context).unfocus(),

                        cursorColor: _purple,

                        cursorHeight: 16,

                        style: const TextStyle(
                          fontSize: 13,

                          color: Colors.white,
                        ),

                        decoration: InputDecoration(
                          hintText: hint,

                          hintStyle: const TextStyle(
                            color: Color(0xFFB3A8BE),

                            fontSize: 13,
                          ),

                          filled: false,

                          fillColor: Colors.transparent,

                          isDense: true,

                          contentPadding: EdgeInsets.zero,

                          border: InputBorder.none,

                          enabledBorder: InputBorder.none,

                          focusedBorder: InputBorder.none,

                          disabledBorder: InputBorder.none,

                          errorBorder: InputBorder.none,

                          focusedErrorBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (password)
              IconButton(
                onPressed: () => setState(() {
                  if (confirm) {
                    _hideConfirm = !_hideConfirm;
                  } else {
                    _hidePassword = !_hidePassword;
                  }
                }),

                icon: Icon(
                  hidden
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,

                  color: const Color(0xFFE084FF),

                  size: 26,
                ),
              ),

            if (!password) const SizedBox(width: 20),
          ],
        ),
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
          builder: (context, constraints) => ClipRect(
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
                        left: 23,

                        top: 55,

                        child: Text(
                          'M O R E\nT H A N\nM U S I C',

                          style: TextStyle(
                            color: Color(0xFFEAD7F6),

                            fontSize: 11,

                            height: 1.85,

                            letterSpacing: 1,
                          ),
                        ),
                      ),

                      const Positioned(
                        left: 25,

                        top: 116,

                        child: _GlowLine(width: 44),
                      ),

                      const Positioned(
                        left: 329,

                        top: 163,

                        child: _MusicNote(size: 32),
                      ),

                      const Positioned(
                        left: 45,

                        top: 217,

                        child: _MusicNote(size: 36),
                      ),

                      const Positioned(
                        left: 330,

                        top: 267,

                        child: _MusicNote(size: 26),
                      ),

                      const Positioned(
                        left: 351,

                        top: 700,

                        child: _MusicNote(size: 33),
                      ),

                      Positioned(
                        top: 127,

                        left: 0,

                        width: 393,

                        child: Column(
                          mainAxisSize: MainAxisSize.min,

                          children: [
                            SizedBox(
                              width: 113,

                              height: 113,

                              child: Image.asset(
                                'assets/images/sonexa_logo.png',

                                fit: BoxFit.contain,

                                errorBuilder: (_, error, trace) => Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(28),

                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFCA65FF),

                                        Color(0xFF4D0FA5),
                                      ],
                                    ),
                                  ),

                                  child: const Icon(
                                    Icons.graphic_eq_rounded,

                                    color: Colors.white,

                                    size: 70,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 7),

                            const Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'SONEX',

                                    style: TextStyle(color: Colors.white),
                                  ),

                                  TextSpan(
                                    text: 'A',

                                    style: TextStyle(color: Color(0xFFB852FA)),
                                  ),
                                ],
                              ),

                              style: TextStyle(
                                fontSize: 35,

                                fontWeight: FontWeight.w800,

                                height: 1,

                                letterSpacing: -.6,
                              ),
                            ),

                            const SizedBox(height: 8),

                            const Text(
                              'F e e l  E v e r y  B e a t',

                              style: TextStyle(
                                color: Color(0xFFF3DFFB),

                                fontSize: 10.5,
                              ),
                            ),

                            const SizedBox(height: 12),

                            const _GlowLine(width: 79),
                          ],
                        ),
                      ),

                      _field(
                        top: 326,

                        label: 'Full Name',

                        hint: 'Enter your full name',

                        icon: Icons.person_outline_rounded,

                        controller: _name,
                      ),

                      _field(
                        top: 394,

                        label: 'Email',

                        hint: 'Enter your email',

                        icon: Icons.mail_outline_rounded,

                        controller: _email,

                        keyboardType: TextInputType.emailAddress,
                      ),

                      _field(
                        top: 464,

                        label: 'Password',

                        hint: 'Create a password',

                        icon: Icons.lock_outline_rounded,

                        controller: _password,

                        password: true,
                      ),

                      _field(
                        top: 535,

                        label: 'Confirm Password',

                        hint: 'Confirm your password',

                        icon: Icons.lock_outline_rounded,

                        controller: _confirm,

                        password: true,

                        confirm: true,

                        inputAction: TextInputAction.done,
                      ),

                      Positioned(
                        left: 24,

                        right: 24,

                        top: 609,

                        height: 50,

                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),

                            gradient: const LinearGradient(
                              colors: [Color(0xFFB946F6), Color(0xFF8000FF)],
                            ),
                          ),

                          child: ElevatedButton(
                            onPressed: _loading ? null : _createAccount,

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
                                ? const SizedBox(
                                    width: 22,

                                    height: 22,

                                    child: CircularProgressIndicator(
                                      color: Colors.white,

                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'CREATE ACCOUNT',

                                    style: TextStyle(
                                      fontSize: 15.4,

                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      Positioned(
                        top: 680,

                        left: 0,

                        width: 393,

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            const Text(
                              'Already have an account?',

                              style: TextStyle(
                                color: Colors.white,

                                fontSize: 12.5,
                              ),
                            ),

                            const SizedBox(width: 9),

                            InkWell(
                              onTap: _openLogin,

                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 4),

                                child: Text(
                                  'Login',

                                  style: TextStyle(
                                    color: _purple,

                                    fontSize: 12.5,

                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
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
          ),
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
    width: width,

    height: 2,

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
  const _MusicNote({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) => Icon(
    Icons.music_note_rounded,

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

    canvas.drawCircle(
      topCenter,

      topRadius,

      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-.55, .6),

          radius: 1.35,

          colors: [Color(0xFF9B16F8), Color(0xFF6400BD), Color(0xFF300663)],
        ).createShader(Rect.fromCircle(center: topCenter, radius: topRadius)),
    );

    canvas.drawCircle(
      topCenter,

      topRadius,

      Paint()
        ..color = const Color(0xFFB566FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    const dots = <Offset>[
      Offset(311, 108),

      Offset(358, 146),

      Offset(79, 170),

      Offset(35, 216),

      Offset(321, 223),

      Offset(44, 307),

      Offset(80, 682),

      Offset(319, 692),

      Offset(359, 712),
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
