import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/theme_controller.dart';
import '../player/player_controller.dart';
import '../player/player_scope.dart';

import 'about_screen.dart';
import 'account_settings_screen.dart';
import 'appearance_screen.dart';
import 'audio_quality_screen.dart';
import 'connected_devices_screen.dart';
import 'equalizer_screen.dart';
import 'feedback_screen.dart';
import 'help_support_screen.dart';
import 'login_screen.dart';
import 'lyrics_screen.dart';
import 'privacy_policy_screen.dart';
import 'security_screen.dart';
import 'subscription_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ===========================================================================
  // SETTINGS VALUES
  // ===========================================================================

  bool _autoplay = true;
  bool _notifications = true;
  bool _dataSaver = false;

  String _audioQuality = 'Normal';
  String _language = 'English';

  String _equalizer = 'Flat';
  String _lyricsMode = 'Show lyrics automatically';

  // ===========================================================================
  // ACCOUNT
  // ===========================================================================

  String _accountName = 'SONEXA User';
  String _accountEmail = 'user@example.com';
  String? _accountPhoto;

  // ===========================================================================
  // THEME
  // ===========================================================================

  final ThemeController _themeController = ThemeController.instance;

  static const Color _purple = Color(0xFF9B6BFF);

  // ===========================================================================
  // INIT
  // ===========================================================================

  @override
  void initState() {
    super.initState();

    _themeController.addListener(_onThemeChanged);

    _loadSettings();
  }

  @override
  void dispose() {
    _themeController.removeListener(_onThemeChanged);

    super.dispose();
  }

  void _onThemeChanged() {
    if (!mounted) return;

    setState(() {});
  }

  // ===========================================================================
  // LOAD SETTINGS + ACCOUNT
  // ===========================================================================

  Future<void> _loadSettings() async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    await prefs.reload();

    if (!mounted) return;

    setState(() {
      _autoplay =
          prefs.getBool('settings_autoplay') ?? true;

      _notifications =
          prefs.getBool('settings_notifications') ?? true;

      _dataSaver =
          prefs.getBool('settings_data_saver') ?? false;

      _audioQuality =
          prefs.getString('settings_audio_quality') ?? 'Normal';

      _language =
          prefs.getString('settings_language') ?? 'English';

      _equalizer =
          prefs.getString('settings_equalizer') ?? 'Flat';

      _lyricsMode =
          prefs.getString('settings_lyrics') ??
              'Show lyrics automatically';

      // Account
      _accountName =
          prefs.getString('account_name') ?? 'SONEXA User';

      _accountEmail =
          prefs.getString('account_email') ?? 'user@example.com';

      _accountPhoto =
          prefs.getString('account_photo');
    });
  }

  // ===========================================================================
  // SAVE BOOL
  // ===========================================================================

  Future<void> _setBool(
    String key,
    bool value,
  ) async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    await prefs.setBool(
      key,
      value,
    );
  }

  // ===========================================================================
  // SAVE STRING
  // ===========================================================================

  Future<void> _setString(
    String key,
    String value,
  ) async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      key,
      value,
    );
  }

  // ===========================================================================
  // ACCOUNT
  // ===========================================================================

  Future<void> _showAccount() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AccountSettingsScreen(),
      ),
    );

    await _loadSettings();
  }

  // ===========================================================================
  // SUBSCRIPTION
  // ===========================================================================

  void _openSubscription() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SubscriptionScreen(),
      ),
    );
  }

  // ===========================================================================
  // PRIVACY
  // ===========================================================================

  void _showPrivacy() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PrivacyPolicyScreen(),
      ),
    );
  }

  // ===========================================================================
  // SECURITY
  // ===========================================================================

  void _showSecurity() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SecurityScreen(),
      ),
    );
  }

  // ===========================================================================
  // CONNECTED DEVICES
  // ===========================================================================

  void _showConnectedDevices() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ConnectedDevicesScreen(),
      ),
    );
  }

  // ===========================================================================
  // HELP
  // ===========================================================================

  void _showHelp() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const HelpSupportScreen(),
      ),
    );
  }

  // ===========================================================================
  // EQUALIZER
  // ===========================================================================

  void _showEqualizer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EqualizerScreen(),
      ),
    );
  }

  // ===========================================================================
  // LYRICS
  // ===========================================================================

  void _showLyrics() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LyricsScreen(),
      ),
    );
  }

  // ===========================================================================
  // APPEARANCE
  // ===========================================================================

  void _showAppearance() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AppearanceScreen(),
      ),
    );
  }

  // ===========================================================================
  // AUDIO QUALITY
  // ===========================================================================

  void _showAudioQuality() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AudioQualityScreen(),
      ),
    ).then((_) {
      _loadSettings();
    });
  }

  // ===========================================================================
  // LANGUAGE
  // ===========================================================================

  void _showLanguage() {
    _showSelectionSheet(
      title: 'Language',
      subtitle: 'Choose your preferred language',
      options: const [
        'English',
        'Hindi',
      ],
      selected: _language,
      onSelected: (value) async {
        setState(() {
          _language = value;
        });

        await _setString(
          'settings_language',
          value,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value == 'Hindi'
                  ? 'Language changed to Hindi'
                  : 'Language changed to English',
            ),
            duration: const Duration(
              milliseconds: 1200,
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // GENERIC SELECTION SHEET
  // ===========================================================================

  void _showSelectionSheet({
    required String title,
    required String subtitle,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelected,
  }) {
    final ThemeData theme = Theme.of(context);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              16,
              20,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SheetHandle(
                  theme: theme,
                ),

                const SizedBox(
                  height: 20,
                ),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 6,
                ),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.55,
                      ),
                      fontSize: 13,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                ...options.map(
                  (option) {
                    final bool isSelected =
                        option == selected;

                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: 8,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(16),
                          onTap: () {
                            onSelected(option);

                            Navigator.pop(
                              sheetContext,
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(
                              milliseconds: 180,
                            ),
                            width: double.infinity,
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 15,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? _purple.withValues(
                                      alpha: 0.12,
                                    )
                                  : theme.colorScheme.onSurface
                                      .withValues(
                                      alpha: 0.04,
                                    ),
                              borderRadius:
                                  BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? _purple.withValues(
                                        alpha: 0.45,
                                      )
                                    : Colors.transparent,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      color: theme
                                          .colorScheme
                                          .onSurface,
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons
                                        .check_circle_rounded,
                                    color: _purple,
                                    size: 21,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // FEEDBACK
  // ===========================================================================

  void _showFeedback() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const FeedbackScreen(),
      ),
    );
  }

  // ===========================================================================
  // ABOUT
  // ===========================================================================

  void _showAbout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AboutScreen(),
      ),
    );
  }

  // ===========================================================================
  // LOGOUT
  // ===========================================================================

  void _logout() {
    final ThemeData theme = Theme.of(context);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),

          title: Text(
            'Log out?',
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),

          content: Text(
            'Are you sure you want to log out of SONEXA?',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(
                alpha: 0.6,
              ),
              fontSize: 14,
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(
                    alpha: 0.6,
                  ),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () async {
                // Close confirmation dialog first.
                Navigator.pop(
                  dialogContext,
                );

                // ============================================================
                // STOP CURRENT SONG
                // ============================================================

                final PlayerController player =
                    PlayerScope.of(context);

                await player.stop();

                // ============================================================
                // SAVE LOGOUT STATE
                // ============================================================

                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();

                final bool saved =
                    await prefs.setBool(
                  'isLoggedIn',
                  false,
                );

                await prefs.reload();

                final bool currentLoginState =
                    prefs.getBool(
                          'isLoggedIn',
                        ) ??
                        false;

                debugPrint(
                  'SONEXA LOGOUT -> saved=$saved, '
                  'isLoggedIn=$currentLoginState',
                );

                if (!mounted) return;

                // ============================================================
                // GO TO LOGIN AND CLEAR PREVIOUS NAVIGATION STACK
                // ============================================================

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 11,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Log out',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final bool isDark =
        theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          theme.scaffoldBackgroundColor,

      body: SafeArea(
        child: Column(
          children: [
            // =================================================================
            // FIXED HEADER
            // =================================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                0,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Settings',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),

            // =================================================================
            // SCROLLABLE SETTINGS CONTENT
            // =================================================================

            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  16,
                  28,
                  16,
                  140,
                ),
                children: [
            // =================================================================
            // ACCOUNT
            // =================================================================

            const _SectionHeader(
              title: 'ACCOUNT',
            ),

            const SizedBox(
              height: 10,
            ),

            _AccountGroup(
              accountName: _accountName,
              accountEmail: _accountEmail,
              accountPhoto: _accountPhoto,
              onAccountTap: _showAccount,
              onSubscriptionTap:
                  _openSubscription,
            ),

            const SizedBox(
              height: 28,
            ),

            // =================================================================
            // PLAYBACK
            // =================================================================

            const _SectionHeader(
              title: 'PLAYBACK',
            ),

            const SizedBox(
              height: 10,
            ),

            _GroupedCard(
              children: [
                _GroupedSettingsItem(
                  icon: Icons.equalizer_rounded,
                  title: 'Equalizer',
                  subtitle: _equalizer,
                  onTap: _showEqualizer,
                ),

                const _GroupedDivider(),

                _GroupedSettingsItem(
                  icon: Icons.high_quality_rounded,
                  title: 'Audio Quality',
                  subtitle: _audioQuality,
                  onTap: _showAudioQuality,
                ),

                const _GroupedDivider(),

                _GroupedSettingsItem(
                  icon: Icons.lyrics_rounded,
                  title: 'Lyrics',
                  subtitle: _lyricsMode,
                  onTap: _showLyrics,
                ),

                const _GroupedDivider(),

                _GroupedSwitchItem(
                  icon: Icons.play_arrow_rounded,
                  title: 'Autoplay',
                  subtitle:
                      'Continue playing similar songs',
                  value: _autoplay,
                  onChanged: (value) async {
                    setState(() {
                      _autoplay = value;
                    });

                    await _setBool(
                      'settings_autoplay',
                      value,
                    );
                  },
                ),
              ],
            ),

            const SizedBox(
              height: 28,
            ),

            // =================================================================
            // APPEARANCE
            // =================================================================

            const _SectionHeader(
              title: 'APPEARANCE',
            ),

            const SizedBox(
              height: 10,
            ),

            _GroupedCard(
              children: [
                _GroupedSettingsItem(
                  icon: Icons.brightness_6_rounded,
                  title: 'Appearance',
                  subtitle:
                      _themeController.appearanceName,
                  onTap: _showAppearance,
                ),

                const _GroupedDivider(),

                _GroupedSettingsItem(
                  icon: Icons.language_rounded,
                  title: 'Language',
                  subtitle: _language,
                  onTap: _showLanguage,
                ),
              ],
            ),

            const SizedBox(
              height: 28,
            ),

            // =================================================================
            // NOTIFICATIONS
            // =================================================================

            const _SectionHeader(
              title: 'NOTIFICATIONS',
            ),

            const SizedBox(
              height: 10,
            ),

            _GroupedCard(
              children: [
                _GroupedSwitchItem(
                  icon:
                      Icons.notifications_active_outlined,
                  title: 'Notifications',
                  subtitle:
                      'New releases, updates and recommendations',
                  value: _notifications,
                  onChanged: (value) async {
                    setState(() {
                      _notifications = value;
                    });

                    await _setBool(
                      'settings_notifications',
                      value,
                    );
                  },
                ),
              ],
            ),

            const SizedBox(
              height: 28,
            ),

            // =================================================================
            // DATA & STORAGE
            // =================================================================

            const _SectionHeader(
              title: 'DATA & STORAGE',
            ),

            const SizedBox(
              height: 10,
            ),

            _GroupedCard(
              children: [
                _GroupedSwitchItem(
                  icon:
                      Icons.data_saver_on_rounded,
                  title: 'Data Saver',
                  subtitle:
                      'Reduce mobile data usage',
                  value: _dataSaver,
                  onChanged: (value) async {
                    setState(() {
                      _dataSaver = value;
                    });

                    await _setBool(
                      'settings_data_saver',
                      value,
                    );
                  },
                ),
              ],
            ),

            const SizedBox(
              height: 28,
            ),

            // =================================================================
            // PRIVACY & SECURITY
            // =================================================================

            const _SectionHeader(
              title: 'PRIVACY & SECURITY',
            ),

            const SizedBox(
              height: 10,
            ),

            _GroupedCard(
              children: [
                _GroupedSettingsItem(
                  icon:
                      Icons.privacy_tip_outlined,
                  title: 'Privacy',
                  subtitle:
                      'Privacy policy and your data',
                  onTap: _showPrivacy,
                ),

                const _GroupedDivider(),

                _GroupedSettingsItem(
                  icon:
                      Icons.lock_outline_rounded,
                  title: 'Security',
                  subtitle:
                      'Password and security settings',
                  onTap: _showSecurity,
                ),

                const _GroupedDivider(),

                _GroupedSettingsItem(
                  icon:
                      Icons.devices_other_rounded,
                  title: 'Connected Devices',
                  subtitle:
                      'Manage your connected devices',
                  onTap: _showConnectedDevices,
                ),
              ],
            ),

            const SizedBox(
              height: 28,
            ),

            // =================================================================
            // HELP & SUPPORT
            // =================================================================

            const _SectionHeader(
              title: 'HELP & SUPPORT',
            ),

            const SizedBox(
              height: 10,
            ),

            _GroupedCard(
              children: [
                _GroupedSettingsItem(
                  icon:
                      Icons.help_center_outlined,
                  title: 'Help & Support',
                  subtitle:
                      'Get help with SONEXA',
                  onTap: _showHelp,
                ),

                const _GroupedDivider(),

                _GroupedSettingsItem(
                  icon:
                      Icons.feedback_outlined,
                  title: 'Send Feedback',
                  subtitle:
                      'Tell us how we can improve',
                  onTap: _showFeedback,
                ),
              ],
            ),

            const SizedBox(
              height: 28,
            ),

            // =================================================================
            // ABOUT
            // =================================================================

            const _SectionHeader(
              title: 'ABOUT',
            ),

            const SizedBox(
              height: 10,
            ),

            _GroupedCard(
              children: [
                _GroupedSettingsItem(
                  icon:
                      Icons.info_outline_rounded,
                  title: 'About SONEXA',
                  subtitle: 'Version 1.0.0',
                  onTap: _showAbout,
                ),
              ],
            ),

            const SizedBox(
              height: 30,
            ),

            // =================================================================
            // LOGOUT
            // =================================================================

            _LogoutButton(
              onTap: _logout,
            ),

            const SizedBox(
              height: 26,
            ),

            // =================================================================
            // BRANDING
            // =================================================================

            Center(
              child: Column(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(13),
                      gradient:
                          const LinearGradient(
                        colors: [
                          Color(0xFF9B5CFF),
                          Color(0xFF5B21B6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(13),
                      child: Image.asset(
                        'assets/images/sonexa_logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return const Icon(
                            Icons.graphic_eq_rounded,
                            color: Colors.white,
                            size: 23,
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 9,
                  ),

                  Text(
                    'SONEXA',
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withValues(
                              alpha: 0.22,
                            )
                          : Colors.black.withValues(
                              alpha: 0.25,
                            ),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    'Your music. Your mood. Your sound.',
                    style: TextStyle(
                      color:
                          theme.colorScheme.onSurface.withValues(
                        alpha: 0.3,
                      ),
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// SECTION HEADER
// =============================================================================

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme =
        Theme.of(context);

    return Text(
      title,
      style: TextStyle(
        color:
            theme.colorScheme.onSurface.withValues(
          alpha: 0.55,
        ),
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }
}

// =============================================================================
// ACCOUNT GROUP
// =============================================================================

class _AccountGroup extends StatelessWidget {
  final String accountName;
  final String accountEmail;
  final String? accountPhoto;

  final VoidCallback onAccountTap;
  final VoidCallback onSubscriptionTap;

  const _AccountGroup({
    required this.accountName,
    required this.accountEmail,
    required this.accountPhoto,
    required this.onAccountTap,
    required this.onSubscriptionTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme =
        Theme.of(context);

    final bool hasPhoto =
        accountPhoto != null &&
            accountPhoto!.isNotEmpty &&
            File(accountPhoto!).existsSync();

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius:
            BorderRadius.circular(24),
        border: Border.all(
          color:
              theme.colorScheme.onSurface.withValues(
            alpha: 0.07,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha:
                  theme.brightness ==
                          Brightness.dark
                      ? 0.18
                      : 0.05,
            ),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          // =================================================================
          // ACCOUNT
          // =================================================================

          InkWell(
            onTap: onAccountTap,
            borderRadius:
                const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                18,
                18,
                16,
                18,
              ),
              child: Row(
                children: [
                  // PROFILE PHOTO

                  Container(
                    width: 62,
                    height: 62,
                    decoration:
                        const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient:
                          LinearGradient(
                        colors: [
                          Color(0xFF9B6BFF),
                          Color(0xFF5B21B6),
                        ],
                        begin:
                            Alignment.topLeft,
                        end:
                            Alignment.bottomRight,
                      ),
                    ),
                    child: ClipOval(
                      child: hasPhoto
                          ? Image.file(
                              File(accountPhoto!),
                              width: 62,
                              height: 62,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (
                                context,
                                error,
                                stackTrace,
                              ) {
                                return const Icon(
                                  Icons.person_rounded,
                                  color: Colors.white,
                                  size: 31,
                                );
                              },
                            )
                          : const Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: 31,
                            ),
                    ),
                  ),

                  const SizedBox(
                    width: 15,
                  ),

                  // NAME + EMAIL

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          accountName,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme
                                .colorScheme
                                .onSurface,
                            fontSize: 18,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),

                        const SizedBox(
                          height: 5,
                        ),

                        Text(
                          accountEmail,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme
                                .colorScheme
                                .onSurface
                                .withValues(
                              alpha: 0.5,
                            ),
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme
                        .colorScheme
                        .onSurface
                        .withValues(
                      alpha: 0.4,
                    ),
                    size: 28,
                  ),
                ],
              ),
            ),
          ),

          const _GroupedDivider(),

          // =================================================================
          // SUBSCRIPTION
          // =================================================================

          InkWell(
            onTap: onSubscriptionTap,
            borderRadius:
                const BorderRadius.vertical(
              bottom: Radius.circular(24),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                18,
                14,
                16,
                14,
              ),
              child: Row(
                children: [
                  const _IconBox(
                    icon:
                        Icons.workspace_premium_rounded,
                    size: 40,
                  ),

                  const SizedBox(
                    width: 13,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Subscription',
                          style: TextStyle(
                            color: theme
                                .colorScheme
                                .onSurface,
                            fontSize: 14,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),

                        const SizedBox(
                          height: 3,
                        ),

                        Text(
                          'Manage your SONEXA plan',
                          style: TextStyle(
                            color: theme
                                .colorScheme
                                .onSurface
                                .withValues(
                              alpha: 0.45,
                            ),
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme
                        .colorScheme
                        .onSurface
                        .withValues(
                      alpha: 0.32,
                    ),
                    size: 23,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// GROUPED CARD
// =============================================================================

class _GroupedCard extends StatelessWidget {
  final List<Widget> children;

  const _GroupedCard({
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme =
        Theme.of(context);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius:
            BorderRadius.circular(24),
        border: Border.all(
          color:
              theme.colorScheme.onSurface.withValues(
            alpha: 0.07,
          ),
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

// =============================================================================
// GROUPED SETTINGS ITEM
// =============================================================================

class _GroupedSettingsItem
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _GroupedSettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme =
        Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding:
              const EdgeInsets.fromLTRB(
            16,
            14,
            14,
            14,
          ),
          child: Row(
            children: [
              _IconBox(
                icon: icon,
              ),

              const SizedBox(
                width: 14,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme
                            .colorScheme
                            .onSurface,
                        fontSize: 14.5,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme
                            .colorScheme
                            .onSurface
                            .withValues(
                          alpha: 0.48,
                        ),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              Icon(
                Icons.chevron_right_rounded,
                color: theme
                    .colorScheme
                    .onSurface
                    .withValues(
                  alpha: 0.32,
                ),
                size: 23,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// GROUPED SWITCH ITEM
// =============================================================================

class _GroupedSwitchItem
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _GroupedSwitchItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme =
        Theme.of(context);

    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        16,
        12,
        12,
        12,
      ),
      child: Row(
        children: [
          _IconBox(
            icon: icon,
          ),

          const SizedBox(
            width: 14,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme
                        .colorScheme
                        .onSurface,
                    fontSize: 14.5,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  subtitle,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme
                        .colorScheme
                        .onSurface
                        .withValues(
                      alpha: 0.48,
                    ),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            width: 5,
          ),

          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor:
                _SettingsScreenState._purple,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: theme
                .colorScheme
                .onSurface
                .withValues(
              alpha: 0.15,
            ),
            materialTapTargetSize:
                MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// DIVIDER
// =============================================================================

class _GroupedDivider
    extends StatelessWidget {
  const _GroupedDivider();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme =
        Theme.of(context);

    return Divider(
      height: 1,
      thickness: 1,
      indent: 70,
      endIndent: 16,
      color: theme
          .colorScheme
          .onSurface
          .withValues(
        alpha: 0.065,
      ),
    );
  }
}

// =============================================================================
// ICON BOX
// =============================================================================

class _IconBox extends StatelessWidget {
  final IconData icon;
  final double size;

  const _IconBox({
    required this.icon,
    this.size = 42,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF9B6BFF)
            .withValues(
          alpha: 0.10,
        ),
        borderRadius:
            BorderRadius.circular(13),
      ),
      child: Icon(
        icon,
        color: const Color(0xFF9B6BFF),
        size: size * 0.5,
      ),
    );
  }
}

// =============================================================================
// SHEET HANDLE
// =============================================================================

class _SheetHandle extends StatelessWidget {
  final ThemeData theme;

  const _SheetHandle({
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 4,
      decoration: BoxDecoration(
        color: theme
            .colorScheme
            .onSurface
            .withValues(
          alpha: 0.2,
        ),
        borderRadius:
            BorderRadius.circular(20),
      ),
    );
  }
}

// =============================================================================
// LOGOUT BUTTON
// =============================================================================

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(
          vertical: 15,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF9B6BFF)
              .withValues(
            alpha: 0.08,
          ),
          borderRadius:
              BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFF9B6BFF)
                .withValues(
              alpha: 0.18,
            ),
          ),
        ),
        child: const Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout_rounded,
              color: Color(0xFF9B6BFF),
              size: 19,
            ),
            SizedBox(
              width: 8,
            ),
            Text(
              'Log out',
              style: TextStyle(
                color: Color(0xFF9B6BFF),
                fontSize: 13.5,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}