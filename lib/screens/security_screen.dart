import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  // ============================================================
  // DARK THEME COLORS
  // ============================================================

  static const Color _darkBackground = Color(0xFF080812);
  static const Color _darkCard = Color(0xFF12101A);
  static const Color _darkBorder = Color(0xFF292231);
  static const Color _darkPurple = Color(0xFF9B6BFF);
  static const Color _darkMuted = Color(0xFF8E8A9A);
  static const Color _darkIconBackground = Color(0xFF1D1728);
  static const Color _darkSecondaryText = Color(0xFF817A8D);

  // ============================================================
  // LIGHT THEME COLORS
  // ============================================================

  static const Color _lightBackground = Color(0xFFF7F5FA);
  static const Color _lightCard = Color(0xFFFFFFFF);
  static const Color _lightBorder = Color(0xFFE3DDEB);
  static const Color _lightPurple = Color(0xFF7B3FE4);
  static const Color _lightMuted = Color(0xFF70697A);
  static const Color _lightIconBackground = Color(0xFFF0E7FF);
  static const Color _lightSecondaryText = Color(0xFF6F6878);

  // ============================================================
  // STORAGE KEYS
  // ============================================================

  static const String _biometricKey =
      'security_biometric_enabled';

  static const String _loginAlertsKey =
      'security_login_alerts';

  // ============================================================
  // AUTH
  // ============================================================

  final LocalAuthentication _localAuth =
      LocalAuthentication();

  bool _biometric = false;
  bool _loginAlerts = true;
  bool _loading = true;
  bool _busy = false;

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

  Color _cardColor(BuildContext context) {
    return _isDark(context)
        ? _darkCard
        : _lightCard;
  }

  Color _borderColor(BuildContext context) {
    return _isDark(context)
        ? _darkBorder
        : _lightBorder;
  }

  Color _purple(BuildContext context) {
    return _isDark(context)
        ? _darkPurple
        : _lightPurple;
  }

  Color _muted(BuildContext context) {
    return _isDark(context)
        ? _darkMuted
        : _lightMuted;
  }

  Color _iconBackground(BuildContext context) {
    return _isDark(context)
        ? _darkIconBackground
        : _lightIconBackground;
  }

  Color _secondaryText(BuildContext context) {
    return _isDark(context)
        ? _darkSecondaryText
        : _lightSecondaryText;
  }

  Color _primaryText(BuildContext context) {
    return _isDark(context)
        ? Colors.white
        : const Color(0xFF18151D);
  }

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // ============================================================
  // LOAD SETTINGS
  // ============================================================

  Future<void> _loadSettings() async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _biometric =
          prefs.getBool(_biometricKey) ?? false;

      _loginAlerts =
          prefs.getBool(_loginAlertsKey) ?? true;

      _loading = false;
    });
  }

  // ============================================================
  // BIOMETRIC AUTHENTICATION
  // ============================================================

  Future<bool> _authenticate() async {
    try {
      final bool supported =
          await _localAuth.isDeviceSupported();

      if (!supported) {
        _showMessage(
          'Biometric authentication is not supported on this device.',
        );
        return false;
      }

      final bool canCheck =
          await _localAuth.canCheckBiometrics;

      if (!canCheck) {
        _showMessage(
          'No fingerprint or face authentication is available.',
        );
        return false;
      }

      final List<BiometricType> biometrics =
          await _localAuth.getAvailableBiometrics();

      if (biometrics.isEmpty) {
        _showMessage(
          'Please set up fingerprint or face unlock on your device first.',
        );
        return false;
      }

      final bool authenticated =
          await _localAuth.authenticate(
        localizedReason:
            'Authenticate to protect your SONEXA account.',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
          sensitiveTransaction: true,
        ),
      );

      return authenticated;
    } catch (_) {
      if (mounted) {
        _showMessage(
          'Biometric authentication failed.',
        );
      }

      return false;
    }
  }

  // ============================================================
  // BIOMETRIC TOGGLE
  // ============================================================

  Future<void> _toggleBiometric(
    bool value,
  ) async {
    if (_busy) return;

    setState(() {
      _busy = true;
    });

    if (value) {
      final bool authenticated =
          await _authenticate();

      if (!mounted) return;

      if (authenticated) {
        final SharedPreferences prefs =
            await SharedPreferences.getInstance();

        await prefs.setBool(
          _biometricKey,
          true,
        );

        if (!mounted) return;

        setState(() {
          _biometric = true;
        });

        _showMessage(
          'Biometric lock enabled.',
        );
      } else {
        setState(() {
          _biometric = false;
        });
      }
    } else {
      final bool authenticated =
          await _authenticate();

      if (!mounted) return;

      if (authenticated) {
        final SharedPreferences prefs =
            await SharedPreferences.getInstance();

        await prefs.setBool(
          _biometricKey,
          false,
        );

        if (!mounted) return;

        setState(() {
          _biometric = false;
        });

        _showMessage(
          'Biometric lock disabled.',
        );
      }
    }

    if (!mounted) return;

    setState(() {
      _busy = false;
    });
  }

  // ============================================================
  // LOGIN ALERTS
  // ============================================================

  Future<void> _toggleLoginAlerts(
    bool value,
  ) async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    await prefs.setBool(
      _loginAlertsKey,
      value,
    );

    if (!mounted) return;

    setState(() {
      _loginAlerts = value;
    });
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    final bool dark = _isDark(context);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(
              color: dark
                  ? Colors.white
                  : Colors.white,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: dark
              ? const Color(0xFF211A2B)
              : const Color(0xFF6D3DB8),
        ),
      );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background(context),

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        backgroundColor: _background(context),
        elevation: 0,
        surfaceTintColor: Colors.transparent,

        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: _primaryText(context),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: Text(
          'Security',
          style: TextStyle(
            color: _primaryText(context),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                color: _purple(context),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                20,
                10,
                20,
                30,
              ),
              children: [
                // ==================================================
                // SECURITY HEADER CARD
                // ==================================================

                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _purple(context)
                        .withValues(alpha: 0.08),
                    borderRadius:
                        BorderRadius.circular(18),
                    border: Border.all(
                      color: _purple(context)
                          .withValues(alpha: 0.18),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: _purple(context)
                              .withValues(alpha: 0.15),
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.shield_rounded,
                          color: _purple(context),
                        ),
                      ),

                      const SizedBox(width: 13),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Keep your account secure',
                              style: TextStyle(
                                color:
                                    _primaryText(context),
                                fontSize: 15,
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              'Manage security preferences for your SONEXA account.',
                              style: TextStyle(
                                color:
                                    _secondaryText(
                                  context,
                                ),
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ==================================================
                // SECURITY OPTIONS TITLE
                // ==================================================

                Text(
                  'SECURITY OPTIONS',
                  style: TextStyle(
                    color: _muted(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),

                const SizedBox(height: 10),

                // ==================================================
                // BIOMETRIC
                // ==================================================

                _switchItem(
                  context,
                  icon: Icons.fingerprint_rounded,
                  title: 'Biometric Lock',
                  subtitle: _biometric
                      ? 'Fingerprint or face unlock is enabled'
                      : 'Use fingerprint or face unlock',
                  value: _biometric,
                  onChanged: _toggleBiometric,
                ),

                // ==================================================
                // LOGIN ALERTS
                // ==================================================

                _switchItem(
                  context,
                  icon:
                      Icons.notifications_active_rounded,
                  title: 'Login Alerts',
                  subtitle:
                      'Get notified about new sign-ins',
                  value: _loginAlerts,
                  onChanged: _toggleLoginAlerts,
                ),

                const SizedBox(height: 12),

                // ==================================================
                // CHANGE PASSWORD
                // ==================================================

                _actionItem(
                  context,
                  icon: Icons.lock_reset_rounded,
                  title: 'Change Password',
                  subtitle:
                      'Update your account password',
                  onTap: () {
                    _showComingSoon(
                      context,
                      'Change Password',
                    );
                  },
                ),

                // ==================================================
                // SIGN OUT ALL DEVICES
                // ==================================================

                _actionItem(
                  context,
                  icon: Icons.logout_rounded,
                  title:
                      'Sign Out From All Devices',
                  subtitle:
                      'Sign out of every active session',
                  onTap: () {
                    _showSignOutDialog(context);
                  },
                ),

                const SizedBox(height: 25),

                // ==================================================
                // SECURITY TIPS TITLE
                // ==================================================

                Text(
                  'SECURITY TIPS',
                  style: TextStyle(
                    color: _muted(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Use a strong password and never share your login details with anyone.',
                  style: TextStyle(
                    color: _muted(context),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
    );
  }

  // ============================================================
  // SWITCH ITEM
  // ============================================================

  Widget _switchItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: _cardColor(context),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: _borderColor(context),
        ),
      ),
      child: Row(
        children: [
          // ICON
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: _iconBackground(context),
              borderRadius:
                  BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: _purple(context),
              size: 21,
            ),
          ),

          const SizedBox(width: 12),

          // TEXT
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color:
                        _primaryText(context),
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: TextStyle(
                    color:
                        _secondaryText(context),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          // SWITCH / LOADING
          if (_busy &&
              title == 'Biometric Lock')
            SizedBox(
              width: 20,
              height: 20,
              child:
                  CircularProgressIndicator(
                strokeWidth: 2,
                color: _purple(context),
              ),
            )
          else
            Switch(
              value: value,
              onChanged: onChanged,
              thumbColor:
                  WidgetStateProperty
                      .resolveWith<Color>(
                (states) {
                  if (states.contains(
                    WidgetState.selected,
                  )) {
                    return _isDark(context)
                        ? const Color(0xFFB77CFF)
                        : const Color(0xFF7B3FE4);
                  }

                  return _isDark(context)
                      ? const Color(0xFF777080)
                      : const Color(0xFFAAA4B2);
                },
              ),
              trackColor:
                  WidgetStateProperty
                      .resolveWith<Color>(
                (states) {
                  if (states.contains(
                    WidgetState.selected,
                  )) {
                    return _isDark(context)
                        ? const Color(0xFF49266B)
                        : const Color(0xFFDCC7FF);
                  }

                  return _isDark(context)
                      ? const Color(0xFF292231)
                      : const Color(0xFFE2DDE8);
                },
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTION ITEM
  // ============================================================

  Widget _actionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            color: _cardColor(context),
            borderRadius:
                BorderRadius.circular(17),
            border: Border.all(
              color: _borderColor(context),
            ),
          ),
          child: Row(
            children: [
              // ICON
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: _iconBackground(context),
                  borderRadius:
                      BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: _purple(context),
                  size: 21,
                ),
              ),

              const SizedBox(width: 12),

              // TEXT
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color:
                            _primaryText(context),
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style: TextStyle(
                        color:
                            _secondaryText(context),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),

              // CHEVRON
              Icon(
                Icons.chevron_right_rounded,
                color: _muted(context),
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CHANGE PASSWORD DIALOG
  // ============================================================

  void _showComingSoon(
    BuildContext context,
    String title,
  ) {

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _cardColor(context),
          surfaceTintColor:
              Colors.transparent,

          title: Text(
            title,
            style: TextStyle(
              color: _primaryText(context),
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          content: Text(
            'This feature will be available soon.',
            style: TextStyle(
              color:
                  _secondaryText(context),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: _purple(context),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // SIGN OUT DIALOG
  // ============================================================

  void _showSignOutDialog(
    BuildContext context,
  ) {
    final bool dark = _isDark(context);

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _cardColor(context),
          surfaceTintColor:
              Colors.transparent,

          title: Text(
            'Sign out from all devices?',
            style: TextStyle(
              color: _primaryText(context),
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          content: Text(
            'This will sign you out from every active SONEXA session.',
            style: TextStyle(
              color:
                  _secondaryText(context),
            ),
          ),

          actions: [
            // CANCEL
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: _muted(context),
                ),
              ),
            ),

            // SIGN OUT
            TextButton(
              onPressed: () async {
                final SharedPreferences prefs =
                    await SharedPreferences
                        .getInstance();

                await prefs.setBool(
                  'isLoggedIn',
                  false,
                );

                if (!context.mounted) return;

                Navigator.pop(dialogContext);

                Navigator.of(context)
                    .popUntil(
                  (route) => route.isFirst,
                );
              },
              child: Text(
                'Sign Out',
                style: TextStyle(
                  color: dark
                      ? const Color(0xFFFF6B81)
                      : const Color(0xFFD93655),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}