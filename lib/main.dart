import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

import 'player/player_controller.dart';
import 'player/player_scope.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/biometric_lock_wrapper.dart';
import 'navigation/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final PlayerController playerController = PlayerController();

  await ThemeController.instance.load();

  runApp(
    SonexaApp(
      playerController: playerController,
    ),
  );
}

class SonexaApp extends StatelessWidget {
  final PlayerController playerController;

  const SonexaApp({
    super.key,
    required this.playerController,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance,
      builder: (
        context,
        themeMode,
        child,
      ) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SONEXA',

          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,

          builder: (
            context,
            child,
          ) {
            return PlayerScope(
              controller: playerController,
              child: child ?? const SizedBox.shrink(),
            );
          },

          // App always starts with SONEXA splash.
          home: const SplashScreen(),
        );
      },
    );
  }
}

// ============================================================
// AUTH GATE
// Checks whether user is already logged in.
// ============================================================

class AuthGate extends StatefulWidget {
  const AuthGate({
    super.key,
  });

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _loading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    final bool loggedIn =
        prefs.getBool('isLoggedIn') ?? false;

    if (!mounted) return;

    setState(() {
      _isLoggedIn = loggedIn;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Auth checking
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF07070D),
        body: SizedBox.expand(),
      );
    }

    // User is NOT logged in
    if (!_isLoggedIn) {
      return const LoginScreen();
    }

    // User is already logged in
    return const BiometricLockWrapper(
      child: MainShell(),
    );
  }
}