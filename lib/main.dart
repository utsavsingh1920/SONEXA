import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';
import 'player/player_controller.dart';
import 'player/player_scope.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/biometric_lock_wrapper.dart';
import 'navigation/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final playerController = PlayerController();
  await ThemeController.instance.load();
  runApp(SonexaApp(playerController: playerController));
}

class SonexaApp extends StatelessWidget {
  final PlayerController playerController;
  const SonexaApp({super.key, required this.playerController});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance,
      builder: (context, themeMode, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SONEXA',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        builder: (context, child) => PlayerScope(
          controller: playerController,
          child: child ?? const SizedBox.shrink(),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

// Keep this AuthGate in main.dart because splash_screen.dart imports ../main.dart.
// Do NOT also import/use screens/auth_gate.dart.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Future<Widget> _destination = _getDestination();

  Future<Widget> _getDestination() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool('isLoggedIn') ?? false;
    final registered = prefs.getBool('hasRegistered') ??
        (prefs.getString('account_email') != null ||
         prefs.getString('sonexa_profile_email') != null || loggedIn);

    if (loggedIn) {
      return const BiometricLockWrapper(child: MainShell());
    }
    if (registered) return const LoginScreen();
    return const SignupScreen();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _destination,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            backgroundColor: Color(0xFF090414),
            body: Center(child: Text('Could not open SONEXA',
              style: TextStyle(color: Colors.white))),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(backgroundColor: Color(0xFF090414),
            body: Center(child: CircularProgressIndicator(
              color: Color(0xFFB852FA))));
        }
        return snapshot.data!;
      },
    );
  }
}
