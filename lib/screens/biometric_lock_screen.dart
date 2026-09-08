import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class BiometricLockScreen extends StatefulWidget {
  const BiometricLockScreen({
    super.key,
    required this.onUnlocked,
  });

  final VoidCallback onUnlocked;

  @override
  State<BiometricLockScreen> createState() =>
      _BiometricLockScreenState();
}

class _BiometricLockScreenState
    extends State<BiometricLockScreen> {
  final LocalAuthentication _localAuth =
      LocalAuthentication();

  bool _authenticating = false;

  // ============================================================
  // THEME COLORS
  // ============================================================

  static const Color _darkBackground =
      Color(0xFF080812);

  static const Color _lightBackground =
      Color(0xFFF7F5FA);

  static const Color _darkPrimary =
      Colors.white;

  static const Color _lightPrimary =
      Color(0xFF18151D);

  static const Color _darkSecondary =
      Color(0xFFA8A0B3);

  static const Color _lightSecondary =
      Color(0xFF70697A);

  static const Color _darkButton =
      Color(0xFF9B6BFF);

  static const Color _lightButton =
      Color(0xFF7B3FE4);

  static const Color _darkDisabled =
      Color(0xFF352447);

  static const Color _lightDisabled =
      Color(0xFFE4D8F5);

  // ============================================================
  // STATE
  // ============================================================

  String _message =
      'Use fingerprint or face unlock';

  // ============================================================
  // THEME HELPERS
  // ============================================================

  bool _isDark(BuildContext context) {
    return Theme.of(context).brightness ==
        Brightness.dark;
  }

  Color _background(BuildContext context) {
    return _isDark(context)
        ? _darkBackground
        : _lightBackground;
  }

  Color _primaryText(BuildContext context) {
    return _isDark(context)
        ? _darkPrimary
        : _lightPrimary;
  }

  Color _secondaryText(BuildContext context) {
    return _isDark(context)
        ? _darkSecondary
        : _lightSecondary;
  }

  Color _buttonColor(BuildContext context) {
    return _isDark(context)
        ? _darkButton
        : _lightButton;
  }

  Color _disabledButton(BuildContext context) {
    return _isDark(context)
        ? _darkDisabled
        : _lightDisabled;
  }

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _authenticate();
      }
    });
  }

  // ============================================================
  // BIOMETRIC AUTHENTICATION
  // ============================================================

  Future<void> _authenticate() async {
    if (_authenticating) return;

    if (!mounted) return;

    setState(() {
      _authenticating = true;

      // IMPORTANT:
      // Previous "Authentication cancelled" message
      // will not stay permanently.
      _message =
          'Use fingerprint or face unlock';
    });

    try {
      final bool supported =
          await _localAuth.isDeviceSupported();

      if (!supported) {
        if (!mounted) return;

        setState(() {
          _message =
              'Biometric authentication is not supported on this device.';
          _authenticating = false;
        });

        return;
      }

      final bool canCheck =
          await _localAuth.canCheckBiometrics;

      if (!canCheck) {
        if (!mounted) return;

        setState(() {
          _message =
              'No fingerprint or face authentication is available.';
          _authenticating = false;
        });

        return;
      }

      final List<BiometricType> available =
          await _localAuth.getAvailableBiometrics();

      if (available.isEmpty) {
        if (!mounted) return;

        setState(() {
          _message =
              'Please set up fingerprint or face unlock on your device first.';
          _authenticating = false;
        });

        return;
      }

      final bool authenticated =
          await _localAuth.authenticate(
        localizedReason:
            'Unlock SONEXA using your fingerprint or face.',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
          sensitiveTransaction: true,
        ),
      );

      if (!mounted) return;

      if (authenticated) {
        widget.onUnlocked();
        return;
      }

      // ========================================================
      // CANCEL / WRONG BIOMETRIC
      // ========================================================

      setState(() {
        _authenticating = false;

        // Don't permanently show "Authentication cancelled".
        _message =
            'Use fingerprint or face unlock';
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _authenticating = false;

        // Keep user on lock screen.
        _message =
            'Authentication failed. Try again.';
      });
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final bool dark = _isDark(context);

    return Scaffold(
      backgroundColor: _background(context),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 30,
            ),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                // ==================================================
                // SONEXA LOGO
                // ==================================================

                SizedBox(
                  width: 150,
                  height: 150,
                  child: Image.asset(
                    'assets/images/sonexa_logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return Icon(
                        Icons.music_note_rounded,
                        color: _buttonColor(context),
                        size: 85,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 28),

                // ==================================================
                // TITLE
                // ==================================================

                Text(
                  'SONEXA is Locked',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _primaryText(context),
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),

                const SizedBox(height: 10),

                // ==================================================
                // MESSAGE
                // ==================================================

                AnimatedSwitcher(
                  duration:
                      const Duration(milliseconds: 200),
                  child: Text(
                    _message,
                    key: ValueKey(_message),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _secondaryText(context),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ==================================================
                // UNLOCK BUTTON
                // ==================================================

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _authenticating
                        ? null
                        : _authenticate,

                    icon: Icon(
                      Icons.fingerprint_rounded,
                      size: 23,
                      color: _authenticating
                          ? (dark
                              ? const Color(0xFF9C91A9)
                              : const Color(0xFF8D829C))
                          : Colors.white,
                    ),

                    label: Text(
                      _authenticating
                          ? 'Authenticating...'
                          : 'Unlock SONEXA',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _buttonColor(context),

                      foregroundColor: Colors.white,

                      disabledBackgroundColor:
                          _disabledButton(context),

                      disabledForegroundColor:
                          dark
                              ? const Color(0xFF9C91A9)
                              : const Color(0xFF8D829C),

                      elevation: 0,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(17),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // ==================================================
                // SMALL SECURITY TEXT
                // ==================================================

                Text(
                  'Your music stays protected on this device.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _secondaryText(context)
                        .withValues(alpha: 0.75),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}