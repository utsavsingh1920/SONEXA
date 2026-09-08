import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/theme_controller.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  ThemeMode _selectedTheme = ThemeMode.system;

  static const String _themeKey = 'theme_mode';

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);

    ThemeMode mode;

    switch (savedTheme) {
      case 'dark':
        mode = ThemeMode.dark;
        break;

      case 'light':
        mode = ThemeMode.light;
        break;

      case 'system':
      default:
        mode = ThemeMode.system;
        break;
    }

    if (!mounted) return;

    setState(() {
      _selectedTheme = mode;
    });
  }

  Future<void> _changeTheme(ThemeMode mode) async {
    setState(() {
      _selectedTheme = mode;
    });

    final prefs = await SharedPreferences.getInstance();

    String value;

    switch (mode) {
      case ThemeMode.dark:
        value = 'dark';
        break;

      case ThemeMode.light:
        value = 'light';
        break;

      case ThemeMode.system:
        value = 'system';
        break;
    }

    await prefs.setString(_themeKey, value);

    // Apply theme globally.
    await ThemeController.instance.setThemeMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,

      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,

        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: colors.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),

        title: Text(
          'Appearance',
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: ListView(
        physics: const BouncingScrollPhysics(),

        padding: const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          30,
        ),

        children: [
          Text(
            'THEME',
            style: TextStyle(
              color: colors.onSurface.withValues(alpha: 0.55),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),

          const SizedBox(height: 12),

          _themeOption(
            context,
            title: 'Dark',
            subtitle: 'Best for nighttime listening',
            icon: Icons.dark_mode_rounded,
            mode: ThemeMode.dark,
          ),

          _themeOption(
            context,
            title: 'Light',
            subtitle: 'Use SONEXA with a bright theme',
            icon: Icons.light_mode_rounded,
            mode: ThemeMode.light,
          ),

          _themeOption(
            context,
            title: 'System Default',
            subtitle: 'Follow your device settings',
            icon: Icons.settings_suggest_rounded,
            mode: ThemeMode.system,
          ),

          const SizedBox(height: 28),

          Container(
            padding: const EdgeInsets.all(18),

            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(
                alpha: theme.brightness == Brightness.dark
                    ? 0.35
                    : 0.55,
              ),

              borderRadius: BorderRadius.circular(18),

              border: Border.all(
                color: colors.onSurface.withValues(
                  alpha: 0.06,
                ),
              ),
            ),

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.palette_outlined,
                  color: colors.primary,
                  size: 25,
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Text(
                    'Appearance changes how SONEXA looks throughout the app.',
                    style: TextStyle(
                      color: colors.onSurface.withValues(
                        alpha: 0.65,
                      ),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _themeOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required ThemeMode mode,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final bool isSelected = _selectedTheme == mode;

    final bool isDark =
        theme.brightness == Brightness.dark;

    final Color cardColor = isDark
        ? const Color(0xFF11111D)
        : colors.surfaceContainerHighest;

    final Color mutedColor = colors.onSurface.withValues(
      alpha: 0.55,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),

      child: Material(
        color: Colors.transparent,

        child: InkWell(
          borderRadius: BorderRadius.circular(18),

          onTap: () => _changeTheme(mode),

          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),

            padding: const EdgeInsets.all(17),

            decoration: BoxDecoration(
              color: isSelected
                  ? colors.primary.withValues(alpha: 0.10)
                  : cardColor,

              borderRadius: BorderRadius.circular(18),

              border: Border.all(
                color: isSelected
                    ? colors.primary.withValues(alpha: 0.45)
                    : colors.onSurface.withValues(
                        alpha: 0.05,
                      ),
              ),
            ),

            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),

                  width: 45,
                  height: 45,

                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.primary.withValues(
                            alpha: 0.15,
                          )
                        : colors.onSurface.withValues(
                            alpha: 0.05,
                          ),

                    borderRadius: BorderRadius.circular(14),
                  ),

                  child: Icon(
                    icon,

                    color: isSelected
                        ? colors.primary
                        : mutedColor,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Text(
                        title,

                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        subtitle,

                        style: TextStyle(
                          color: mutedColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                AnimatedSwitcher(
                  duration: const Duration(
                    milliseconds: 180,
                  ),

                  child: Icon(
                    isSelected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,

                    key: ValueKey<bool>(isSelected),

                    color: isSelected
                        ? colors.primary
                        : colors.onSurface.withValues(
                            alpha: 0.35,
                          ),
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