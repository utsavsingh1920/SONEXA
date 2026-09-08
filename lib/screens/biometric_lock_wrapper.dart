import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'biometric_lock_screen.dart';

class BiometricLockWrapper extends StatefulWidget {
  const BiometricLockWrapper({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<BiometricLockWrapper> createState() =>
      _BiometricLockWrapperState();
}

class _BiometricLockWrapperState
    extends State<BiometricLockWrapper>
    with WidgetsBindingObserver {
  static const String _biometricKey =
      'security_biometric_enabled';

  bool _enabled = false;
  bool _locked = false;
  bool _loading = true;

  bool _appWasPaused = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _loadBiometricState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  Future<void> _loadBiometricState() async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    if (!mounted) return;

    final bool enabled =
        prefs.getBool(_biometricKey) ?? false;

    setState(() {
      _enabled = enabled;
      _loading = false;
      _locked = enabled;
    });
  }

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    if (!_enabled) return;

    if (state == AppLifecycleState.paused) {
      _appWasPaused = true;
    }

    if (state == AppLifecycleState.resumed &&
        _appWasPaused) {
      _appWasPaused = false;

      _lockApp();
    }
  }

  void _lockApp() {
    if (!mounted || !_enabled) return;

    setState(() {
      _locked = true;
    });
  }

  void _unlockApp() {
    if (!mounted) return;

    setState(() {
      _locked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF080812),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF9B6BFF),
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,

        if (_locked)
          Positioned.fill(
            child: Material(
              color: const Color(0xFF080812),
              child: BiometricLockScreen(
                onUnlocked: _unlockApp,
              ),
            ),
          ),
      ],
    );
  }
}